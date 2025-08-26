from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: (
        str  # e.g. postgresql+asyncpg://postgres:postgres@localhost:5432/pharma
    )
    FIREBASE_PROJECT_ID: str | None = None
    CORS_ORIGINS: list[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:37737",
    ]  # add your Flutter web origin
    RESERVATION_MINUTES: int = 120  # booking hold time

    class Config:
        env_file = ".env"


settings = Settings()
