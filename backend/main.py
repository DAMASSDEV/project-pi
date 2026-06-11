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

class SignInRequest(BaseModel):
    email: EmailStr
    password: str

class SignInResponse(BaseModel):
    success: bool
    message: str
    token: str | None = None
    user: dict | None = None

@app.post("/api/auth/signin", response_model=SignInResponse)
async def sign_in(payload: SignInRequest):
    if payload.email == "you@example.com" and payload.password == "password123":
        return SignInResponse(
            success=True,
            message="Sign in successful",
            token="mock-jwt-token-12345",
            user={
                "email": payload.email,
                "name": "User Nutrify"
            }
        )
    raise HTTPException(status_code=401, detail="Invalid email or password")
