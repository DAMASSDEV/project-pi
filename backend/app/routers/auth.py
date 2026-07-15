import secrets
import logging
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Form
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import PUBLIC_BASE_URL
from app.core.security import (
    hash_password,
    verify_password,
    is_password_hashed,
    create_access_token,
)
from app.schemas.auth import (
    SignInRequest, SignInResponse,
    SignUpRequest, SignUpResponse,
    ForgotPasswordRequest, ForgotPasswordResponse,
)
from app.models.user import User
from app.models.personalization import Personalization
from app.models.password_reset import PasswordResetToken
from app.services.email_service import EmailService

router = APIRouter()
logger = logging.getLogger(__name__)

RESET_TOKEN_EXPIRE_MINUTES = 30
RESET_REQUEST_COOLDOWN_SECONDS = 60

def _render_reset_page(token: str, error: str | None = None, show_form: bool = True) -> str:
    error_html = f'<p class="error">{error}</p>' if error else ""
    form_html = ""
    if show_form:
        form_html = f"""
<form method="post" action="/reset-password">
  <input type="hidden" name="token" value="{token}">
  <label for="password">Kata Sandi Baru</label>
  <input type="password" id="password" name="password" minlength="6" required>
  <label for="confirm_password">Konfirmasi Kata Sandi</label>
  <input type="password" id="confirm_password" name="confirm_password" minlength="6" required>
  <button type="submit">Simpan Kata Sandi</button>
</form>
"""
    return f"""<!doctype html>
<html lang="id">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Atur Ulang Kata Sandi - Nutrify</title>
<style>
body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f5fbf9; margin: 0; padding: 0; display: flex; min-height: 100vh; align-items: center; justify-content: center; }}
.card {{ background: #ffffff; border-radius: 20px; padding: 40px 32px; max-width: 400px; width: 90%; box-shadow: 0 12px 32px rgba(16,137,103,0.08); box-sizing: border-box; }}
h1 {{ color: #108967; font-size: 22px; margin: 0 0 8px; }}
p {{ color: #4a4a4a; font-size: 14px; line-height: 1.6; }}
label {{ display: block; font-size: 13px; font-weight: 600; color: #333; margin: 20px 0 6px; }}
input {{ width: 100%; box-sizing: border-box; padding: 12px 14px; border: 1px solid #dcdcdc; border-radius: 10px; font-size: 14px; }}
button {{ width: 100%; margin-top: 28px; padding: 14px; background: #108967; color: #ffffff; border: none; border-radius: 10px; font-size: 15px; font-weight: 700; cursor: pointer; }}
.error {{ color: #d32f2f; background: #fdecea; padding: 10px 14px; border-radius: 8px; font-size: 13px; }}
</style>
</head>
<body>
<div class="card">
<h1>Atur Ulang Kata Sandi</h1>
<p>Masukkan kata sandi baru untuk akun Nutrify Anda.</p>
{error_html}
{form_html}
</div>
</body>
</html>
"""

def _render_reset_success_page() -> str:
    return """<!doctype html>
<html lang="id">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Berhasil - Nutrify</title>
<style>
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f5fbf9; margin: 0; padding: 0; display: flex; min-height: 100vh; align-items: center; justify-content: center; }
.card { background: #ffffff; border-radius: 20px; padding: 40px 32px; max-width: 400px; width: 90%; text-align: center; box-shadow: 0 12px 32px rgba(16,137,103,0.08); box-sizing: border-box; }
h1 { color: #108967; font-size: 22px; margin: 0 0 8px; }
p { color: #4a4a4a; font-size: 14px; line-height: 1.6; }
</style>
</head>
<body>
<div class="card">
<h1>Kata Sandi Berhasil Diubah</h1>
<p>Silakan kembali ke aplikasi Nutrify dan masuk menggunakan kata sandi baru Anda.</p>
</div>
</body>
</html>
"""

