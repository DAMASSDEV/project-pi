import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://damassdev:Danarmas!12345@postgres:5432/maindb"
)
