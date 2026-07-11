from sqlalchemy import Column, String, Float, Integer
from app.core.database import Base

class Food(Base):
    __tablename__ = "foods"

    food_name = Column(String, primary_key=True, index=True)
    serving_size_g = Column(Float, nullable=False)
    calories = Column(Float, nullable=False)
    protein = Column(Float, nullable=False)
    fat = Column(Float, nullable=False)
    carbohydrates = Column(Float, nullable=False)
    sugar = Column(Float, nullable=False)
    sodium = Column(Float, nullable=False)
    fiber = Column(Float, nullable=False)
    calories_from_macro = Column(Float, nullable=True)
    protein_per_calorie = Column(Float, nullable=True)
    fat_per_calorie = Column(Float, nullable=True)
    carbs_per_calorie = Column(Float, nullable=True)
    calorie_category = Column(String, nullable=True)
    is_high_protein = Column(Integer, nullable=True)
    is_high_fiber = Column(Integer, nullable=True)
    is_high_sodium = Column(Integer, nullable=True)
