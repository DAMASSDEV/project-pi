import os
import socket
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy.exc import OperationalError
from app.core.config import DATABASE_URL

def get_engine():
    url = DATABASE_URL
    try:
        # Try resolving 'postgres' if inside container, otherwise try 'localhost'
        if "@postgres" in url:
            try:
                socket.gethostbyname("postgres")
            except socket.gaierror:
                url = url.replace("@postgres", "@localhost")
        
        engine = create_engine(url)
        # Force a connection test to catch auth/network errors
        with engine.connect() as conn:
            pass
        print(f"Connected to database successfully: {url}")
        return engine
    except OperationalError as e:
        print(f"Failed to connect to primary database: {e}")
        # If we didn't try localhost yet and was container host, try localhost
        if "@postgres" in DATABASE_URL and "@localhost" not in url:
            try:
                fallback_url = DATABASE_URL.replace("@postgres", "@localhost")
                engine = create_engine(fallback_url)
                with engine.connect() as conn:
                    pass
                print(f"Connected to fallback database successfully: {fallback_url}")
                return engine
            except OperationalError:
                pass
        
        # SQLite local fallback
        current_dir = os.path.dirname(os.path.abspath(__file__))
        backend_dir = os.path.abspath(os.path.join(current_dir, "..", ".."))
        sqlite_path = os.path.join(backend_dir, "local_nutrify.db")
        sqlite_url = f"sqlite:///{sqlite_path}"
        print(f"Falling back to SQLite database at: {sqlite_path}")
        return create_engine(sqlite_url, connect_args={"check_same_thread": False})

engine = get_engine()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

