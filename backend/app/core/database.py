import socket
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy.exc import OperationalError
from app.core.config import DATABASE_URL

def get_engine():
    url = DATABASE_URL
    try:
        if "@postgres" in url:
            try:
                socket.gethostbyname("postgres")
            except socket.gaierror:
                url = url.replace("@postgres", "@localhost")
        
        engine = create_engine(url)
        conn = engine.connect()
        conn.close()
        return engine
    except OperationalError:
        try:
            fallback_url = DATABASE_URL.replace("@postgres", "@localhost")
            engine = create_engine(fallback_url)
            conn = engine.connect()
            conn.close()
            return engine
        except OperationalError:
            return create_engine("sqlite:///fallback.db")

engine = get_engine()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
