import aioredis
from fastapi import Depends, Header, status, APIRouter
from typing import Annotated
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from datetime import timedelta
import sys, os
from sqlalchemy import select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users
from auth.schemas import CreateUser, Token, Message
from auth.utils import authenticate_user, decode_token, validate_token_payload
from auth.service import create_access_token, create_user_in_db, create_study_info
from auth.dependencies import db_dependency
from auth.exceptions import token_exception, get_user_exception, access_token_exception, refresh_token_exception, get_valid_user_exception, user_exception
from auth.constants import REFRESH_TOKEN_EXPIRE_DAYS, ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter(
    prefix="/auth",
    tags=["auth"],
    responses={401: {"user": "Not authorized"}}
)

oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/token")

async def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    payload = decode_token(token)
    if payload is None:
        raise access_token_exception()
    username, user_id, user_role = validate_token_payload(payload)
    return {'username' : username, 'id' : user_id, 'user_role': user_role}

# 회원가입
@router.post("/register", status_code=status.HTTP_200_OK, responses={409: {"model": Message}})
async def create_new_user(db: db_dependency, create_user: CreateUser):
    result = await db.execute(select(Users).filter(Users.username == create_user.username))
    existing_user = result.scalars().first()
    if existing_user:
        raise user_exception()
    user = await create_user_in_db(db, create_user)
    await create_study_info(db, user.id)
    return {'detail': '성공적으로 회원가입되었습니다.'}

# 로그인 
@router.post("/token", responses={401: {"model": Message}})
async def first_login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], db: db_dependency):
    user = await authenticate_user(form_data.username, form_data.password, db)    
    if not user:
        raise token_exception()

    redis_client = await aioredis.create_redis_pool('redis://localhost')
    # if existing_token and await get_valid_user(existing_token): 
    #     raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="이미 로그인한 유저가 있습니다.")

    access_token = create_access_token(user.username, user.id, user.role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    refresh_token = create_access_token(user.username, '', '', timedelta(minutes=REFRESH_TOKEN_EXPIRE_DAYS))
    await redis_client.set(f"{user.username}_refresh", refresh_token)
    await redis_client.set(f"{user.username}_access", access_token)

    redis_client.close()
    await redis_client.wait_closed()
    return {'access_token' : access_token, 'token_type' : 'bearer', 'role': user.role, 'refresh_token' : refresh_token}

# Access Token 유효성 검사 (동기 작업들이므로 async를 제거)
@router.post("/access", status_code=status.HTTP_200_OK, responses={401: {"model": Message}})
def login_for_access_token(access_token: Annotated[str, Depends(oauth2_bearer)]):
    payload = decode_token(access_token)
    if payload is None:
        raise access_token_exception()
    username, user_id, user_role = validate_token_payload(payload)
    return {'detail': 'Token Valid', 'role': user_role}

# Refresh Token 유효성 검사
@router.post("/refresh", responses={401: {"model": Message}})
async def refresh_access_token(db: db_dependency, refresh_token: str = Header(default=None)):
    payload = decode_token(refresh_token)
    if payload is None:
        raise refresh_token_exception()
    
    username = payload.get('sub')
    if username is None:
        raise get_user_exception()
    
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    stored_refresh_token = await redis_client.get(f"{username}_refresh")
    if stored_refresh_token is None or stored_refresh_token.decode('utf-8') != refresh_token:
        raise refresh_token_exception()

    result = await db.execute(select(Users).filter(Users.username == username))
    user = result.scalars().first()
    if user is None:
        raise get_user_exception()
    
    access_token = create_access_token(user.username, user.id, user.role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    new_refresh_token = create_access_token(user.username, '', '', timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))
    await redis_client.set(f"{user.username}_refresh", new_refresh_token)
    await redis_client.set(f"{user.username}_access", access_token)
    redis_client.close()
    await redis_client.wait_closed()
    return {'access_token': access_token, 'token_type': 'bearer', 'role': user.role, 'refresh_token': new_refresh_token}

# 로그아웃 (리프레시 토큰을 삭제는 했지만, 안에 담긴 정보 자체는 남아있음. )
@router.post("/logout", responses={401: {"model": Message}})
async def logout(refresh_token: str = Header(default=None)):
    # 리프레시 토큰이 유효하다. 
    payload = decode_token(refresh_token)
    if payload is None:
        raise refresh_token_exception()
    
    username = payload.get('sub')
    if username is None:
        raise get_user_exception()
    # 저장된 리프레시 토큰하고, 제출한 리프레시 토큰이 같다. (존재한다.)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    stored_refresh_token = await redis_client.get(f"{username}_refresh")
    if stored_refresh_token is None or stored_refresh_token.decode('utf-8') != refresh_token:
        raise refresh_token_exception()
    
    await redis_client.delete(f"{username}_access")
    await redis_client.delete(f"{username}_refresh")
    redis_client.close()
    await redis_client.wait_closed()
    return {'detail': '성공적으로 로그아웃 되었습니다!'}