from pydantic import BaseModel

class PersonalizationRequest(BaseModel):
    email: str
    name: str
    dob: str
    gender: str
    height: float
    weight: float
    activity: str
    conditions: list[str]
    other_conditions: str | None = None
    allergies: list[str]
    restrictions: list[str]
    goal: str
    preferences: list[str]
    notes: str | None = None

class PersonalizationResponse(BaseModel):
    success: bool
    message: str
