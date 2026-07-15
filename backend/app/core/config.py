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

SMTP_EMAIL = os.getenv("SMTP_EMAIL", "")
SMTP_APP_PASSWORD = os.getenv("SMTP_APP_PASSWORD", "")
PUBLIC_BASE_URL = os.getenv("PUBLIC_BASE_URL", "https://api-nutrify.damassdev.my.id")

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
