import os
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.core.config import LOG_LEVEL
from app.core.database import engine, Base
from app.routers.auth import router as auth_router
from app.routers.chat import router as chat_router
from app.routers.personalization import router as personalization_router
from app.routers.health import router as health_router
from app.routers.meal import router as meal_router
import app.models

logging.basicConfig(
    level=getattr(logging, LOG_LEVEL.upper(), logging.INFO),
    format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "..", "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

import csv
import time
from sqlalchemy.exc import OperationalError
from app.core.database import SessionLocal
from app.models.food import Food

def populate_foods():
    db = SessionLocal()
    try:
        if db.query(Food).first() is not None:
            print("Database foods already populated.")
            return

        csv_path = "../ai-model/clean_dataset.csv"
        if not os.path.exists(csv_path):
            print(f"CSV file not found at {csv_path}")
            return

        print("Populating foods database from CSV...")
        with open(csv_path, mode='r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            foods_to_insert = []
            seen_names = set()
            for row in reader:
                name = row['food_name'].strip()
                name_key = name.lower()
                if name_key in seen_names:
                    continue
                seen_names.add(name_key)
                food = Food(
                    food_name=name,
                    serving_size_g=float(row['serving_size_g'] or 0.0),
                    calories=float(row['calories'] or 0.0),
                    protein=float(row['protein'] or 0.0),
                    fat=float(row['fat'] or 0.0),
                    carbohydrates=float(row['carbohydrates'] or 0.0),
                    sugar=float(row['sugar'] or 0.0),
                    sodium=float(row['sodium'] or 0.0),
                    fiber=float(row['fiber'] or 0.0),
                    calories_from_macro=float(row['calories_from_macro'] or 0.0) if row.get('calories_from_macro') else None,
                    protein_per_calorie=float(row['protein_per_calorie'] or 0.0) if row.get('protein_per_calorie') else None,
                    fat_per_calorie=float(row['fat_per_calorie'] or 0.0) if row.get('fat_per_calorie') else None,
                    carbs_per_calorie=float(row['carbs_per_calorie'] or 0.0) if row.get('carbs_per_calorie') else None,
                    calorie_category=row.get('calorie_category', ''),
                    is_high_protein=int(row['is_high_protein'] or 0) if row.get('is_high_protein') else 0,
                    is_high_fiber=int(row['is_high_fiber'] or 0) if row.get('is_high_fiber') else 0,
                    is_high_sodium=int(row['is_high_sodium'] or 0) if row.get('is_high_sodium') else 0
                )
                foods_to_insert.append(food)
            
            db.bulk_save_objects(foods_to_insert)
            db.commit()
            print(f"Successfully populated {len(foods_to_insert)} foods.")
    except Exception as e:
        print(f"Error populating foods database: {e}")
        db.rollback()
    finally:
        db.close()

def migrate_meal_logs_portion_column():
    from sqlalchemy import text
    try:
        with engine.connect() as conn:
            conn.execute(text("ALTER TABLE meal_logs ADD COLUMN portion FLOAT DEFAULT 1.0"))
            conn.commit()
            print("Migration: added 'portion' column to meal_logs.")
    except Exception:
        pass

def migrate_password_reset_created_at_column():
    from sqlalchemy import text
    try:
        with engine.connect() as conn:
            conn.execute(text("ALTER TABLE password_reset_tokens ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"))
            conn.commit()
            print("Migration: added 'created_at' column to password_reset_tokens.")
    except Exception:
        pass

@app.on_event("startup")
def on_startup():
    retries = 10
    while retries > 0:
        try:
            Base.metadata.create_all(bind=engine)
            print("Successfully connected to the database and created tables.")
            migrate_meal_logs_portion_column()
            migrate_password_reset_created_at_column()
            populate_foods()
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
