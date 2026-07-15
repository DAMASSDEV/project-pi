import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from app.core.config import SMTP_EMAIL, SMTP_APP_PASSWORD

class EmailService:
    @staticmethod
    def send_password_reset_email(to_email: str, reset_link: str):
        message = MIMEMultipart("alternative")
        message["Subject"] = "Pemulihan Kata Sandi Nutrify"
        message["From"] = SMTP_EMAIL
        message["To"] = to_email

        html_body = f"""
<div style="font-family: -apple-system, Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px; color: #1a1a1a;">
  <h2 style="color: #108967; margin: 0 0 16px;">Pemulihan Kata Sandi</h2>
  <p style="font-size: 14px; line-height: 1.6;">Kami menerima permintaan untuk mengatur ulang kata sandi akun Nutrify Anda.</p>
  <p style="margin: 28px 0;">
    <a href="{reset_link}" style="display: inline-block; background-color: #108967; color: #ffffff; padding: 14px 28px; border-radius: 10px; text-decoration: none; font-weight: bold; font-size: 14px;">
      Atur Ulang Kata Sandi
    </a>
  </p>
  <p style="font-size: 13px; color: #666; line-height: 1.6;">Tautan ini berlaku selama 30 menit. Jika Anda tidak meminta pemulihan kata sandi, abaikan email ini.</p>
</div>
"""
        message.attach(MIMEText(html_body, "html"))

        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(SMTP_EMAIL, SMTP_APP_PASSWORD)
            server.sendmail(SMTP_EMAIL, to_email, message.as_string())
