from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey
from app.core.database import Base
from datetime import datetime

class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    token = Column(String, primary_key=True, index=True)
    email = Column(String, ForeignKey("users.email"), nullable=False)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    expires_at = Column(DateTime, nullable=False)
    used = Column(Boolean, default=False, nullable=False)
