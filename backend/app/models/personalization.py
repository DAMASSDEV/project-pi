from sqlalchemy import Column, String, Float, ForeignKey, JSON
from app.core.database import Base

class Personalization(Base):
    __tablename__ = "personalizations"

    email = Column(String, ForeignKey("users.email"), primary_key=True)
    name = Column(String, nullable=False)
    dob = Column(String, nullable=False)
    gender = Column(String, nullable=False)
    height = Column(Float, nullable=False)
    weight = Column(Float, nullable=False)
    activity = Column(String, nullable=False)
    conditions = Column(JSON, nullable=False)
    other_conditions = Column(String, nullable=True)
    allergies = Column(JSON, nullable=False)
    restrictions = Column(JSON, nullable=False)
    goal = Column(String, nullable=False)
    preferences = Column(JSON, nullable=False)
    notes = Column(String, nullable=True)
