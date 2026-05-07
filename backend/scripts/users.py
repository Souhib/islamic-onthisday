#!/usr/bin/env python3
"""User-admin CLI for the thaqafa backend.

Same shape as Majlisna's ``generate_fake_data.py`` and LaTabdhir's
``expire_pending_orders.py``: a single script under ``backend/scripts/``
that wires up the async DB engine, runs one operation, and tears down.

Usage (from ``backend/``):

    uv run python scripts/users.py create --email me@example.com \\
        --display-name "Souhib"
    uv run python scripts/users.py list
    uv run python scripts/users.py delete --email me@example.com --yes
    uv run python scripts/users.py delete-all --yes

``create`` will prompt for the password securely if ``--password`` isn't
passed, so the secret never lands in shell history. ``delete`` cascades
to bookmarks and to both token tables in a single transaction.
``delete-all`` is the nuclear option and demands ``--yes`` explicitly to
avoid muscle-memory accidents.
"""

import argparse
import asyncio
import sys
from getpass import getpass

from pydantic import EmailStr, TypeAdapter, ValidationError
from sqlalchemy import delete, func, select

from thaqafa import database as _database
from thaqafa.api.services.auth import hash_password
from thaqafa.database import dispose_engine, init_engine
from thaqafa.models.user import Bookmark, EmailVerificationToken, PasswordResetToken, User
from thaqafa.settings import get_settings

# Reuse FastAPI's email validator so the script accepts the same shapes
# the API does. Plain ``re`` would diverge over time.
_EMAIL_VALIDATOR: TypeAdapter[EmailStr] = TypeAdapter(EmailStr)
_MIN_PASSWORD_CHARS = 8


def _normalise_email(raw: str) -> str:
    try:
        validated = _EMAIL_VALIDATOR.validate_python(raw)
    except ValidationError as e:
        sys.exit(f"invalid email: {e.errors()[0]['msg']}")
    return str(validated).strip().lower()


def _read_password(arg: str | None) -> str:
    pw = arg if arg is not None else getpass("Password: ")
    if len(pw) < _MIN_PASSWORD_CHARS:
        sys.exit(f"password must be at least {_MIN_PASSWORD_CHARS} characters")
    return pw


async def _find_user(session, email: str) -> User | None:
    row = (await session.exec(select(User).where(User.email == email))).first()
    if row is None:
        return None
    return row[0] if hasattr(row, "_fields") or isinstance(row, tuple) else row


async def _delete_user_cascade(session, user: User) -> dict[str, int]:
    """Delete one user + everything that references them. Returns a count map."""
    bookmarks = (await session.exec(delete(Bookmark).where(Bookmark.user_id == user.id))).rowcount  # type: ignore[union-attr]
    pw_tokens = (await session.exec(delete(PasswordResetToken).where(PasswordResetToken.user_id == user.id))).rowcount  # type: ignore[union-attr]
    verify_tokens = (
        await session.exec(delete(EmailVerificationToken).where(EmailVerificationToken.user_id == user.id))
    ).rowcount  # type: ignore[union-attr]
    (await session.exec(delete(User).where(User.id == user.id)))
    await session.commit()
    return {
        "bookmarks": int(bookmarks or 0),
        "password_reset_tokens": int(pw_tokens or 0),
        "email_verification_tokens": int(verify_tokens or 0),
        "users": 1,
    }


async def cmd_create(args, session) -> int:
    email = _normalise_email(args.email)
    display_name = args.display_name.strip()
    if not display_name:
        sys.exit("display name cannot be empty")
    password = _read_password(args.password)

    existing = await _find_user(session, email)
    if existing is not None:
        sys.exit(f"a user with email {email!r} already exists ({existing.id})")

    user = User(
        email=email,
        password_hash=hash_password(password),
        display_name=display_name,
        email_verified=not args.unverified,
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)
    print(
        f"created user {user.id}\n"
        f"  email:           {user.email}\n"
        f"  display_name:    {user.display_name}\n"
        f"  email_verified:  {user.email_verified}"
    )
    return 0


