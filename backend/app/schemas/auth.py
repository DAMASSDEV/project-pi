from pydantic import BaseModel

class SignInRequest(BaseModel):
    email: str
    password: str

class SignInResponse(BaseModel):
    success: bool
    message: str
    token: str | None = None
    user: dict | None = None

class SignUpRequest(BaseModel):
    name: str
    email: str
    password: str

class SignUpResponse(BaseModel):
    success: bool
    message: str
    token: str | None = None
    user: dict | None = None

class ForgotPasswordRequest(BaseModel):
    email: str

class ForgotPasswordResponse(BaseModel):
    success: bool
    message: str
