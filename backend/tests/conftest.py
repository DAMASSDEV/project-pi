import os
import tempfile

os.environ["DATABASE_URL"] = f"sqlite:///{tempfile.mktemp(suffix='.db')}"
os.environ["JWT_SECRET_KEY"] = "test-secret-key"
os.environ["SMTP_EMAIL"] = ""
os.environ["SMTP_APP_PASSWORD"] = ""

import pytest
from fastapi.testclient import TestClient
from app.main import app


@pytest.fixture(scope="session")
def client():
    with TestClient(app) as c:
        yield c


@pytest.fixture
def auth_headers(client):
    def _make(email: str, password: str = "testpass123"):
        client.post(
            "/api/auth/signup",
            json={"name": "Test User", "email": email, "password": password},
        )
        resp = client.post(
            "/api/auth/signin",
            json={"email": email, "password": password},
        )
        token = resp.json()["token"]
        return {"Authorization": f"Bearer {token}"}

    return _make
