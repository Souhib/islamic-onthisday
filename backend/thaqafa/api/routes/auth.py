"""Auth routes — signup, login, refresh, /me, password reset, email verification."""

from typing import Annotated

from fastapi import APIRouter, Depends, Request, status
from fastapi.responses import Response

from thaqafa.api.cache import NO_STORE
from thaqafa.api.controllers.account import AccountController
from thaqafa.api.controllers.auth import AuthController
from thaqafa.api.controllers.email_verification import EmailVerificationController
from thaqafa.api.controllers.password_reset import PasswordResetController
from thaqafa.api.rate_limit import AUTH_MAILER_LIMIT, AUTH_TIGHT_LIMIT, limiter
from thaqafa.api.schemas.auth import (
    ChangeDisplayNameRequest,
    ChangeEmailConfirm,
    ChangeEmailRequest,
    ChangePasswordRequest,
    EmailVerifyConfirm,
    EmailVerifyResend,
    LoginRequest,
    PasswordResetConfirm,
    PasswordResetRequest,
    RefreshRequest,
    SignupRequest,
    TokenPair,
    UserPublic,
)
from thaqafa.dependencies import (
    get_account_controller,
    get_auth_controller,
    get_current_user,
    get_email_verification_controller,
    get_password_reset_controller,
)
from thaqafa.models.user import User

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/signup",
    response_model=TokenPair,
    response_model_by_alias=True,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new account and receive a token pair",
    dependencies=[NO_STORE],
)
@limiter.limit(AUTH_TIGHT_LIMIT)
async def signup(
    request: Request,  # noqa: ARG001  (consumed by slowapi.limiter decorator)
    body: SignupRequest,
    controller: Annotated[AuthController, Depends(get_auth_controller)],
) -> TokenPair:
    return await controller.signup(body)


@router.post(
    "/login",
    response_model=TokenPair,
    response_model_by_alias=True,
    summary="Exchange email + password for a token pair",
    dependencies=[NO_STORE],
)
@limiter.limit(AUTH_TIGHT_LIMIT)
async def login(
    request: Request,  # noqa: ARG001
    body: LoginRequest,
    controller: Annotated[AuthController, Depends(get_auth_controller)],
) -> TokenPair:
    return await controller.login(body)


@router.post(
    "/refresh",
    response_model=TokenPair,
    response_model_by_alias=True,
    summary="Exchange a refresh token for a fresh pair",
    dependencies=[NO_STORE],
)
async def refresh(
    body: RefreshRequest,
    controller: Annotated[AuthController, Depends(get_auth_controller)],
) -> TokenPair:
    return await controller.refresh(body.refresh_token)


@router.get(
    "/me",
    response_model=UserPublic,
    response_model_by_alias=True,
    summary="Return the authenticated user's profile",
    dependencies=[NO_STORE],
)
async def me(user: Annotated[User, Depends(get_current_user)]) -> UserPublic:
    return UserPublic.model_validate(user)


@router.post(
    "/password-reset/request",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Send a password-reset email if the address is registered",
    dependencies=[NO_STORE],
)
@limiter.limit(AUTH_MAILER_LIMIT)
async def request_password_reset(
    request: Request,  # noqa: ARG001
    body: PasswordResetRequest,
    controller: Annotated[PasswordResetController, Depends(get_password_reset_controller)],
) -> Response:
    await controller.request_reset(body)
    # Always 204 — never reveal whether the email is registered. Account
    # enumeration is a leak we don't need to enable just for nicer errors.
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/password-reset/confirm",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Consume a password-reset token and set a new password",
    dependencies=[NO_STORE],
)
async def confirm_password_reset(
    body: PasswordResetConfirm,
    controller: Annotated[PasswordResetController, Depends(get_password_reset_controller)],
) -> Response:
    await controller.confirm_reset(body)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/email/verify",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Consume an email-verification token and mark the user verified",
    dependencies=[NO_STORE],
)
async def verify_email(
    body: EmailVerifyConfirm,
    controller: Annotated[EmailVerificationController, Depends(get_email_verification_controller)],
) -> Response:
    await controller.confirm(body.token)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/email/resend",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Re-send the verification email if the address is registered",
    dependencies=[NO_STORE],
)
@limiter.limit(AUTH_MAILER_LIMIT)
async def resend_verification_email(
    request: Request,  # noqa: ARG001
    body: EmailVerifyResend,
    controller: Annotated[EmailVerificationController, Depends(get_email_verification_controller)],
) -> Response:
    await controller.resend(body)
    # Always 204 — never reveal whether the email is registered.
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# --- Account self-management ----------------------------------------------


@router.patch(
    "/me",
    response_model=UserPublic,
    response_model_by_alias=True,
    summary="Update the authenticated user's display name",
    dependencies=[NO_STORE],
)
async def change_display_name(
    body: ChangeDisplayNameRequest,
    user: Annotated[User, Depends(get_current_user)],
    controller: Annotated[AccountController, Depends(get_account_controller)],
) -> UserPublic:
    updated = await controller.change_display_name(user, body)
    return UserPublic.model_validate(updated)


@router.post(
    "/me/password",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Rotate the authenticated user's password",
    dependencies=[NO_STORE],
)
async def change_password(
    body: ChangePasswordRequest,
    user: Annotated[User, Depends(get_current_user)],
    controller: Annotated[AccountController, Depends(get_account_controller)],
) -> Response:
    await controller.change_password(user, body)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/me/email",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Start the email-change flow (verify link sent to the new address)",
    dependencies=[NO_STORE],
)
async def request_email_change(
    body: ChangeEmailRequest,
    user: Annotated[User, Depends(get_current_user)],
    controller: Annotated[AccountController, Depends(get_account_controller)],
) -> Response:
    await controller.request_email_change(user, body)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/me/email/confirm",
    response_model=UserPublic,
    response_model_by_alias=True,
    summary="Consume an email-change token and apply the new address",
    dependencies=[NO_STORE],
)
async def confirm_email_change(
    body: ChangeEmailConfirm,
    controller: Annotated[AccountController, Depends(get_account_controller)],
) -> UserPublic:
    updated = await controller.confirm_email_change(body)
    return UserPublic.model_validate(updated)


@router.delete(
    "/me",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Permanently delete the authenticated user's account",
    dependencies=[NO_STORE],
)
async def delete_account(
    user: Annotated[User, Depends(get_current_user)],
    controller: Annotated[AccountController, Depends(get_account_controller)],
) -> Response:
    """Permanently delete the authenticated user.

    Cascades the user's bookmarks + every one-time-token row in a single
    transaction. Idempotent — a re-tried delete on a token whose user is
    already gone resolves to a no-op via the existing 401-on-missing-user
    flow.
    """
    await controller.delete_account(user)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
