from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.personalization import PersonalizationRequest, PersonalizationResponse
from app.models.personalization import Personalization

router = APIRouter()

@router.post("/api/personalization", response_model=PersonalizationResponse)
async def save_personalization(payload: PersonalizationRequest, db: Session = Depends(get_db)):
    db_personal = db.query(Personalization).filter(Personalization.email == payload.email).first()
    if db_personal:
        db_personal.name = payload.name
        db_personal.dob = payload.dob
        db_personal.gender = payload.gender
        db_personal.height = payload.height
        db_personal.weight = payload.weight
        db_personal.activity = payload.activity
        db_personal.conditions = payload.conditions
        db_personal.other_conditions = payload.other_conditions
        db_personal.allergies = payload.allergies
        db_personal.restrictions = payload.restrictions
        db_personal.goal = payload.goal
        db_personal.preferences = payload.preferences
        db_personal.notes = payload.notes
    else:
        db_personal = Personalization(
            email=payload.email,
            name=payload.name,
            dob=payload.dob,
            gender=payload.gender,
            height=payload.height,
            weight=payload.weight,
            activity=payload.activity,
            conditions=payload.conditions,
            other_conditions=payload.other_conditions,
            allergies=payload.allergies,
            restrictions=payload.restrictions,
            goal=payload.goal,
            preferences=payload.preferences,
            notes=payload.notes
        )
        db.add(db_personal)
    
    db.commit()
    return PersonalizationResponse(
        success=True,
        message="Data personalisasi berhasil disimpan."
    )
