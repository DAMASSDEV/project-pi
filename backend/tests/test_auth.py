from app.core.security import hash_password, verify_password


def test_signup_and_signin(client):
    email = "signup1@example.com"
    resp = client.post(
        "/api/auth/signup",
        json={"name": "Test User", "email": email, "password": "secret123"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["success"] is True
    assert data["token"]

    resp2 = client.post(
        "/api/auth/signin",
        json={"email": email, "password": "secret123"},
    )
    assert resp2.status_code == 200
    assert resp2.json()["token"]


def test_signin_wrong_password(client):
    email = "wrongpass@example.com"
    client.post(
        "/api/auth/signup",
        json={"name": "Test User", "email": email, "password": "correctpass"},
    )
    resp = client.post(
        "/api/auth/signin",
        json={"email": email, "password": "wrongpass"},
    )
    assert resp.status_code == 401


def test_signup_duplicate_email(client):
    email = "duplicate@example.com"
    payload = {"name": "Dup", "email": email, "password": "pass123"}
    client.post("/api/auth/signup", json=payload)
    resp = client.post("/api/auth/signup", json=payload)
    assert resp.status_code == 400


def test_password_hashing_roundtrip():
    hashed = hash_password("mypassword")
    assert hashed != "mypassword"
    assert verify_password("mypassword", hashed)
    assert not verify_password("wrongpassword", hashed)


def test_forgot_password_unknown_email(client):
    resp = client.post(
        "/api/auth/forgot-password", json={"email": "doesnotexist@example.com"}
    )
    assert resp.status_code == 404


def test_forgot_password_rate_limit(client):
    email = "ratelimit@example.com"
    client.post(
        "/api/auth/signup",
        json={"name": "T4", "email": email, "password": "pass123"},
    )
    first = client.post("/api/auth/forgot-password", json={"email": email})
    assert first.status_code == 200
    second = client.post("/api/auth/forgot-password", json={"email": email})
    assert second.status_code == 429
