def test_search_foods_short_query_returns_empty(client):
    resp = client.get("/api/foods/search", params={"q": "a"})
    assert resp.status_code == 200
    assert resp.json()["results"] == []


def test_search_foods_finds_laksa(client):
    resp = client.get("/api/foods/search", params={"q": "laksa"})
    assert resp.status_code == 200
    results = resp.json()["results"]
    assert len(results) > 0
    assert any("laksa" in r["food_name"].lower() for r in results)


def test_scan_meal_exact_match_prefers_exact_over_substring(client):
    resp = client.post("/api/meals/scan", json={"food_name": "Laksa"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["food_name"].lower() == "laksa"
    assert data["calories"] == 280.0


def test_scan_meal_unknown_food_uses_fallback(client):
    resp = client.post(
        "/api/meals/scan", json={"food_name": "Xyzqwzz123NotARealFood"}
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["calories"] == 250.0
    assert data["components"] == "Bahan Segar Pilihan"


def test_scan_meal_cungkring_has_dedicated_components(client):
    resp = client.post("/api/meals/scan", json={"food_name": "Cungkring"})
    assert resp.status_code == 200
    data = resp.json()
    assert "paru" in data["components"].lower()


def test_scan_meal_empty_food_name_rejected(client):
    resp = client.post("/api/meals/scan", json={"food_name": "  "})
    assert resp.status_code == 400
