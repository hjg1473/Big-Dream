from fastapi import FastAPI
import models
from database import engine
from routers import auth, users, super, student

app = FastAPI()

models.Base.metadata.create_all(bind=engine)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(super.router)
app.include_router(student.router)