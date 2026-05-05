"""Editorial email templates — minimal HTML mirroring the FE typography.

Inline styles only: most clients (Gmail, Outlook, Apple Mail) strip
``<style>`` tags or quirk on them in odd ways. Same paper / ink colour
palette as the website so the messages feel like the product they came
from rather than a generic auth email.
"""

import html as _html

# Conservative web-safe stack — Apple Mail / Gmail render the project's
# Cardo / GT Sectra-style serif without embedded webfonts. We don't ship
# webfonts in email; they're a deliverability foot-gun.
_FONT_SERIF = "'Iowan Old Style', 'Palatino Linotype', Palatino, Georgia, 'Times New Roman', serif"
_FONT_MONO = "'SF Mono', 'Menlo', 'Consolas', monospace"

_PAPER = "#f4ede0"
_INK = "#1b1a17"
_INK_SOFT = "#3b3933"
_RULE = "#cdc6b6"
_ACCENT = "#7a5b3a"


def _shell(*, headline: str, body_html: str, accent_label: str) -> str:
    """Wrap a body fragment in the standard chrome.

    The chrome is intentionally spartan: a centered paper-coloured panel
    with a thin top frame, an accent eyebrow, a serif headline, the body
    fragment, and a small footer signature. No images — the emails carry
    no visual brand asset, only typography.
    """
    safe_label = _html.escape(accent_label.upper())
    safe_headline = _html.escape(headline)
    return f"""\
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{safe_headline}</title>
</head>
<body style="margin:0;padding:0;background:{_PAPER};color:{_INK};font-family:{_FONT_SERIF};">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0"
         style="background:{_PAPER};padding:40px 16px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0"
               style="max-width:520px;background:{_PAPER};">
          <tr>
            <td style="padding:0 0 18px 0;border-top:1px solid {_INK};border-bottom:0.5px solid {_RULE};
                       text-align:center;">
              <div style="font-family:{_FONT_MONO};font-size:11px;letter-spacing:2px;text-transform:uppercase;
                          color:{_ACCENT};padding:14px 0;">
                · {safe_label} ·
              </div>
            </td>
          </tr>
          <tr>
            <td style="padding:28px 4px 8px 4px;">
              <h1 style="margin:0;font-family:{_FONT_SERIF};font-size:30px;line-height:1.1;font-weight:500;
                          letter-spacing:-0.6px;color:{_INK};text-align:center;">
                {safe_headline}
              </h1>
            </td>
          </tr>
          <tr>
            <td style="padding:18px 4px 28px 4px;color:{_INK_SOFT};font-size:16px;line-height:1.55;">
              {body_html}
            </td>
          </tr>
          <tr>
            <td style="padding:20px 0 0 0;border-top:0.5px solid {_RULE};
                       font-family:{_FONT_MONO};font-size:10.5px;letter-spacing:1.5px;text-transform:uppercase;
                       color:#8a857a;text-align:center;">
              Islam Aujourd'hui dans l'Histoire · news.majlisna.app
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
"""


def _button(label: str, href: str) -> str:
    safe_label = _html.escape(label)
    safe_href = _html.escape(href, quote=True)
    return (
        f'<a href="{safe_href}" '
        f'style="display:inline-block;background:{_INK};color:{_PAPER};'
        f"text-decoration:none;font-family:{_FONT_MONO};font-size:11.5px;"
        f"letter-spacing:1.8px;text-transform:uppercase;padding:14px 26px;"
        f'margin:18px 0;">{safe_label}</a>'
    )


# --- Password reset --------------------------------------------------------


def password_reset_email(*, reset_url: str, user_display_name: str | None) -> tuple[str, str, str]:
    """Build (subject, html, text) for the password reset email."""
    greeting = f"Bonjour {_html.escape(user_display_name)}," if user_display_name else "Bonjour,"
    body_html = (
        f'<p style="margin:0 0 14px 0;">{greeting}</p>'
        '<p style="margin:0 0 14px 0;">'
        "Vous avez demandé à réinitialiser le mot de passe de votre compte "
        "<em>Islamic On This Day</em>. Cliquez sur le bouton ci-dessous pour "
        "choisir un nouveau mot de passe :"
        "</p>"
        f'<p style="margin:0;text-align:center;">{_button("Réinitialiser mon mot de passe", reset_url)}</p>'
        '<p style="margin:18px 0 0 0;font-size:14px;color:#6e6a5e;font-style:italic;">'
        "Le lien est valable 30 minutes. Si vous n'êtes pas à l'origine de cette demande, "
        "ignorez ce message — votre mot de passe n'a pas été modifié."
        "</p>"
    )
    text = (
        f"{greeting}\n\n"
        "Vous avez demandé à réinitialiser le mot de passe de votre compte "
        "Islamic On This Day. Ouvrez ce lien dans votre navigateur :\n\n"
        f"{reset_url}\n\n"
        "Le lien est valable 30 minutes. Si vous n'êtes pas à l'origine de "
        "cette demande, ignorez ce message — votre mot de passe n'a pas été modifié.\n"
    )
    subject = "Réinitialisez votre mot de passe — Islamic On This Day"
    html = _shell(
        headline="Réinitialiser votre mot de passe",
        body_html=body_html,
        accent_label="Islamic On This Day",
    )
    return subject, html, text