@router.post("/api/auth/signin", response_model=SignInResponse)
async def sign_in(payload: SignInRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Email atau kata sandi salah.")

    # Verify password (supports both bcrypt and legacy plain text)
    if is_password_hashed(user.password):
        if not verify_password(payload.password, user.password):
            raise HTTPException(status_code=401, detail="Email atau kata sandi salah.")
    else:
        # Legacy plain text password — verify then auto-migrate to bcrypt
        if user.password != payload.password:
            raise HTTPException(status_code=401, detail="Email atau kata sandi salah.")
        user.password = hash_password(payload.password)
        db.commit()

    personalization_exists = db.query(Personalization).filter(Personalization.email == user.email).first() is not None

    token = create_access_token(data={"sub": user.email, "name": user.name})

    return SignInResponse(
        success=True,
        message="Sign in successful",
        token=token,
        user={
            "email": user.email,
            "name": user.name,
            "has_completed_personalization": personalization_exists
        }
    )

@router.post("/api/auth/signup", response_model=SignUpResponse)
async def sign_up(payload: SignUpRequest, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == payload.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email sudah terdaftar.")

    new_user = User(
        email=payload.email,
        name=payload.name,
        password=hash_password(payload.password)
    )
    db.add(new_user)
    db.commit()

    token = create_access_token(data={"sub": payload.email, "name": payload.name})

    return SignUpResponse(
        success=True,
        message="Registrasi berhasil! Silakan masuk.",
        token=token,
        user={
            "email": payload.email,
            "name": payload.name
        }
    )

@router.post("/api/auth/forgot-password", response_model=ForgotPasswordResponse)
async def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Email tidak ditemukan.")

    cooldown_cutoff = datetime.utcnow() - timedelta(seconds=RESET_REQUEST_COOLDOWN_SECONDS)
    recent_request = db.query(PasswordResetToken).filter(
        PasswordResetToken.email == user.email,
        PasswordResetToken.created_at > cooldown_cutoff,
    ).first()
    if recent_request:
        raise HTTPException(status_code=429, detail="Tunggu beberapa saat sebelum meminta tautan pemulihan lagi.")

    token = secrets.token_urlsafe(32)
    db.add(PasswordResetToken(
        token=token,
        email=user.email,
        created_at=datetime.utcnow(),
        expires_at=datetime.utcnow() + timedelta(minutes=RESET_TOKEN_EXPIRE_MINUTES),
        used=False,
    ))
    db.commit()

    reset_link = f"{PUBLIC_BASE_URL}/reset-password?token={token}"
    try:
        EmailService.send_password_reset_email(user.email, reset_link)
    except Exception as e:
        logger.debug(f"Gagal mengirim email pemulihan ke {user.email}: {e}")

    return ForgotPasswordResponse(
        success=True,
        message="Tautan pemulihan kata sandi telah dikirim ke email Anda."
    )

@router.get("/reset-password", response_class=HTMLResponse)
async def reset_password_form(token: str, db: Session = Depends(get_db)):
    reset_token = db.query(PasswordResetToken).filter(PasswordResetToken.token == token).first()
    if not reset_token or reset_token.used or reset_token.expires_at < datetime.utcnow():
        return HTMLResponse(_render_reset_page(token, error="Tautan sudah tidak berlaku. Silakan minta tautan baru dari aplikasi.", show_form=False))

    return HTMLResponse(_render_reset_page(token))

@router.post("/reset-password", response_class=HTMLResponse)
async def reset_password_submit(
    token: str = Form(...),
    password: str = Form(...),
    confirm_password: str = Form(...),
    db: Session = Depends(get_db),
):
    reset_token = db.query(PasswordResetToken).filter(PasswordResetToken.token == token).first()
    if not reset_token or reset_token.used or reset_token.expires_at < datetime.utcnow():
        return HTMLResponse(_render_reset_page(token, error="Tautan sudah tidak berlaku. Silakan minta tautan baru dari aplikasi.", show_form=False))

    if password != confirm_password:
        return HTMLResponse(_render_reset_page(token, error="Konfirmasi kata sandi tidak cocok."))

    if len(password) < 6:
        return HTMLResponse(_render_reset_page(token, error="Kata sandi minimal 6 karakter."))

    user = db.query(User).filter(User.email == reset_token.email).first()
    user.password = hash_password(password)
    reset_token.used = True
    db.commit()

    return HTMLResponse(_render_reset_success_page())

