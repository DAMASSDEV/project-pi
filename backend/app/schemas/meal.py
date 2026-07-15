from pydantic import BaseModel

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
    portion: float = 1.0

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
    portion: float

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
    is_bogor_food: bool = True
    alert_message: str = ""
