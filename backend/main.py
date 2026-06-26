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

class PersonalizationRequest(BaseModel):
    email: EmailStr
    name: str
    dob: str
    gender: str
    height: float
    weight: float
    activity: str
    conditions: list[str]
    other_conditions: str | None = None
    allergies: list[str]
    restrictions: list[str]
    goal: str
    preferences: list[str]
    notes: str | None = None

class PersonalizationResponse(BaseModel):
    success: bool
    message: str

@app.post("/api/personalization", response_model=PersonalizationResponse)
async def save_personalization(payload: PersonalizationRequest):
    if payload.email in users_db:
        users_db[payload.email]["personalization"] = payload.model_dump()
        return PersonalizationResponse(
            success=True,
            message="Data personalisasi berhasil disimpan."
        )
    users_db[payload.email] = {
        "email": payload.email,
        "name": payload.name,
        "password": "",
        "personalization": payload.model_dump()
    }
    return PersonalizationResponse(
        success=True,
        message="Data personalisasi berhasil disimpan."
    )


class ChatRequest(BaseModel):
    message: str


class ChatResponse(BaseModel):
    success: bool
    message: str


@app.post("/api/chat", response_model=ChatResponse)
async def send_chat_message(payload: ChatRequest):
    msg = payload.message.lower()
    if "asinan" in msg:
        reply = "Asinan Bogor memiliki estimasi sekitar 150 kkal per porsi. Hidangan segar ini kaya akan serat, Vitamin C, dan antioksidan karena terdiri dari buah-buahan dan sayuran segar dengan kuah asam pedas."
    elif "soto" in msg or "kuning" in msg:
        reply = "Soto Kuning Bogor memiliki estimasi sekitar 350-400 kkal per porsi. Kandungan utamanya adalah protein dan lemak dari kuah santan serta kaldu daging."
    elif "telur" in msg:
        reply = "Satu butir telur rebus mengandung sekitar 78 kkal, 6 gram protein berkualitas tinggi, serta vitamin D dan B12. Sangat baik untuk pemulihan otot."
    elif "makan" in msg or "ide" in msg or "saran" in msg:
        reply = "Ide makan sehat tinggi protein: Dada ayam panggang dengan tumis brokoli dan nasi merah. Total kalori sekitar 450 kkal dengan kandungan protein sekitar 40g."
    else:
        reply = "Halo! Saya adalah asisten gizi pintar Anda. Tanyakan kepada saya tentang estimasi kalori makanan khas Bogor (seperti Asinan atau Soto Kuning), rekomendasi gizi, atau tips diet Anda."

    return ChatResponse(success=True, message=reply)


@app.get("/health")
async def health_check():
    return {"status": "healthy"}





