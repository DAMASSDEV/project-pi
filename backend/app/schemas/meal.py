from pydantic import BaseModel
from typing import Optional

class MealLogCreate(BaseModel):
    email: str
    food_name: str
    calories: float
    protein: float
    carbs: float
    fat: float
    health_score: int
    components: str
    timestamp: str
    image_path: str
    is_manual: bool = False

class MealLogResponse(BaseModel):
    id: int
    email: str
    food_name: str
    calories: float
    protein: float
    carbs: float
    fat: float
    health_score: int
    components: str
    timestamp: str
    image_path: str
    is_manual: bool

    class Config:
        from_attributes = True

class ScanResponse(BaseModel):
    success: bool
    food_name: str
    calories: float
    protein: float
    carbs: float
    fat: float
    health_score: int
    components: str
    description: str
    image_path: str
