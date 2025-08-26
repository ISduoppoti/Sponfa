import firebase_admin
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
from firebase_admin import auth as fb_auth
from firebase_admin import credentials

bearer = HTTPBearer(auto_error=False)
_init = False


def _ensure_firebase():
    global _init
    if not _init:
        # Use ADC or service account JSON via GOOGLE_APPLICATION_CREDENTIALS
        firebase_admin.initialize_app()
        _init = True


async def get_current_user(token=Depends(bearer)):
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    _ensure_firebase()
    try:
        decoded = fb_auth.verify_id_token(token.credentials)
        return decoded  # contains 'uid'
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
