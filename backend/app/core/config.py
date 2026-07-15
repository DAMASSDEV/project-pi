import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/maindb"
)

JWT_SECRET_KEY = os.getenv(
    "JWT_SECRET_KEY",
    "nutrify-default-secret-key-change-in-production"
)
JWT_ALGORITHM = "HS256"
JWT_EXPIRE_MINUTES = int(os.getenv("JWT_EXPIRE_MINUTES", "1440"))
