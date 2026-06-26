from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import engine, Base
from app.routers.auth import router as auth_router
from app.routers.chat import router as chat_router
from app.routers.personalization import router as personalization_router
from app.routers.health import router as health_router
import app.models

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)

app.include_router(auth_router)
app.include_router(chat_router)
app.include_router(personalization_router)
app.include_router(health_router)
