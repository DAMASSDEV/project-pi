from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import engine, Base
from app.routers.auth import router as auth_router
from app.routers.chat import router as chat_router
from app.routers.personalization import router as personalization_router
from app.routers.health import router as health_router
from app.routers.meal import router as meal_router
import app.models

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

import time
from sqlalchemy.exc import OperationalError

@app.on_event("startup")
def on_startup():
    retries = 10
    while retries > 0:
        try:
            Base.metadata.create_all(bind=engine)
            print("Successfully connected to the database and created tables.")
            break
        except OperationalError as e:
            retries -= 1
            print(f"Database connection failed. Retrying in 3 seconds... ({retries} retries left)")
            time.sleep(3)
            if retries == 0:
                print("Failed to connect to the database after 10 attempts.")
                raise e

app.include_router(auth_router)
app.include_router(chat_router)
app.include_router(personalization_router)
app.include_router(health_router)
app.include_router(meal_router)
