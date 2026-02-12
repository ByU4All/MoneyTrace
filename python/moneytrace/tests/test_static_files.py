"""
Test static file serving.
"""


def test_serve_index_html(client):
    """Test that index.html is served at root."""
    response = client.get("/")
    assert response.status_code == 200
    assert "MoneyTrace" in response.text
    assert "<!DOCTYPE html>" in response.text


def test_serve_css(client):
    """Test that CSS file is served."""
    response = client.get("/css/app.css")
    assert response.status_code == 200
    assert "MoneyTrace PWA" in response.text or "root" in response.text


def test_serve_js_api(client):
    """Test that api.js is served."""
    response = client.get("/js/api.js")
    assert response.status_code == 200
    assert "API" in response.text


def test_serve_js_screens(client):
    """Test that screens.js is served."""
    response = client.get("/js/screens.js")
    assert response.status_code == 200
    assert "Screens" in response.text


def test_serve_js_app(client):
    """Test that app.js is served."""
    response = client.get("/js/app.js")
    assert response.status_code == 200
    assert "App" in response.text