async def cmd_delete(args, session) -> int:
    email = _normalise_email(args.email)
    user = await _find_user(session, email)
    if user is None:
        sys.exit(f"no user with email {email!r}")

    if not args.yes:
        ans = input(f"delete user {email} ({user.id}) and all their data? [y/N] ").strip().lower()
        if ans not in {"y", "yes"}:
            print("aborted")
            return 1

    counts = await _delete_user_cascade(session, user)
    print(
        f"deleted user {user.id}\n"
        f"  bookmarks:                 {counts['bookmarks']}\n"
        f"  password_reset_tokens:     {counts['password_reset_tokens']}\n"
        f"  email_verification_tokens: {counts['email_verification_tokens']}"
    )
    return 0


async def cmd_list(_args, session) -> int:
    rows = (await session.exec(select(User).order_by(User.created_at.desc()))).all()
    users: list[User] = [r[0] if hasattr(r, "_fields") or isinstance(r, tuple) else r for r in rows]
    if not users:
        print("(no users)")
        return 0
    # Per-user bookmark count.
    counts: dict = {}
    for u in users:
        n_row = (await session.exec(select(func.count()).select_from(Bookmark).where(Bookmark.user_id == u.id))).one()
        counts[u.id] = int(n_row[0] if hasattr(n_row, "__getitem__") else n_row)

    print(f"{'email':<40} {'name':<24} {'verified':<8} {'bookmarks':<10} created_at")
    print("-" * 110)
    for u in users:
        verified = "✓" if u.email_verified else "—"
        print(f"{u.email:<40} {(u.display_name or ''):<24} {verified:<8} {counts[u.id]:<10} {u.created_at.isoformat()}")
    print(f"\n{len(users)} user(s)")
    return 0


async def cmd_delete_all(args, session) -> int:
    n_users = int((await session.exec(select(func.count()).select_from(User))).one()[0])
    n_bookmarks = int((await session.exec(select(func.count()).select_from(Bookmark))).one()[0])
    n_pw = int((await session.exec(select(func.count()).select_from(PasswordResetToken))).one()[0])
    n_verify = int((await session.exec(select(func.count()).select_from(EmailVerificationToken))).one()[0])

    if n_users == 0:
        print("(no users)")
        return 0

    print(
        f"about to delete:\n"
        f"  users:                     {n_users}\n"
        f"  bookmarks:                 {n_bookmarks}\n"
        f"  password_reset_tokens:     {n_pw}\n"
        f"  email_verification_tokens: {n_verify}"
    )
    if not args.yes:
        sys.exit("refusing to wipe — pass --yes to confirm")

    await session.exec(delete(Bookmark))
    await session.exec(delete(PasswordResetToken))
    await session.exec(delete(EmailVerificationToken))
    await session.exec(delete(User))
    await session.commit()
    print("done")
    return 0


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="users.py",
        description=(
            "Manage thaqafa user accounts. ``create`` makes a verified user "
            "(use --unverified to skip the verified flag); ``delete`` "
            "cascades to bookmarks + tokens; ``delete-all`` requires --yes."
        ),
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_create = sub.add_parser("create", help="Create a new user account.")
    p_create.add_argument("--email", required=True)
    p_create.add_argument(
        "--password",
        help="Password. If omitted, the script prompts securely (recommended).",
    )
    p_create.add_argument("--display-name", required=True)
    p_create.add_argument(
        "--unverified",
        action="store_true",
        help="Mark the new account as un-verified (default: verified).",
    )
    p_create.set_defaults(handler=cmd_create)

    p_delete = sub.add_parser("delete", help="Delete one user and all their data.")
    p_delete.add_argument("--email", required=True)
    p_delete.add_argument(
        "--yes",
        action="store_true",
        help="Skip the confirmation prompt.",
    )
    p_delete.set_defaults(handler=cmd_delete)

    p_list = sub.add_parser("list", help="List all users with bookmark counts.")
    p_list.set_defaults(handler=cmd_list)

    p_delete_all = sub.add_parser(
        "delete-all",
        help="Wipe every user + their data. Requires --yes.",
    )
    p_delete_all.add_argument(
        "--yes",
        action="store_true",
        help="Required to actually run — without it the script previews and exits.",
    )
    p_delete_all.set_defaults(handler=cmd_delete_all)

    return parser


async def _run() -> int:
    args = _build_parser().parse_args()
    settings = get_settings()
    await init_engine(settings)
    try:
        if _database._session_factory is None:
            sys.exit("database not initialised")
        async with _database._session_factory() as session:
            return await args.handler(args, session)
    finally:
        await dispose_engine()


if __name__ == "__main__":
    sys.exit(asyncio.run(_run()))
