from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

users_db = {
    "you@example.com": {
        "email": "you@example.com",
        "password": "password123",
        "name": "User Nutrify"
    }
}

class SignInRequest(BaseModel):
    email: EmailStr
    password: str

class SignInResponse(BaseModel):
    success: bool
    message: str
    token: str | None = None
    user: dict | None = None

class SignUpRequest(BaseModel):
    name: str
    email: EmailStr
    password: str

class SignUpResponse(BaseModel):
    success: bool
    message: str
    token: str | None = None
    user: dict | None = None

@app.post("/api/auth/signin", response_model=SignInResponse)
async def sign_in(payload: SignInRequest):
    user = users_db.get(payload.email)
    if user and user["password"] == payload.password:
        return SignInResponse(
            success=True,
            message="Sign in successful",
            token="mock-jwt-token-12345",
            user={
                "email": user["email"],
                "name": user["name"]
            }
        )
    raise HTTPException(status_code=401, detail="Invalid email or password")

@app.post("/api/auth/signup", response_model=SignUpResponse)
async def sign_up(payload: SignUpRequest):
    if payload.email in users_db:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    users_db[payload.email] = {
        "email": payload.email,
        "password": payload.password,
        "name": payload.name
    }
    
    return SignUpResponse(
        success=True,
        message="Sign up successful",
        token="mock-jwt-token-67890",
        user={
            "email": payload.email,
            "name": payload.name
        }
    )

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ForgotPasswordResponse(BaseModel):
    success: bool
    message: str

@app.post("/api/auth/forgot-password", response_model=ForgotPasswordResponse)
async def forgot_password(payload: ForgotPasswordRequest):
    return ForgotPasswordResponse(
        success=True,
        message="Instruksi pemulihan kata sandi telah dikirim ke email Anda."
    )



