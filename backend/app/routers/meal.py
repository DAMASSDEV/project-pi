from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.meal import MealLog
from app.schemas.meal import MealLogCreate, MealLogResponse, ScanResponse

router = APIRouter()

@router.post("/api/meals/scan", response_model=ScanResponse)
async def scan_meal(payload: dict):
    food_name = payload.get("food_name", "").strip()
    name_lower = food_name.lower()
    
    if "soto" in name_lower or "kuning" in name_lower:
        return ScanResponse(
            success=True,
            food_name="Soto Kuning Bogor",
            calories=380.0,
            protein=22.0,
            carbs=15.0,
            fat=25.0,
            health_score=75,
            components="Daging Sapi, Kuah Santan, Soun, Telur Rebus, Seledri",
            description="Soto Kuning khas Bogor yang gurih dengan protein hewani tinggi. Kandungan lemak jenuh dari kuah santan cukup tinggi, disarankan batasi kuahnya.",
            image_path="assets/image3.png"
        )
    elif "asinan" in name_lower:
        return ScanResponse(
            success=True,
            food_name="Asinan Bogor",
            calories=150.0,
            protein=3.0,
            carbs=32.0,
            fat=2.0,
            health_score=92,
            components="Tahu, Nanas, Bengkuang, Kedondong, Kacang Tanah, Kuah Cuka Cabai",
            description="Hidangan asinan segar rendah lemak and kaya serat. Vitamin C tinggi dari buah-buahan segar membantu meningkatkan metabolisme tubuh.",
            image_path="assets/image2.png"
        )
    elif "nasi" in name_lower or "goreng" in name_lower:
        return ScanResponse(
            success=True,
            food_name="Nasi Goreng Spesial",
            calories=510.0,
            protein=14.0,
            carbs=72.0,
            fat=18.0,
            health_score=62,
            components="Nasi Putih, Telur Dada, Ayam Suwir, Minyak Goreng, Sayuran Pelengkap",
            description="Nasi goreng dengan karbohidrat tinggi untuk energi instan. Kurangi penggunaan minyak berlebih untuk menjaga kesehatan jantung.",
            image_path="assets/image1.png"
        )
    elif "salad" in name_lower or "chicken" in name_lower:
        return ScanResponse(
            success=True,
            food_name="Chicken Salad Bowl",
            calories=320.0,
            protein=28.0,
            carbs=12.0,
            fat=16.0,
            health_score=96,
            components="Dada Ayam Panggang, Selada Hijau, Tomat Ceri, Alpukat, Dressing Minyak Zaitun",
            description="Makanan padat gizi yang sangat tinggi protein untuk mendukung pembentukan otot dan lemak sehat untuk kesehatan otak.",
            image_path="assets/image2.png"
        )
    else:
        display_name = food_name if food_name else "Menu Makanan Kustom"
        return ScanResponse(
            success=True,
            food_name=display_name,
            calories=260.0,
            protein=12.0,
            carbs=30.0,
            fat=10.0,
            health_score=80,
            components="Bahan Makanan Segar, Bumbu Dasar Seimbang",
            description="Makanan dengan profil gizi yang seimbang. Pilihan yang baik untuk memenuhi kebutuhan makronutrisi harian Anda.",
            image_path="assets/image3.png"
        )

@router.post("/api/meals", response_model=MealLogResponse)
async def save_meal(payload: MealLogCreate, db: Session = Depends(get_db)):
    db_meal = MealLog(
        email=payload.email,
        food_name=payload.food_name,
        calories=payload.calories,
        protein=payload.protein,
        carbs=payload.carbs,
        fat=payload.fat,
        health_score=payload.health_score,
        components=payload.components,
        timestamp=payload.timestamp,
        image_path=payload.image_path,
        is_manual=payload.is_manual
    )
    db.add(db_meal)
    db.commit()
    db.refresh(db_meal)
    return db_meal

@router.get("/api/meals", response_model=List[MealLogResponse])
async def get_meals(email: str = Query(...), db: Session = Depends(get_db)):
    meals = db.query(MealLog).filter(MealLog.email == email).order_by(MealLog.id.desc()).all()
    return meals

@router.delete("/api/meals/{meal_id}")
async def delete_meal(meal_id: int, db: Session = Depends(get_db)):
    db_meal = db.query(MealLog).filter(MealLog.id == meal_id).first()
    if not db_meal:
        raise HTTPException(status_code=404, detail="Meal log not found")
    db.delete(db_meal)
    db.commit()
    return {"success": True, "message": "Catatan makanan berhasil dihapus."}

@router.put("/api/meals/{meal_id}")
async def update_meal(meal_id: int, payload: dict, db: Session = Depends(get_db)):
    db_meal = db.query(MealLog).filter(MealLog.id == meal_id).first()
    if not db_meal:
        raise HTTPException(status_code=404, detail="Meal log not found")
    
    if "food_name" in payload:
        db_meal.food_name = payload["food_name"]
    if "calories" in payload:
        db_meal.calories = payload["calories"]
    if "protein" in payload:
        db_meal.protein = payload["protein"]
    if "carbs" in payload:
        db_meal.carbs = payload["carbs"]
    if "fat" in payload:
        db_meal.fat = payload["fat"]
    if "components" in payload:
        db_meal.components = payload["components"]
        
    db.commit()
    db.refresh(db_meal)
    return {"success": True, "meal": {
        "id": db_meal.id,
        "email": db_meal.email,
        "food_name": db_meal.food_name,
        "calories": db_meal.calories,
        "protein": db_meal.protein,
        "carbs": db_meal.carbs,
        "fat": db_meal.fat,
        "components": db_meal.components,
        "timestamp": db_meal.timestamp,
        "image_path": db_meal.image_path,
        "is_manual": db_meal.is_manual
    }}
