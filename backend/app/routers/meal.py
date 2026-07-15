from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.meal import MealLog
from app.models.food import Food
from app.schemas.meal import MealLogCreate, MealLogResponse, ScanResponse

router = APIRouter()

@router.get("/api/foods/search")
async def search_foods(q: str = Query(...), db: Session = Depends(get_db)):
    query = q.strip()
    if len(query) < 2:
        return {"success": True, "results": []}

    matches = db.query(Food).filter(Food.food_name.ilike(f"%{query}%")).limit(10).all()
    results = [
        {
            "food_name": food.food_name,
            "serving_size_g": food.serving_size_g,
            "calories": food.calories,
            "protein": food.protein,
            "carbs": food.carbohydrates,
            "fat": food.fat,
        }
        for food in matches
    ]
    return {"success": True, "results": results}

@router.post("/api/meals/scan", response_model=ScanResponse)
async def scan_meal(payload: dict, db: Session = Depends(get_db)):
    food_name = payload.get("food_name", "").strip()
    if not food_name:
        raise HTTPException(status_code=400, detail="Food name is required")

    name_lower = food_name.lower()
    
    # Try exact match first, then substring search
    db_food = db.query(Food).filter(Food.food_name.ilike(food_name)).first()
    if not db_food:
        db_food = db.query(Food).filter(Food.food_name.ilike(f"%{food_name}%")).first()

    # If not found, try word-by-word search
    if not db_food:
        words = name_lower.split()
        for word in words:
            if len(word) > 2:
                db_food = db.query(Food).filter(Food.food_name.ilike(f"%{word}%")).first()
                if db_food:
                    break

    # If still not found, fallback
    if not db_food:
        display_name = food_name.title()
        calories = 250.0
        protein = 10.0
        carbs = 30.0
        fat = 8.0
        health_score = 75
        components = "Bahan Segar Pilihan"
        description = "Makanan kustom dengan profil gizi standar seimbang."
        image_path = "assets/image3.png"
    else:
        display_name = db_food.food_name.title()
        calories = db_food.calories
        protein = db_food.protein
        carbs = db_food.carbohydrates
        fat = db_food.fat
        
        # Calculate health score dynamically
        if db_food.calorie_category == 'rendah':
            base_score = 90
        elif db_food.calorie_category == 'sedang':
            base_score = 75
        else:
            base_score = 55
            
        if db_food.is_high_protein == 1:
            base_score += 5
        if db_food.is_high_fiber == 1:
            base_score += 5
        if db_food.is_high_sodium == 1:
            base_score -= 10
            
        health_score = min(max(base_score, 10), 100)
        
        # Build description
        desc_parts = [
            f"Kandungan gizi per porsi ({db_food.serving_size_g}g): Energi sebesar {calories} kkal, Protein {protein}g, Karbohidrat {carbs}g, dan Lemak {fat}g."
        ]
        
        if db_food.is_high_protein == 1:
            desc_parts.append("Makanan ini tergolong tinggi protein, yang sangat baik untuk pembentukan massa otot dan pemulihan tubuh.")
        if db_food.is_high_fiber == 1:
            desc_parts.append("Kandungan seratnya tinggi, baik untuk pencernaan sehat dan membantu kenyang lebih lama.")
        if db_food.is_high_sodium == 1:
            desc_parts.append("Perhatian: makanan ini mengandung natrium (garam) yang tinggi. Disarankan membatasi porsi konsumsi untuk menjaga kesehatan jantung.")
            
        # Add custom recommendations based on food type
        if "asinan" in name_lower:
            desc_parts.append("Asinan Bogor kaya akan serat dan vitamin dari sayuran/buah segar, sangat baik sebagai camilan sehat.")
            components = "Buah segar, sayur asin, kuah cuka merah, tahu, kacang tanah goreng"
            image_path = "assets/image2.png"
        elif "soto" in name_lower:
            desc_parts.append("Batasi konsumsi kuah santan soto untuk menjaga kestabilan kadar lemak jenuh harian Anda.")
            components = "Daging sapi/ayam, kuah santan kuning, bihun, emping, daun bawang"
            image_path = "assets/image3.png"
        elif "doclang" in name_lower:
            desc_parts.append("Doclang merupakan sumber karbohidrat dan protein yang padat. Kurangi porsi saus kacang berlebih untuk menghemat kalori.")
            components = "Ketupat, tahu goreng, kentang rebus, telur rebus, saus kacang, kecap manis"
            image_path = "assets/image1.png"
        elif "laksa" in name_lower:
            desc_parts.append("Laksa Bogor kaya protein dari oncom dan tahu, namun kuah bersantannya cukup pekat, konsumsilah dalam batas wajar.")
            components = "Ketupat, bihun, tauge, kemangi, oncom merah, kuah santan laksa"
            image_path = "assets/image2.png"
        elif "toge" in name_lower:
            desc_parts.append("Toge Goreng merupakan hidangan gurih kaya protein nabati dari tahu dan tauco. Pilihan yang lezat dan rendah lemak.")
            components = "Toge rebus, tahu kuning, ketupat, mie kuning, kuah tauco gurih"
            image_path = "assets/image1.png"
        elif "cungkring" in name_lower:
            desc_parts.append("Cungkring kaya protein hewani dari paru dan kikil sapi, namun cukup tinggi lemak, konsumsilah dalam porsi wajar.")
            components = "Ketupat, paru sapi, kikil sapi, bumbu kacang, kecap pedas"
            image_path = "assets/image1.png"
        else:
            components = "Bahan makanan olahan segar"
            image_path = "assets/image3.png"
        description = " ".join(desc_parts)

    return ScanResponse(
        success=True,
        food_name=display_name,
        calories=calories,
        protein=protein,
        carbs=carbs,
        fat=fat,
        health_score=health_score,
        components=components,
        description=description,
        image_path=image_path
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

import os
import shutil
import uuid
from app.core.config import PUBLIC_BASE_URL

UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "../../uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

MODEL_PATH = os.path.join(os.path.dirname(__file__), "../bogor_yolo_best.pt")
if not os.path.exists(MODEL_PATH):
    MODEL_PATH = os.path.join(os.path.dirname(__file__), "../../../ai-model/bogor_yolo_best.pt")
if not os.path.exists(MODEL_PATH):
    MODEL_PATH = os.path.join(os.path.dirname(__file__), "../../ai-model/bogor_yolo_best.pt")

import sys
import traceback

yolo_model = None
BOGOR_FOOD_CLASSES = ["Asinan Bogor", "Cungkring", "Doclang", "Laksa", "Toge Goreng"]
CONFIDENCE_THRESHOLD = 0.15

try:
    log_messages = []
    log_messages.append(f"MODEL_PATH: {MODEL_PATH}")
    log_messages.append(f"Exists: {os.path.exists(MODEL_PATH)}")
    
    if os.path.exists(MODEL_PATH):
        import torch
        torch.backends.mkldnn.enabled = False
        from ultralytics import YOLO
        yolo_model = YOLO(MODEL_PATH)
        log_messages.append(f"Model YOLO berhasil dimuat. Classes: {yolo_model.names}")
    else:
        log_messages.append("Model YOLO tidak ditemukan di path manapun.")
        
    log_content = "\n".join(log_messages)
    print(log_content, flush=True)
    with open("yolo_startup.log", "w") as f:
        f.write(log_content)
except Exception as e:
    err_msg = f"Gagal memuat model YOLO: {e}\n{traceback.format_exc()}"
    sys.stderr.write(err_msg + "\n")
    sys.stderr.flush()
    try:
        with open("yolo_startup.log", "w") as f:
            f.write(err_msg)
    except Exception:
        pass

@router.post("/api/meals/scan-image")
async def scan_meal_image(file: UploadFile = File(...), db: Session = Depends(get_db)):
    ext = os.path.splitext(file.filename or "")[1] or ".jpg"
    saved_filename = f"{uuid.uuid4().hex}{ext}"
    saved_path = os.path.join(UPLOAD_DIR, saved_filename)

    with open(saved_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    image_url = f"{PUBLIC_BASE_URL}/uploads/{saved_filename}"

    detected_name = None
    detected_confidence = 0.0
    portion_scale = 1.0

    print(f"DEBUG: Memulai pemindaian gambar. Status yolo_model: {yolo_model is not None}")
    if yolo_model is not None:
        try:
            results = yolo_model(saved_path, verbose=False)
            if results and len(results) > 0:
                boxes = results[0].boxes
                if boxes is not None and len(boxes) > 0:
                    print(f"DEBUG: Menemukan {len(boxes)} boxes.")
                    for idx, box in enumerate(boxes):
                        c = float(box.conf[0])
                        cid = int(box.cls[0])
                        nm = yolo_model.names[cid]
                        print(f"DEBUG: Box #{idx} -> Class: {nm} ({cid}), Conf: {c:.4f}")

                    best_box = max(boxes, key=lambda x: float(x.conf[0]))
                    conf = float(best_box.conf[0])
                    cls_id = int(best_box.cls[0])
                    detected_name = yolo_model.names[cls_id]
                    detected_confidence = conf
                    print(f"DEBUG: Box terbaik -> {detected_name} dengan Conf: {conf:.4f}")

                    try:
                        img_h, img_w = results[0].orig_shape
                        x1, y1, x2, y2 = [float(v) for v in best_box.xyxy[0]]
                        box_area = max(0.0, x2 - x1) * max(0.0, y2 - y1)
                        image_area = float(img_w * img_h)
                        area_ratio = box_area / image_area if image_area > 0 else 0.0
                        baseline_ratio = 0.35
                        portion_scale = area_ratio / baseline_ratio if baseline_ratio > 0 else 1.0
                        portion_scale = max(0.7, min(portion_scale, 1.5))
                        print(f"DEBUG: Area rasio bounding box: {area_ratio:.3f}, portion_scale: {portion_scale:.2f}")
                    except Exception as e:
                        print(f"DEBUG: Gagal menghitung portion_scale, pakai default 1.0: {e}")
                        portion_scale = 1.0

                    if conf < CONFIDENCE_THRESHOLD:
                        print(f"DEBUG: Conf {conf:.4f} di bawah threshold {CONFIDENCE_THRESHOLD}. Diabaikan.")
                        detected_name = None
                else:
                    print("DEBUG: Tidak ada boxes terdeteksi.")
        except Exception as e:
            print(f"DEBUG: Error saat prediksi YOLO: {e}")
    else:
        print("DEBUG: yolo_model bernilai None! Model gagal dimuat saat startup.")

    if detected_name is not None:
        scan_result = await scan_meal({"food_name": detected_name}, db)
        return ScanResponse(
            success=True,
            food_name=scan_result.food_name,
            calories=round(scan_result.calories * portion_scale, 1),
            protein=round(scan_result.protein * portion_scale, 1),
            carbs=round(scan_result.carbs * portion_scale, 1),
            fat=round(scan_result.fat * portion_scale, 1),
            health_score=scan_result.health_score,
            components=scan_result.components,
            description=scan_result.description,
            image_path=image_url,
            is_bogor_food=True,
            alert_message=""
        )
    else:
        return ScanResponse(
            success=True,
            food_name="Tidak Terdeteksi",
            calories=0.0,
            protein=0.0,
            carbs=0.0,
            fat=0.0,
            health_score=0,
            components="",
            description="",
            image_path=image_url,
            is_bogor_food=False,
            alert_message="Makanan ini tidak dikenali sebagai makanan khas Bogor."
        )

