import uuid
from fastapi import APIRouter, Depends, Form, HTTPException
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.auth import (
    SignInRequest, SignInResponse,
    SignUpRequest, SignUpResponse,
    ForgotPasswordRequest, ForgotPasswordResponse
)
from app.models.user import User

router = APIRouter()

@router.post("/api/auth/signin", response_model=SignInResponse)
async def sign_in(payload: SignInRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or user.password != payload.password:
        raise HTTPException(status_code=401, detail="Email atau kata sandi salah.")
    
    if not user.is_verified:
        raise HTTPException(
            status_code=400, 
            detail="Email Anda belum diverifikasi. Silakan periksa log konsol backend untuk mengklik tautan verifikasi."
        )

    return SignInResponse(
        success=True,
        message="Sign in successful",
        token="mock-jwt-token-12345",
        user={
            "email": user.email,
            "name": user.name
        }
    )

@router.post("/api/auth/signup", response_model=SignUpResponse)
async def sign_up(payload: SignUpRequest, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == payload.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email sudah terdaftar.")

    token = str(uuid.uuid4())
    new_user = User(
        email=payload.email,
        name=payload.name,
        password=payload.password,
        is_verified=False,
        verification_token=token
    )
    db.add(new_user)
    db.commit()

    print("\n" + "="*80)
    print(f"VERIFICATION LINK: http://localhost:8000/verify-email?token={token}")
    print("="*80 + "\n")

    return SignUpResponse(
        success=True,
        message="Registrasi berhasil! Silakan verifikasi email Anda melalui tautan di konsol backend.",
        token="mock-jwt-token-67890",
        user={
            "email": payload.email,
            "name": payload.name
        }
    )

@router.get("/verify-email", response_class=HTMLResponse)
async def verify_email(token: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.verification_token == token).first()
    if not user:
        return """
        <html>
          <head>
            <title>Verifikasi Gagal</title>
            <style>
              body { font-family: sans-serif; text-align: center; padding-top: 100px; color: #EB5757; }
              .card { display: inline-block; padding: 40px; border-radius: 20px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); background: #FFF5F5; }
            </style>
          </head>
          <body>
            <div class="card">
              <h1>Tautan Verifikasi Tidak Valid</h1>
              <p>Tautan ini mungkin sudah kadaluarsa atau salah.</p>
            </div>
          </body>
        </html>
        """

    user.is_verified = True
    user.verification_token = None
    db.commit()

    return """
    <html>
      <head>
        <title>Email Terverifikasi</title>
        <style>
          body { font-family: sans-serif; text-align: center; padding-top: 100px; color: #108967; }
          .card { display: inline-block; padding: 40px; border-radius: 20px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); background: #F0FAF7; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>Email Berhasil Diverifikasi!</h1>
          <p>Silakan kembali ke aplikasi Nutrify untuk masuk ke akun Anda.</p>
        </div>
      </body>
    </html>
    """

@router.post("/api/auth/forgot-password", response_model=ForgotPasswordResponse)
async def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Email tidak terdaftar.")

    token = str(uuid.uuid4())
    user.reset_token = token
    db.commit()

    print("\n" + "="*80)
    print(f"PASSWORD RESET LINK: http://localhost:8000/reset-password-page?token={token}")
    print("="*80 + "\n")

    return ForgotPasswordResponse(
        success=True,
        message="Tautan pemulihan kata sandi telah dikirim ke log konsol backend."
    )

@router.get("/reset-password-page", response_class=HTMLResponse)
async def reset_password_page(token: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.reset_token == token).first()
    if not user:
        return """
        <html>
          <head>
            <title>Reset Gagal</title>
            <style>
              body { font-family: sans-serif; text-align: center; padding-top: 100px; color: #EB5757; }
              .card { display: inline-block; padding: 40px; border-radius: 20px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); background: #FFF5F5; }
            </style>
          </head>
          <body>
            <div class="card">
              <h1>Tautan Reset Tidak Valid</h1>
              <p>Tautan ini mungkin sudah digunakan atau salah.</p>
            </div>
          </body>
        </html>
        """

    return f"""
    <html>
      <head>
        <title>Reset Kata Sandi</title>
        <style>
          body {{ font-family: sans-serif; text-align: center; padding-top: 50px; background-color: #f8f9fa; }}
          .card {{ display: inline-block; padding: 40px; border-radius: 20px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); background: white; text-align: left; width: 320px; }}
          .btn {{ background: #108967; color: white; border: none; padding: 12px 20px; border-radius: 8px; font-weight: bold; cursor: pointer; width: 100%; margin-top: 20px; }}
          input {{ width: 100%; padding: 10px; margin-top: 8px; border: 1px solid #ccc; border-radius: 8px; box-sizing: border-box; }}
        </style>
      </head>
      <body>
        <div class="card">
          <h2 style="color: #108967;">Reset Kata Sandi</h2>
          <form action="/api/auth/reset-password-submit" method="post">
            <input type="hidden" name="token" value="{token}" />
            <label>Kata Sandi Baru</label>
            <input type="password" name="password" required placeholder="Masukkan kata sandi baru" />
            <button type="submit" class="btn">Simpan Sandi Baru</button>
          </form>
        </div>
      </body>
    </html>
    """

@router.post("/api/auth/reset-password-submit", response_class=HTMLResponse)
async def reset_password_submit(token: str = Form(...), password: str = Form(...), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.reset_token == token).first()
    if not user:
        return """
        <html>
          <head>
            <title>Reset Gagal</title>
            <style>
              body { font-family: sans-serif; text-align: center; padding-top: 100px; color: #EB5757; }
              .card { display: inline-block; padding: 40px; border-radius: 20px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); background: #FFF5F5; }
            </style>
          </head>
          <body>
            <div class="card">
              <h1>Tautan Reset Tidak Valid</h1>
              <p>Gagal menyetel ulang kata sandi baru.</p>
            </div>
          </body>
        </html>
        """

    user.password = password
    user.reset_token = None
    db.commit()

    return """
    <html>
      <head>
        <title>Reset Sukses</title>
        <style>
          body { font-family: sans-serif; text-align: center; padding-top: 100px; color: #108967; }
          .card { display: inline-block; padding: 40px; border-radius: 20px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); background: #F0FAF7; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>Reset Kata Sandi Berhasil!</h1>
          <p>Silakan masuk kembali menggunakan kata sandi baru Anda di aplikasi Nutrify.</p>
        </div>
      </body>
    </html>
    """
