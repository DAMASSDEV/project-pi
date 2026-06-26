from fastapi import APIRouter
from app.schemas.chat import ChatRequest, ChatResponse
from app.services.chat_service import ChatService

router = APIRouter()

@router.post("/api/chat", response_model=ChatResponse)
async def send_chat_message(payload: ChatRequest):
    reply = ChatService.get_bot_response(payload.message)
    return ChatResponse(success=True, message=reply)
