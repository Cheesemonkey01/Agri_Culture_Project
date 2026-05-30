# Agri_Culture_Project

## Projektübersicht
Dieses Projekt implementiert eine einfache Smart Agriculture API in Python mit FastAPI. Die API liest Sensordaten aus der CSV-Datei `smart_agriculture_measurements.csv`, wertet sie aus und stellt sie als JSON-Endpunkte zur Verfügung.

## Systemarchitektur
Das System ist als monolithischer Backend-Service aufgebaut:
- **Backend**: `main.py` mit FastAPI
- **Datenquelle**: `smart_agriculture_measurements.csv`
- **API-Dokumentation**: `api.yml`

### Komponenten
- `main.py`
  - definiert alle HTTP-Endpunkte
  - lädt Messdaten mit `pandas`
  - berechnet Statistiken und generiert Alerts
- `smart_agriculture_measurements.csv`
  - enthält die Sensor-Messwerte
- `api.yml`
  - beschreibt die OpenAPI-Spezifikation der API

### Datenfluss
1. Client sendet eine HTTP-Anfrage an einen Endpunkt.
2. FastAPI routet die Anfrage zu einer Funktion in `main.py`.
3. Die Funktion lädt bei Bedarf die CSV-Datei und verarbeitet die Daten.
4. Das Ergebnis wird als JSON zurückgegeben.

## API-Endpunkte
- `GET /` - Basisinformation zur API
- `GET /health` - Statusprüfung
- `GET /sensors` - zuletzt geladene Messwerte
- `GET /statistics` - berechnete Kennzahlen zu pH und Bodenfeuchte
- `GET /alerts` - Alerts basierend auf der letzten Messung
- `POST /login` - Demo-Authentifizierung

## Betrieb
Die API kann lokal mit Uvicorn gestartet werden:

```bash
uvicorn main:app --reload
```

Standardmäßig ist sie dann unter `http://127.0.0.1:8000` erreichbar.

## Hinweise
Aktuell handelt es sich um einen Prototyp. Für den produktiven Einsatz sollten folgende Punkte ergänzt werden:
- echte Authentifizierung und Autorisierung
- HTTPS/TLS
- eingeschränkte CORS-Konfiguration
- feste Abhängigkeitsverwaltung (`requirements.txt` oder `pyproject.toml`)
- Logging und Fehlerhandling

