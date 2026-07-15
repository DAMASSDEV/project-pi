def test_get_meals_requires_auth(client):
    resp = client.get("/api/meals", params={"email": "noauth@example.com"})
    assert resp.status_code in (401, 403)


def test_get_meals_rejects_other_users_email(client, auth_headers):
    headers = auth_headers("usera@example.com")
    resp = client.get(
        "/api/meals",
        params={"email": "userb@example.com"},
        headers=headers,
    )
    assert resp.status_code == 403


def test_get_meals_allows_own_email(client, auth_headers):
    headers = auth_headers("userc@example.com")
    resp = client.get(
        "/api/meals",
        params={"email": "userc@example.com"},
        headers=headers,
    )
    assert resp.status_code == 200
    assert resp.json() == []


def _meal_payload(email):
    return {
        "email": email,
        "food_name": "Test Food",
        "calories": 100.0,
        "protein": 5.0,
        "carbs": 10.0,
        "fat": 2.0,
        "health_score": 80,
        "components": "test",
        "timestamp": "2026-01-01 12:00",
        "image_path": "assets/image1.png",
        "is_manual": True,
    }


def test_meal_crud_lifecycle(client, auth_headers):
    email = "lifecycle@example.com"
    headers = auth_headers(email)

    create_resp = client.post("/api/meals", json=_meal_payload(email), headers=headers)
    assert create_resp.status_code == 200
    meal = create_resp.json()
    assert meal["portion"] == 1.0
    meal_id = meal["id"]

    update_resp = client.put(
        f"/api/meals/{meal_id}",
        json={"calories": 150.0, "portion": 2.0},
        headers=headers,
    )
    assert update_resp.status_code == 200
    assert update_resp.json()["meal"]["portion"] == 2.0
    assert update_resp.json()["meal"]["calories"] == 150.0

    delete_resp = client.delete(f"/api/meals/{meal_id}", headers=headers)
    assert delete_resp.status_code == 200


def test_save_meal_rejects_other_users_email(client, auth_headers):
    headers = auth_headers("spoofer@example.com")
    resp = client.post(
        "/api/meals",
        json=_meal_payload("victim@example.com"),
        headers=headers,
    )
    assert resp.status_code == 403


def test_delete_meal_rejects_non_owner(client, auth_headers):
    headers_a = auth_headers("ownera@example.com")
    headers_b = auth_headers("ownerb@example.com")

    create_resp = client.post(
        "/api/meals", json=_meal_payload("ownera@example.com"), headers=headers_a
    )
    meal_id = create_resp.json()["id"]

    resp = client.delete(f"/api/meals/{meal_id}", headers=headers_b)
    assert resp.status_code == 403


def test_update_meal_rejects_non_owner(client, auth_headers):
    headers_a = auth_headers("owner2a@example.com")
    headers_b = auth_headers("owner2b@example.com")

    create_resp = client.post(
        "/api/meals", json=_meal_payload("owner2a@example.com"), headers=headers_a
    )
    meal_id = create_resp.json()["id"]

    resp = client.put(
        f"/api/meals/{meal_id}", json={"calories": 999.0}, headers=headers_b
    )
    assert resp.status_code == 403
