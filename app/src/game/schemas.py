import json
from typing import Dict
from fastapi import WebSocket
from pydantic import BaseModel

class Room:
    def __init__(self, room_id: str, host_id: str, room_max: int):
        self.room_id = room_id
        self.host_id = host_id
        self.room_max = room_max
        self.participants: Dict[str, int] = {} # 참여자 리스트 -> 딕셔너리 (개인 점수 계산용)
        self.host_websocket: WebSocket = None # 웹소켓

rooms: Dict[str, Room] = {}

# 호스트가 방 생성할 때 쓰는 객체 
class CreateRoomRequest(BaseModel):
    host_id: str
    cproblem_id: int
    room_max: int

# 참여자가 방 참가할 때 쓰는 객체
class JoinRoomRequest(BaseModel):
    room_id: str
    participant_id: str

class GetStudentScoreRequest(BaseModel):
    room_id: str

class ParticipantSolveRequest(BaseModel):
    room_id: str
    participant_id: str
    pnum: int # 0~9
# ?
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {} # 활성화된 연결 딕셔너리

    async def connect(self, room_id: str, client_id: str, websocket: WebSocket):
        await websocket.accept()
        if room_id not in self.active_connections:
            self.active_connections[room_id] = {}
        self.active_connections[room_id][client_id] = websocket

    def disconnect(self, room_id: str, client_id: str):
        self.active_connections[room_id].pop(client_id, None)

    async def send_personal_message(self, message: str, websocket: WebSocket): # 
        await websocket.send_text(json.dumps(message))