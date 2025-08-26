from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api.products import router as products_router
from .core.config import settings

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health():
    return {"ok": True}


app.include_router(products_router)
