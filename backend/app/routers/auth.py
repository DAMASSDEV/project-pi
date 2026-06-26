from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.auth import (
    SignInRequest, SignInResponse,
    SignUpRequest, SignUpResponse,
    ForgotPasswordRequest, ForgotPasswordResponse
)
from app.models.user import User
from app.models.personalization import Personalization

router = APIRouter()

@router.post("/api/auth/signin", response_model=SignInResponse)
async def sign_in(payload: SignInRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or user.password != payload.password:
        raise HTTPException(status_code=401, detail="Email atau kata sandi salah.")
    
    personalization_exists = db.query(Personalization).filter(Personalization.email == user.email).first() is not None
    
    return SignInResponse(
        success=True,
        message="Sign in successful",
        token="mock-jwt-token-12345",
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
        password=payload.password
    )
    db.add(new_user)
    db.commit()

    return SignUpResponse(
        success=True,
        message="Registrasi berhasil! Silakan masuk.",
        token="mock-jwt-token-67890",
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
    
    return ForgotPasswordResponse(
        success=True,
        message="Tautan pemulihan kata sandi telah dikirim ke email Anda."
    )
