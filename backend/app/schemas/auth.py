from pydantic import BaseModel, EmailStr

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

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ForgotPasswordResponse(BaseModel):
    success: bool
    message: str

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    password: str

class ResetPasswordResponse(BaseModel):
    success: bool
    message: str

