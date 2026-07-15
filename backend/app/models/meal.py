from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey
from app.core.database import Base

class MealLog(Base):
    __tablename__ = "meal_logs"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    email = Column(String, ForeignKey("users.email"), nullable=False)
    food_name = Column(String, nullable=False)
    calories = Column(Float, nullable=False)
    protein = Column(Float, nullable=False)
    carbs = Column(Float, nullable=False)
    fat = Column(Float, nullable=False)
    health_score = Column(Integer, nullable=False)
    components = Column(String, nullable=False)
    timestamp = Column(String, nullable=False)
    image_path = Column(String, nullable=False)
    is_manual = Column(Boolean, default=False)
    portion = Column(Float, nullable=False, default=1.0)
