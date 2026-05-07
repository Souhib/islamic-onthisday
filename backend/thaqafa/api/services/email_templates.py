"""Editorial email templates rendered via Jinja2.

Templates live in ``thaqafa/email_templates/*.{html,txt}`` and ship inside
the package wheel, so deployment is just "install the package, send the
email". Auto-escaping covers any user-provided field (display_name,
greeting); the Python wrappers below stay declarative — pass the data
in, get ``(subject, html, text)`` back.
"""

from jinja2 import Environment, PackageLoader, select_autoescape

# One env, lazy-built at first use. PackageLoader resolves to
# ``thaqafa/email_templates/`` inside the installed wheel.
_env: Environment | None = None


def _get_env() -> Environment:
    global _env  # noqa: PLW0603 — process-singleton, set once on first use
    if _env is None:
        _env = Environment(
            loader=PackageLoader("thaqafa", "email_templates"),
            autoescape=select_autoescape(enabled_extensions=("html",), default_for_string=False),
            trim_blocks=True,
            lstrip_blocks=True,
        )
    return _env


def _greeting(name: str | None) -> str:
    return f"Bonjour {name}," if name else "Bonjour,"


def password_reset_email(*, reset_url: str, user_display_name: str | None) -> tuple[str, str, str]:
    """Build (subject, html, text) for the password reset email."""
    env = _get_env()
    ctx = {
        "headline": "Réinitialiser votre mot de passe",
        "accent_label": "Islamic On This Day",
        "greeting": _greeting(user_display_name),
        "href": reset_url,
        "label": "Réinitialiser mon mot de passe",
    }
    html = env.get_template("password_reset.html").render(**ctx)
    text = env.get_template("password_reset.txt").render(**ctx)
    subject = "Réinitialisez votre mot de passe — Islamic On This Day"
    return subject, html, text


def email_verification_email(*, verify_url: str, user_display_name: str | None) -> tuple[str, str, str]:
    """Build (subject, html, text) for the welcome + verification email."""
    env = _get_env()
    ctx = {
        "headline": "Bienvenue parmi nous",
        "accent_label": "Islamic On This Day",
        "greeting": _greeting(user_display_name),
        "href": verify_url,
        "label": "Confirmer mon adresse",
    }
    html = env.get_template("email_verification.html").render(**ctx)
    text = env.get_template("email_verification.txt").render(**ctx)
    subject = "Bienvenue — confirmez votre adresse · Islamic On This Day"
    return subject, html, text


def password_changed_email(*, reset_url: str, user_display_name: str | None) -> tuple[str, str, str]:
    """Build (subject, html, text) for the post-change password notification.

    The CTA points at ``/forgot-password`` so a user who didn't trigger
    the change can immediately reset and lock the attacker out.
    """
    env = _get_env()
    ctx = {
        "headline": "Mot de passe modifié",
        "accent_label": "Islamic On This Day",
        "greeting": _greeting(user_display_name),
        "href": reset_url,
        "label": "Réinitialiser mon mot de passe",
    }
    html = env.get_template("password_changed.html").render(**ctx)
    text = env.get_template("password_changed.txt").render(**ctx)
    subject = "Votre mot de passe a été modifié · Islamic On This Day"
    return subject, html, text


def email_change_verify_email(*, verify_url: str, user_display_name: str | None) -> tuple[str, str, str]:
    """Build the email sent to the NEW address to confirm an email change."""
    env = _get_env()
    ctx = {
        "headline": "Confirmer la nouvelle adresse",
        "accent_label": "Islamic On This Day",
        "greeting": _greeting(user_display_name),
        "href": verify_url,
        "label": "Confirmer cette adresse",
    }
    html = env.get_template("email_change_verify.html").render(**ctx)
    text = env.get_template("email_change_verify.txt").render(**ctx)
    subject = "Confirmez votre nouvelle adresse · Islamic On This Day"
    return subject, html, text


def email_change_notice_email(
    *,
    reset_url: str,
    new_email: str,
    user_display_name: str | None,
) -> tuple[str, str, str]:
    """Heads-up sent to the OLD email when a change is initiated."""
    env = _get_env()
    ctx = {
        "headline": "Demande de changement d'email",
        "accent_label": "Islamic On This Day",
        "greeting": _greeting(user_display_name),
        "href": reset_url,
        "label": "Réinitialiser mon mot de passe",
        "new_email": new_email,
    }
    html = env.get_template("email_change_notice.html").render(**ctx)
    text = env.get_template("email_change_notice.txt").render(**ctx)
    subject = "Demande de changement d'email · Islamic On This Day"
    return subject, html, text
