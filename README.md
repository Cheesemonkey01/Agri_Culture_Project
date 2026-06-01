# 🌱 Smart Agriculture Monitoring System – Komplette Projekt-Dokumentation

## 🎯 Projektüberblick

Ein **vollständiges IoT-Überwachungssystem** für intelligente Landwirtschaft mit mehreren Komponenten:

### Komponenten des Projekts

1. **🖥️ Flutter Desktop App** (Windows)
   - Live-Anzeige von Sensordaten
   - Interaktive Analyse-Dashboards (Kennzahlen, Trends)
   - Warnsystem bei Abweichungen
   - Automatisches Refresh wenn CSV ändert sich

2. **🐍 Python FastAPI Server** (Backend)
   - REST API für Datenbeschaffung
   - Statistik-Berechnungen (μ, σ, Cp, Cpk, etc.)
   - Alert-System
   - Authentifizierung (Login)
   - CORS aktiviert für Cross-Origin-Anfragen

3. **📊 CSV-Datenspeicher**
   - Zentrale Datenquelle (`smart_agriculture_measurements.csv`)
   - Kann von Python, Flutter oder externen IoT-Sensoren befüllt werden
   - Kompatibel mit Excel und anderen Tools

5. **🔌 API-Definition** (OpenAPI/Swagger)
   - Formale Spezifikation aller Endpoints
   - Automatische API-Dokumentation

### Datenfluss

```
Sensoren / Messsysteme
    ↓
CSV-Datei (smart_agriculture_measurements.csv)
    ↑↓
Python FastAPI Server (Statistiken, Alerts)
    ↓
Flutter Windows App (UI, Live-Anzeige)
    ↓
Benutzer sieht Dashboard, Analyse, Warnungen
```

---

## 📋 Abkürzungen & Erklärungen

### Technologie-Abkürzungen

| Abkürzung | Vollform | Erklärung |
|-----------|----------|-----------|
| **CSV** | Comma-Separated Values | Einfaches Text-Dateiformat zum Speichern von Tabellendaten (Spalten mit Komma getrennt). Kann mit Excel oder einem Text-Editor geöffnet werden. |
| **API** | Application Programming Interface | Schnittstelle, über die verschiedene Programme miteinander kommunizieren können. |
| **UI** | User Interface | Die sichtbare Bedienoberfläche der Anwendung (Buttons, Fenster, Menüs). |
| **UX** | User Experience | Wie benutzerfreundlich die Anwendung ist. |
| **FAB** | Floating Action Button | Der runde Button mit dem Plus-Symbol (schwebt über dem Fenster). |
| **JSON** | JavaScript Object Notation | Dateiformat zum Austausch von strukturierten Daten zwischen Programmen. |
| **HTTP** | HyperText Transfer Protocol | Protokoll für Datenaustausch im Internet. |

### Landwirtschaft & Messwerte

| Abkürzung | Vollform | Erklärung |
|-----------|----------|-----------|
| **pH** | Potenz des Wasserstoffs | Maßstab für Säure/Lauge-Gehalt. Bereich: 0–14. Neutral = 7, sauer < 7, basisch > 7. Optimal für Pflanzen oft: 6.0–7.5. |
| **LSL** | Lower Specification Limit | Untere Grenze für akzeptable Messwerte. Wenn Wert < LSL → Warnung. |
| **USL** | Upper Specification Limit | Obere Grenze für akzeptable Messwerte. Wenn Wert > USL → Warnung. |
| **Cp** | Process Capability Index | Kennzahl, die zeigt, ob der **Prozess die Toleranz schafft** (unabhängig von Zentration). Wert > 1.33 = gut. |
| **Cpk** | Process Capability Kindex | Verbesserung von Cp – berücksichtigt auch, **wie gut der Prozess zentriert** ist. Wert > 1.0 = akzeptabel. |
| **σ (Sigma)** | Standardabweichung | Maß für die **Streuung** der Messwerte. Kleine σ = stabile Messungen, große σ = stark schwankend. |
| **μ (Mu)** | Mittelwert / Durchschnitt | Summe aller Werte ÷ Anzahl der Messungen. |

### Qualitätskontrolle (Six Sigma / SPC)

| Abkürzung | Vollform | Erklärung |
|-----------|----------|-----------|
| **SPC** | Statistical Process Control | Statistische Prozesskontrolle – Überwachung mit Kennzahlen wie Cp/Cpk. |
| **QM / QS** | Qualitätsmanagement / Qualitätssicherung | System zur Kontrolle und Verbesserung der Produktqualität. |
| **TOL / Toleranz** | Tolerance | Zulässiger Bereich für einen Messwert. Ziel: Alle Werte liegen zwischen LSL und USL. |

### Allgemeine Begriffe

| Abkürzung | Vollform | Erklärung |
|-----------|----------|-----------|
| **DB / Datenbank** | Database | Strukturierte Sammlung von Daten. In diesem Projekt: CSV-Datei. |
| **OOP** | Object-Oriented Programming | Programmierstil mit Klassen und Objekten (z.B. `SensorReading`, `AppData`). |
| **CRUD** | Create, Read, Update, Delete | Vier Basis-Operationen auf Daten: Erstellen, Lesen, Ändern, Löschen. |

---

## 🛠️ Technischer Aufbau

### Verwendete Technologien

- **Programmiersprache**: Dart
- **Framework**: Flutter (für Windows-Desktop-Apps)
- **Datenformat**: CSV (einfache Text-Datei)
- **Abhängigkeiten**: `csv` (für robustes Parsen), `flutter` Standard-Bibliotheken

### Projektstruktur

```
Agri_Culture_Project/
├── flutter_app/                    # Haupt-Anwendung
│   ├── lib/
│   │   └── main.dart              # Kompletter App-Code
│   ├── test/
│   │   └── widget_test.dart       # Tests
│   ├── pubspec.yaml               # Abhängigkeiten & Konfiguration
│   └── windows/                   # Windows-spezifische Dateien
├── smart_agriculture_measurements.csv  # Datenspeicher (Messwerte)
├── api.yml                         # API-Definition (nicht aktiv)
├── FLM_6AAME_Smart_Agriculture.ipynb   # Dokumentation/Notebook
├── Zwischenpraesentation.md        # Präsentation
└── README.md                       # Diese Datei
```

### Wichtige Code-Klassen

#### `SensorReading`
Speichert **eine einzelne Messung**:
- Zeitstempel (wann gemessen)
- 6 Messwerte: Bodenfeuchte, Bodentemperatur, Lufttemperatur, Luftfeuchte, pH, Bewässerung
- Systemstatus (OK / Fehler)

#### `AppData`
Verarbeitet und speichert **alle Messungen**:
- Lädt CSV-Datei
- Berechnet Kennzahlen: Mittelwert, Standardabweichung, Cp, Cpk
- Erkennt Warnungen (Werte außerhalb LSL/USL)
- Speichert den Pfad zur CSV-Datei

#### `HomePage` / `_HomePageState`
**Haupt-Fenster** mit:
- Bottom Navigation (4 Tabs: Dashboard, Analyse, Alerts, Info)
- Auto-Reload (File-Watcher überwacht CSV-Änderungen)
- Refresh-Button (oben rechts)
- FAB „Neue Messung anhängen" (Eingabeformular)

#### Screen-Klassen
- `DashboardScreen`: Aktuelle Sensordaten + Kennzahlen auf einen Blick
- `AnalysisScreen`: Detaillierte Prozessfähigkeitsanalyse (Cp/Cpk)
- `AlertsScreen`: Warnsystem – zeigt Abweichungen
- `InfoScreen`: Dateipfad, letzte Messung, Projekt-Info

---

## 🚀 Installation & Start

### Voraussetzungen

1. **Flutter SDK** installiert (≥ 3.10.8)  
   Download: https://flutter.dev
2. **Windows 10/11** (für Desktop-Anwendung)
3. **Text-Editor** (z.B. VS Code, um CSV-Datei zu bearbeiten)

### Schritt-für-Schritt

#### 1. Abhängigkeiten installieren
```powershell
cd flutter_app
flutter pub get
```

#### 2. App starten
```powershell
flutter run -d windows
```

#### 3. App testen
- Navigiere durch die 4 Tabs (Dashboard, Analyse, Alerts, Info)
- Klicke auf „Neue Messung anhängen" → Formular öffnet sich
- Fülle Werte ein → „Hinzufügen" klicken
- CSV wird aktualisiert, App lädt automatisch neu
- Oder: Manueller Refresh mit Button oben rechts

---

## 📊 Die CSV-Datei verstehen

### Aufbau

Die Datei `smart_agriculture_measurements.csv` speichert alle Messungen:

```csv
timestamp,soilMoisture,soilTemperature,airTemperature,airHumidity,ph,irrigation,systemStatus
2025-06-01 10:30:00,45.2,18.5,22.1,65.3,6.8,False,OK
2025-06-01 11:00:00,48.1,19.2,23.5,62.1,6.7,True,OK
2025-06-01 11:30:00,50.0,20.0,25.0,55.0,6.5,False,OK
```

### Spalten erklärt

| Spalte | Einheit | Bereich | Beispiel |
|--------|---------|---------|----------|
| `timestamp` | Text (ISO 8601) | — | `2025-06-01 10:30:00` |
| `soilMoisture` | % | 0–100 | `45.2` |
| `soilTemperature` | °C | -20–60 | `18.5` |
| `airTemperature` | °C | -20–60 | `22.1` |
| `airHumidity` | % | 0–100 | `65.3` |
| `ph` | pH (0–14) | 0–14 | `6.8` |
| `irrigation` | Boolean | True/False | `False` |
| `systemStatus` | Text | OK/WARNING/CRITICAL | `OK` |

### CSV manuell bearbeiten

1. CSV mit Excel oder Notepad öffnen
2. Neue Zeile hinzufügen (richtige Spalten-Reihenfolge!)
3. Speichern (Strg+S)
4. Flutter-App: Refresh-Button klicken
5. Neue Daten sollten sofort sichtbar sein

---

## 🧩 Datenmodell

Das Projekt hat zwei zentrale Datenebenen:

### 1. Messdaten (Zeilenmodell)

Die CSV-Datei ist das primäre Datenmodell. Jede Zeile entspricht einer Messung und enthält folgende Felder:

- `timestamp`: Zeitpunkt der Messung
- `soil_moisture` / `soil_moisture_percent`: Bodenfeuchte in Prozent
- `soil_temperature` / `soil_temperature_c`: Bodentemperatur in °C
- `air_temperature` / `air_temperature_c`: Lufttemperatur in °C
- `air_humidity` / `air_humidity_percent`: Luftfeuchte in Prozent
- `ph` / `ph_value`: pH-Wert
- `irrigation` / `irrigation_active`: Bewässerungszustand (True/False)
- `system_status`: Status der Messanlage (z. B. OK, WARNING)

Dieses Zeilenmodell wird vom Python-Server in einen `pandas.DataFrame` geladen und als JSON-Antwort für API-Clients bereitgestellt.

### 2. Analysemodell (Aggregierte Werte)

Auf Basis aller Messreihen werden aggregierte Kennzahlen berechnet:

- `sample_count`: Anzahl der Messungen
- `ph_mean`, `ph_median`: Mittelwert und Median des pH-Werts
- `ph_std`, `ph_variance`: Standardabweichung und Varianz
- `ph_cpl`, `ph_cpu`: Prozessfähigkeitsanteile (unten/oben)
- `ph_cp`, `ph_cpk`: Prozessfähigkeitsindices
- `soil_moisture_mean`, `soil_moisture_min`, `soil_moisture_max`: Bodenfeuchtemetriken

Diese Kennzahlen sind das Analysemodell und werden über den API-Endpunkt `/statistics` geliefert.

### Datenmodell in Flutter

In der Flutter-App sind die wichtigsten Datentypen:

- `SensorReading`: Eine einzelne Messung mit Feldern wie `timestamp`, `soilMoisture`, `soilTemperature`, `airTemperature`, `airHumidity`, `phValue`, `irrigationActive`, `systemStatus`.
- `AppData`: Eine Sammlung aller `SensorReading`-Objekte plus berechnete Werte (`meanPh`, `stdPh`, `cp`, `cpk`) und den Pfad zur CSV-Datei.

`AppData` bildet im Frontend die Verbindung zwischen Rohdaten und Benutzeroberfläche: Es liefert das letzte Messdatum, Warnungen, Systemstatus und die Analysekennzahlen.

### Datenfluss Zusammenfassung

1. Sensorwerte werden als neue Zeile in die CSV geschrieben.
2. Der Python-API-Server liest die CSV und wandelt sie in ein Tabellen-Objekt (`DataFrame`) um.
3. Über die API liest die Flutter-App entweder rohe Messwerte oder berechnete Kennzahlen.
4. Im Frontend wird `SensorReading` für einzelne Messungen und `AppData` für die aggregierten Ergebnisse verwendet.

---

## 🧠 API-Design des Projekts

Die API dient als Bindeglied zwischen CSV-Daten und der Flutter-UI. Sie wurde mit FastAPI implementiert und ist als REST-Schnittstelle strukturiert.

### Haupt-Endpunkte

- `GET /health` – Statusprüfung der API
- `POST /login` – einfache Anmeldeprüfung für Authentifizierungstest
- `GET /sensors` – liefert alle Rohmessungen als JSON
- `GET /statistics` – berechnete Kennzahlen für die Analyseseiten
- `GET /alerts` – identifiziert Messungen mit Grenzwertverletzungen

### Designprinzipien

- **Single Source of Truth**: Die CSV-Datei ist die einzige Quelle der Rohdaten.
- **Trennung von Verantwortung**: Python übernimmt Datenverarbeitung und Statistik, Flutter kümmert sich um Darstellung und Interaktion.
- **JSON als Austauschformat**: API-Antworten sind JSON, damit sie einfach im Flutter-Frontend verarbeitet werden können.
- **Erweiterbarkeit**: Neue Endpunkte können hinzugefügt werden, z. B. `/sensor/{id}` oder `/export`.

### Authentifizierung

Der aktuelle Prototyp enthält einen einfachen Login-Endpoint zur Demonstration. Für ein produktives System sollte hier eine sichere Authentifizierung mit Token oder OAuth ergänzt werden.

---

## 📈 Datenanalyse im Projekt

### Analyseverfahren

Die Datenanalyse erfolgt in zwei Stufen:

1. **Rohdaten einlesen**
   - CSV-Datei lesen
   - in ein `pandas.DataFrame` konvertieren
   - ungültige Werte filtern oder in `NaN` umwandeln

2. **Kennzahlen berechnen**
   - Mittelwert, Median, Varianz, Standardabweichung
   - Prozessfähigkeit: `Cp`, `Cpk`, `Cpl`, `Cpu`
   - Grenzwertbewertungen auf Basis von LSL/USL

### Wichtige Metriken

- `mean` / `median` – zentrale Lage der Messwerte
- `std` / `variance` – Streuung der Daten
- `Cp` – zeigt, ob die Prozessstreuung in der Toleranz liegt
- `Cpk` – berücksichtigt zusätzlich die Lage des Mittelwerts
- Grenzwertverletzungen – konkrete Alerts für Werte außerhalb erlaubter Bereiche

### Praxisnutzen

- Analyse ermöglicht frühzeitiges Erkennen von Trends
- Alerts zeigen, wenn Bodenfeuchte oder pH-Wert aus dem optimalen Bereich fallen
- Cp/Cpk geben ein Qualitätsbild der Stabilität der Messgrößen

---

## 🧾 Offene Punkte

- **Echte Sensordaten**: Anschluss von realen IoT-Sensoren statt manueller CSV-Eingabe.
- **Persistenz**: Umstellung auf echte Datenbank (SQLite, PostgreSQL) für Mehrbenutzerbetrieb.
- **Sicherheit**: Starker Auth-Mechanismus, Eingabevalidierung und sichere Speicherung.
- **Skalierbarkeit**: API-Rate-Limiting, Paging bei großen Datenmengen, WebSocket für Echtzeit-Updates.
- **Fehlerbehandlung**: Robuster Umgang mit fehlerhaften oder gesperrten CSV-Dateien.
- **Tests**: Automatisierte Integrationstests für API und Datenpipeline.
- **UI/UX**: Bessere Visualisierung von Trends, Diagramme und Benutzerführung.

---

## 🧩 Lessons Learned

- **Datenmodell zuerst planen**: Eine klare Trennung zwischen Rohdaten und Analyse verbessert Wartbarkeit.
- **CSV als Einstieg geeignet**: Einfach, aber nicht ausreichend für produktive Systeme mit mehreren Nutzern.
- **Trennung Backend / Frontend**: Python eignet sich gut für Berechnungen und Statistik; Flutter für Benutzeroberfläche.
- **Auto-Reload ist wertvoll**: File-Watcher mit Refresh sorgt für flüssige Nutzung beim Datenaustausch.
- **Dokumentation zählt**: Eine gute README macht das System verständlicher, insbesondere bei mehreren Komponenten.
- **Sicherheit darf nicht fehlen**: Frühzeitig über Authentifizierung, CORS und Datenvalidierung nachdenken.

---

## 📈 Kennzahlen verstehen
 
### Mittelwert (μ)
```
μ = (x₁ + x₂ + ... + xₙ) / n
```
**Beispiel:** pH-Messwerte: 6.5, 6.7, 6.8  
μ = (6.5 + 6.7 + 6.8) / 3 = **6.67**

### Standardabweichung (σ)
```
σ = √[ Σ(xᵢ - μ)² / n ]
```
Misst, wie **verstreut** die Werte sind. Kleine σ = stabil, große σ = wild schwankend.

### Cp (Process Capability Index)
```
Cp = (USL - LSL) / (6 × σ)
```
Zeigt, ob die **Breite des Prozesses** in den Toleranzbereich passt.
- Cp > 1.33: Sehr gut
- Cp > 1.0: Akzeptabel
- Cp < 1.0: Nicht fähig (zu viel Streuung)

### Cpk (Process Capability Kindex)
```
Cpk = min[ (μ - LSL)/(3×σ) , (USL - μ)/(3×σ) ]
```
Wie Cp, **berücksichtigt aber auch die Zentrierung** (ist der Prozess richtig eingestellt?).
- Cpk > 1.0: Der Prozess ist stabil und gut zentriert
- Cpk < 1.0: Der Prozess produziert zu viele Ausreißer

---

## ⚠️ Warnsystem

Die App zeigt **Warnungen** (Alerts), wenn:

1. **pH-Wert außerhalb Spezifikation**
   - Ziel-Bereich: 5.8 ≤ pH ≤ 7.2
   - Wenn pH < 5.8 oder > 7.2 → ⚠️ Warnung

2. **Systemstatus ist nicht OK**
   - Wenn `systemStatus` ≠ „OK" → ⚠️ Warnung

Diese Warnungen erscheinen im **Alerts-Tab** und beeinflussen den **System-Status** auf dem Dashboard.

---

## � Python FastAPI Server – Backend

Der Python-Server ist das **Herzstück der Datenverarbeitung**. Er liest die CSV-Datei, berechnet Statistiken und stellt alles über eine REST-API zur Verfügung.

### Technologie

- **Framework**: FastAPI (modernes Python Web-Framework)
- **Daten-Verarbeitung**: Pandas (Tabellen & Statistik)
- **Server**: Uvicorn (ASGI-Server)
- **CORS**: Aktiviert (Flutter-App kann vom Desktop zugreifen)

### Installation & Start

#### 1. Python-Abhängigkeiten installieren
```powershell
pip install fastapi uvicorn pandas
```

#### 2. Server starten
```powershell
python main.py
```

Ausgabe:
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

#### 3. API testen
Öffne einen Browser:
```
http://localhost:8000/docs
```
oder
```
http://localhost:8000/redoc
```

Das ist die **automatische interaktive API-Dokumentation** (Swagger UI).

### Verfügbare Endpoints

Alle Endpoints geben JSON-Responses zurück.

#### `GET /health`
**Systemstatus prüfen**

Request:
```
GET http://localhost:8000/health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2025-06-01T10:30:45.123456"
}
```

**Wofür**: Prüfung, ob der Server erreichbar ist.

---

#### `GET /sensors?limit=10`
**Letzte Messwerte abrufen**

Parameter:
- `limit` (optional, default=10): Anzahl der Messwerte

Request:
```
GET http://localhost:8000/sensors?limit=5
```

Response:
```json
{
  "count": 5,
  "data": [
    {
      "timestamp": "2025-06-01T10:30:00",
      "soil_moisture_percent": 45.2,
      "soil_temperature_c": 18.5,
      "air_temperature_c": 22.1,
      "air_humidity_percent": 65.3,
      "ph_value": 6.8,
      "irrigation_active": false,
      "system_status": "OK"
    },
    ...
  ]
}
```

**Wofür**: Rohdaten für Tabellen, Graphen, Exportfunktionen.

---

#### `GET /statistics`
**Berechnete Kennzahlen**

Request:
```
GET http://localhost:8000/statistics
```

Response:
```json
{
  "sample_count": 42,
  "ph_mean": 6.75,
  "ph_median": 6.8,
  "ph_std": 0.342,
  "ph_variance": 0.117,
  "ph_cpl": 1.247,
  "ph_cpu": 1.419,
  "ph_cp": 1.323,
  "ph_cpk": 1.247,
  "soil_moisture_mean": 47.3,
  "soil_moisture_min": 35.1,
  "soil_moisture_max": 62.5
}
```

**Erklärung:**
- `ph_mean`: Durchschnitt pH
- `ph_std`: Standardabweichung (Streuung)
- `ph_cpl`: Untere Prozessfähigkeit (CPU = Lower)
- `ph_cpu`: Obere Prozessfähigkeit (CPL = Upper) – **achtung: Naming ist in der API vertauscht**
- `ph_cp`: Prozessfähigkeitsindex (gesamte Toleranz)
- `ph_cpk`: Zentrierte Prozessfähigkeit (beachtet Versatz)

**Wofür**: Qualitätskontrolle, Bericht-Erzeugung, Trend-Analyse.

---

#### `GET /alerts`
**Warnungen generieren**

Request:
```
GET http://localhost:8000/alerts
```

Response:
```json
{
  "alerts": [
    {
      "timestamp": "2025-06-01T10:30:00",
      "type": "PH_TOO_HIGH",
      "severity": "HIGH",
      "message": "pH above upper specification limit"
    },
    {
      "timestamp": "2025-06-01T10:30:00",
      "type": "SOIL_DRY",
      "severity": "MEDIUM",
      "message": "Bodenfeuchte zu niedrig"
    }
  ],
  "latest_measurement": { ... }
}
```

**Alert-Typen:**
- `PH_TOO_LOW`: pH < 5.8
- `PH_TOO_HIGH`: pH > 7.2
- `SOIL_DRY`: Bodenfeuchte < 35%
- `AIR_TEMP_HIGH`: Lufttemperatur > 28°C
- `SYSTEM_ALERT`: Systemstatus ≠ OK

**Wofür**: Automatische Benachrichtigungen, Echtzeit-Überwachung.

---

#### `POST /login`
**Authentifizierung (Demo)**

Request:
```json
POST http://localhost:8000/login
Content-Type: application/json

{
  "username": "abc",
  "password": "123"
}
```

Response (erfolgreich):
```json
{
  "access_token": "demo-token",
  "token_type": "bearer"
}
```

Response (Fehler):
```json
{
  "detail": "Ungültige Anmeldedaten"
}
```

**Beachte:** Das ist ein **Demo-Token**. In echten Systemen würde man JWT (JSON Web Token) nutzen.

---

#### `GET /` (Root)
**API-Info**

Request:
```
GET http://localhost:8000/
```

Response:
```json
{
  "message": "Smart Agriculture API ist bereit. Verwende /health, /sensors, /statistics, /alerts, /login."
}
```

---

### Python-Code verstehen

#### Wichtige Funktionen

**`load_measurements()`**
```python
def load_measurements() -> pd.DataFrame:
    if not DATA_FILE.exists():
        raise FileNotFoundError(f"{DATA_FILE} not found")
    df = pd.read_csv(DATA_FILE, parse_dates=["timestamp"])
    return df
```
- Lädt CSV in einen **DataFrame** (wie Tabelle in Python)
- Konvertiert Spalte "timestamp" zu Datum/Zeit
- Wirft Error wenn Datei fehlt

**`compute_statistics(df)`**
- Berechnet Mittelwert, Median, Standardabweichung
- Berechnet Cp, Cpk mit LSL=5.8, USL=7.2
- Berechnet Min/Max für Bodenfeuchte
- Gibt alle Werte als Dictionary zurück

**`build_alerts(measurement)`**
- Prüft jeden Messwert gegen Grenzen
- Erstellt Alert-Objekte bei Überschreitungen
- Gibt Liste von Alerts zurück

**`latest_measurement(df)`**
- Nimmt letzte Zeile der Tabelle (`df.iloc[-1]`)
- Konvertiert zu Dictionary für JSON-Response

#### CORS-Middleware
```python
app.add_middleware(
  CORSMiddleware,
  allow_origins=["*"],
  allow_credentials=True,
  allow_methods=["*"],
  allow_headers=["*"],
)
```
Erlaubt der **Flutter-App auf Windows**, Daten vom Server abzurufen (ohne würde Browser/App die Anfrage blockieren).

---

### Schnittstelle zwischen Python & Flutter

```
Flutter App                              Python Server
    ↓                                        ↑
  (GET /sensors)  ← HTTP Request →  load_measurements()
    ↓                                        ↓
  parse JSON  ← HTTP Response (JSON) ← DataFrame to dict()
    ↓
 UI aktualisieren
```

Die Flutter-App könnte den Python-Server statt der CSV-Datei nutzen!

---

### Verwendungsszenarien

#### Szenario A: Einfache Nutzung (aktuell)
```
CSV-Datei ← Flutter App liest direkt
         ← auch File-Watcher beobachtet CSV
```

#### Szenario B: Mit Python-Server
```
CSV-Datei ← Python Server liest & verarbeitet
         ← Flutter fragt Python ab statt CSV zu lesen
         ← Mehrere Clients können Server nutzen
```

#### Szenario C: Mit IoT-Sensoren
```
IoT-Sensor → Python-Endpoint (neuer POST /measurements) → CSV-Datei
         → Flutter beobachtet CSV oder fragt Server ab
```

---

### Erweitering: Neuer Endpoint für Daten-Eingabe

Wenn du einen **Sensor-Schreiber** bauen willst:

```python
from pydantic import BaseModel

class MeasurementInput(BaseModel):
    soil_moisture_percent: float
    soil_temperature_c: float
    air_temperature_c: float
    air_humidity_percent: float
    ph_value: float
    irrigation_active: bool
    system_status: str

@app.post("/measurements")
def add_measurement(data: MeasurementInput) -> Dict:
    df = load_measurements()
    new_row = {
        "timestamp": datetime.now().isoformat(),
        **data.dict()
    }
    df = pd.concat([df, pd.DataFrame([new_row])], ignore_index=True)
    df.to_csv(DATA_FILE, index=False)
    return {"status": "ok", "measurement": new_row}
```

Damit könnte jeder Sensor/Client neue Messungen POST-en!

---

### Fehlerbehandlung

Wenn CSV nicht existiert:
```
HTTP/1.1 500 Internal Server Error
{"detail": "smart_agriculture_measurements.csv not found"}
```

Wenn Login falsch:
```
HTTP/1.1 401 Unauthorized
{"detail": "Ungültige Anmeldedaten"}
```

---

## 🔌 OpenAPI/Swagger Spezifikation

Die Datei `api.yml` definiert die **formale API-Spezifikation** im OpenAPI 3.0-Format.

### Was ist OpenAPI?

Ein **Standard**, um REST APIs zu dokumentieren:
- Beschreibt alle Endpoints
- Definiert Request/Response-Schemen
- Auto-generiert Dokumentation & Client-Code

### Viewer öffnen

Die FastAPI stellt automatisch Swagger UI zur Verfügung:
```
http://localhost:8000/docs       → Swagger UI (interaktiv)
http://localhost:8000/redoc      → ReDoc (hübsche Doku)
http://localhost:8000/openapi.json  → Roh-JSON
```

---

## 🔗 Integration zwischen Komponenten

### 1️⃣ Flutter → CSV (Aktuell)
```
Flutter liest CSV direkt
        ↓
File-Watcher beobachtet Änderungen
        ↓
Auto-Reload auf Basis von CSV
```

### 2️⃣ Flutter → Python Server (Optional)
```
Flutter POST: /measurements (neue Daten)
        ↓
Python speichert in CSV
        ↓
Flutter GET: /statistics (Kennzahlen)
        ↓
Flutter GET: /alerts (Warnungen)
```

### 3️⃣ Sensor → Python → Flutter
```
Sensor schreibt JSON zu /measurements
        ↓
Python speichert in CSV
        ↓
Flutter beobachtet CSV
        ↓
UI aktualisiert
```

### 4️⃣ Externes Skript → CSV → Flutter
```
Python-Skript (z.B. täglich) schreibt CSV
        ↓
Flutter-File-Watcher merkt Änderung
        ↓
Auto-Reload, Benutzer sieht neue Daten
```

---

## 🏗️ Gesamtarchitektur

```
┌─────────────────────────────────────────────────────────────┐
│                   Sensoren / Messsysteme                    │
│                                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│              CSV-Datei (Zentraler Datenspeicher)             │
│      (smart_agriculture_measurements.csv)                    │
│                                                              │
│  Spalten: timestamp, soilMoisture, temp, humidity, ph, ... │
└──────────────────────────────────────────────────────────────┘
         ↓ (File-Watcher)      ↓ (HTTP)
    ┌────────────────┐  ┌──────────────────┐
    │ Flutter App    │  │ Python Server    │
    │ (Windows UI)   │  │ (FastAPI)        │
    │                │  │                  │
    │ • Dashboard    │  │ • /sensors       │
    │ • Analyse      │  │ • /statistics    │
    │ • Alerts       │  │ • /alerts        │
    │ • Info         │  │ • /login         │
    │                │  │                  │
    └────────────────┘  └──────────────────┘
         ↓ (Anzeige)          ↓ (Datenverarbeitung)
    Benutzer sieht         Kennzahlen, Statistik
    Live-Daten            berechnet
```

### Datenfluss im Detail

1. **Daten-Erfassung**:
   - Sensor schreibt Daten → CSV (z.B. via Python-Skript)
   - Oder: Benutzer gibt manuell ein (Flutter Formular)

2. **Speicherung**:
   - CSV-Datei wird aktualisiert
   - Python-Server kann CSV auch laden

3. **Verarbeitung (Parallel)**:
   - **Flutter**: Liest CSV, berechnet lokal (unabhängig)
   - **Python**: Liest CSV, berechnet Statistiken (zentral)

4. **Anzeige**:
   - Flutter zeigt Dashboard, Alerts, Analyse
   - Python stellt API zur Verfügung (z.B. für andere Apps)

### Warum diese Architektur?

| Vorteil | Beschreibung |
|---------|-------------|
| **Dezentralisiert** | Flutter läuft lokal, Python als Option |
| **Skalierbar** | Python Server kann mehrere Clients bedienen |
| **Robust** | CSV als Fallback wenn Server weg |
| **Standard** | REST API, CSV, OpenAPI |
| **Testbar** | Jede Komponente einzeln testbar |

---


### Öffnen & Ausführen

```powershell
# Installation
pip install jupyter pandas matplotlib

# Starten
jupyter notebook FLM_6AAME_Smart_Agriculture.ipynb
```

Browser öffnet sich mit interaktivem Notebook.

### Notebook-Struktur

Typische Abschnitte:
1. **Import & Setup**: Bibliotheken laden, Daten einlesen
2. **Exploratory Data Analysis (EDA)**: Erste Blick auf Daten
3. **Data Cleaning**: Fehler / Ausreißer entfernen
4. **Statistik**: Berechnung von Kennzahlen
5. **Visualisierung**: Graphen & Charts
6. **Dokumentation**: Phase-Beschreibungen

---

## 🚀 Betrieb & Deployment

### Lokale Entwicklung (aktuell)

```powershell
# Terminal 1: Python Server
python main.py
→ API läuft auf http://localhost:8000

# Terminal 2: Flutter App
cd flutter_app
flutter run -d windows
→ Windows Desktop App lädt CSV lokal
```

### Production-Setup (Beispiel)

#### Option A: Nur Flutter (lokal)
```
Sensor → CSV
      → Flutter (Windows-PC) liest CSV
      → Benutzer sieht Daten
```

#### Option C: Vollständig IoT-basiert
```
IoT-Geräte → Cloud API
          → Datenbank
          → Web-Dashboard (z.B. Grafana, Tableau)
          → Mobile App
```

### Tipps für Production

1. **Datensicherung**: CSV täglich backup-en
2. **Error Handling**: Was passiert, wenn Sensor ausfällt?
3. **Skalierung**: Mehrere Felder/Sensoren?
4. **Authentifizierung**: Wer darf Daten sehen?
5. **Monitoring**: Alerts wenn Server down
6. **Logs**: Wer ändert wann Daten?

---

## 🔒 Sicherheit

### Aktueller Stand

- ⚠️ **CSV-Datei**: Keine Verschlüsselung, jeder kann den Dateiinhalt lesen und ändern.
- ⚠️ **Python-API**: CORS erlaubt alle Ursprünge (`allow_origins=["*"]`) – das ist nur für Entwicklung sinnvoll.
- ⚠️ **Login**: Demo-Token mit hartkodierten Zugangsdaten (`abc`/`123`); keine echte Authentifizierung, keine Sitzungsverwaltung.
- ⚠️ **Transport**: Aktuell kein HTTPS / TLS; API läuft unverschlüsselt auf `http://localhost:8000`.
- ⚠️ **Datenintegrität**: CSV ist keine transaktionale Datenbank; bei gleichzeitigen Zugriffen können Daten verloren gehen.
- ⚠️ **Zugriffssteuerung**: Es gibt keine Benutzerrollen (Admin/Viewer/Editor), keine Trennung von Lese- und Schreibrechten.
- ⚠️ **Fehlende Absicherung**: Keine Rate-Limits, kein Audit-Log, keine detaillierte Fehlerbehandlung für JSON/CSV-Injektion.

---

## 🛡️ Cybersecurity Review

### Identifizierte Risiken

| Risiko | Beschreibung | Schwere | Status |
|--------|--------------|---------|--------|
| Offene API | `allow_origins=["*"]` erlaubt jedem Browser/Client Zugriff. | Hoch | Aktuell |
| Unsichere Auth | Demo-Login ist nicht produktiv. | Hoch | Aktuell |
| Unverschlüsselte Übertragung | HTTP ohne TLS. | Hoch | Aktuell |
| Ungeprüfte Eingaben | Keine Pydantic-Prüfung bei CSV-Daten oder Login JSON. | Mittel | Aktuell |
| Datenverlust | CSV als Single-Source ohne Locking/Backup. | Mittel | Aktuell |
| Offen zugängliche Doku | Swagger UI `/docs` ist öffentlich. | Niedrig | Aktuell |

### Schwachstellen im Projekt

1. **CORS zu breit**
   - Das erlaubt fremden Webseiten, API-Anfragen an den Server zu stellen.
   - Besser: nur vertrauenswürdige Ursprünge zulassen oder CORS ganz deaktivieren für Desktop-Clients.

2. **Demo-Authentifizierung**
   - Hartkodierte Zugangsdaten sind unsicher.
   - Kein tatsächlicher Login-Prozess, kein Passwortschutz, keine Tokenprüfung.

3. **Keine Verschlüsselung**
   - Sensible Daten wie Messwerte und API-Zugriffe sollten nicht im Klartext über das Netzwerk laufen.
   - TLS/HTTPS ist notwendig, wenn der Server nicht nur lokal genutzt wird.

4. **CSV als Storage-Format**
   - CSV bietet keine Transaktionssicherheit.
   - Bei gleichzeitigem Schreiben können Daten beschädigt werden.
   - Keine Benutzerzugriffssteuerung möglich.

5. **Fehlende Input-Validierung**
   - Der Server akzeptiert JSON ohne strenge Schema-Prüfung.
   - Ungültige oder manipulierte Daten können zu Fehlern führen.

6. **Fehlende Protokollierung und Monitoring**
   - Es wird nicht dokumentiert, wer wann welche API verwendet.
   - Bei Sicherheitsvorfällen fehlen Hinweise zur Ursachenanalyse.

---

## ✅ Handlungsempfehlungen

### Kurzfristig (sofort umsetzen)

- **CORS einschränken**: Nur erlaubte Origins konfigurieren oder entfernen.
- **Login verbessern**: Entferne Demo-Zugangsdaten; nutze stattdessen sichere Authentifizierung.
- **HTTPS aktivieren**: Entwickle mit lokalen Zertifikaten oder setze einen Reverse Proxy mit TLS ein.
- **Input-Validation**: Nutze Pydantic-Modelle für alle API-Requests.
- **Rate-Limiting**: Schutz gegen brute-force und Automatisierungsangriffe.
- **Backups**: Regelmäßige Sicherung der CSV-Datei.

### Mittelfristig (weiter verbessern)

- **API-Key oder JWT**: Authentifiziere Clients sicherer.
- **Rollen und Berechtigungen**: Admin, Viewer, Editor definieren.
- **Datenspeicher upgraden**: CSV durch SQLite / PostgreSQL ersetzen.
- **Audit-Logs**: Schreibe alle Änderungen und Logins in eine Protokolldatei.
- **CSRF/Origin-Checks**: Wenn die API auch über Browser erreichbar ist.

### Langfristig (Produktivbetrieb)

- **Web Application Firewall (WAF)**: Schutz für öffentlichen API-Zugriff.
- **Vulnerability Scanning**: Regelmäßige Scans der Python- und Flutter-Abhängigkeiten.
- **Security Reviews**: Regelmäßige Sicherheitsprüfungen vor jeder neuen Phase.
- **Secrets Management**: Keine hartkodierten Passwörter, sondern Umgebungsvariablen oder Vaults.

---

## 🔧 Spezifische Empfehlungen für dieses Projekt

### Python FastAPI

- Verwende `pydantic.BaseModel` für POST/GET-Requests.
- Ersetze Demo-Login durch einen echten Token-Flow.
- Nutze `HTTPS` durch Uvicorn mit Zertifikat oder verwende `nginx` als Reverse Proxy.
- Setze `allow_origins` im CORS-Middleware auf echte Domains oder nur `localhost`.

### Flutter App

- Speichere keine Zugangsdaten im Quellcode.
- Verwende HTTPS-URLs, wenn du APIs aufrufst.
- Zeige keine sensiblen Daten in Klartext, falls später Passwörter hinzukommen.
- Prüfe, ob lokale Dateien vor unbefugter Änderung geschützt werden können.

### CSV und Datenhaltung

- Übergang zu einer relationalen DB für Produktionsumgebungen.
- Füge Datei-Locking (oder bessere Logs) hinzu, wenn mehrere Prozesse schreiben.
- Validierung der CSV-Daten beim Start, z. B. mit Schema-Checks.

---

## 💡 Fazit

Der aktuelle Projektstand ist gut für eine Lern- und Entwicklungsumgebung. Für echten Betrieb sind aber primär diese Sicherheitsmaßnahmen nötig:

- Authentifizierung absichern
- Transport verschlüsseln
- API-Zugriffe begrenzen
- Storage stabilisieren
- Logs und Monitoring einführen

Wenn du willst, kann ich auch ein konkretes Sicherheitskonzept für die Python-API und/oder den Produktionsbetrieb der Flutter-App schreiben. 

---

## 📚 Weitere Ressourcen

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [FastAPI Security](https://fastapi.tiangolo.com/tutorial/security/)
- [HTTPS mit Uvicorn](https://www.uvicorn.org/deployment/)
- [Secure CORS](https://developer.mozilla.org/de/docs/Web/HTTP/CORS)

---

## 📚 Weitere Ressourcen & Erweiterungen

### Mögliche Erweiterungen

| Feature | Aufwand | Nutzen |
|---------|---------|--------|
| **Graphen in Flutter** (pH über Zeit) | Mittel | Sehr hoch |
| **Push-Notifications** (kritische Alerts) | Hoch | Hoch |
| **Mobile App** (iOS/Android) | Hoch | Sehr hoch |
| **Daten-Export** (PDF, Excel) | Einfach | Mittel |
| **Mehrere Felder** (Verwaltung) | Hoch | Sehr hoch |
| **Echtzeit-Grafiken** (WebSocket) | Hoch | Sehr hoch |
| **Machine Learning** (Vorhersage) | Sehr hoch | Mittel |
| **Cloud-Deployment** (AWS, Azure) | Hoch | Hoch |

### Verwandte Technologien

| Technologie | Zweck |
|-------------|-------|
| **PostgreSQL / SQLite** | Robustere Datenbank statt CSV |
| **Docker** | Containerisierung für einfaches Deployment |
| **Kubernetes** | Orchestrierung bei vielen Servern |
| **Grafana** | Professionelle Dashboards & Alerting |
| **Mosquitto (MQTT)** | IoT-Protokoll für Sensor-Kommunikation |
| **RabbitMQ** | Message Queue für asynchrone Verarbeitung |
| **TensorFlow / Scikit-Learn** | Machine Learning für Vorhersagen |

---

## 🛠️ Troubleshooting

### Flutter App lädt CSV nicht

**Problem**: `CSV nicht gefunden`

**Lösungen**:
1. Prüfe: Ist `smart_agriculture_measurements.csv` im richtigen Ordner?
2. Prüfe: Pfad-Separatoren (Windows: `\`, Linux: `/`)
3. Lösung: Verschiebe CSV in `flutter_app/` oder Parent-Ordner
4. Code-Fix: `_findCsvFile()` bis 10 Ordner nach oben suchen

### Python Server antwortet nicht

**Problem**: `Connection refused` auf `localhost:8000`

**Lösungen**:
1. Server läuft? → `python main.py` neu starten
2. Port belegt? → `netstat -ano` (Windows) prüfen
3. Firewall? → Windows Firewall kann Port 8000 blockieren
4. CSV gibt Error? → CSV-Format prüfen (Kommas, Quotes)

### Flutter App aktualisiert nicht

**Problem**: CSV ändert sich, aber UI bleibt alt

**Lösungen**:
1. Warte 500ms (Debouncer)
2. Klick Refresh-Button (oben rechts)
3. Neu starten: `flutter run` beenden + erneut starten
4. Prüfe: Datei-Watcher funktioniert nur auf Netzwerk-Laufwerken schlecht

### Statistik-Werte sind falsch

**Problem**: Cp/Cpk sieht komisch aus

**Lösungen**:
1. Mindestens 10-20 Messwerte für sinnvolle σ
2. Prüfe: LSL=5.8, USL=7.2 (sind die Grenzen richtig?)
3. Prüfe: Dezimal-Trennzeichen (Punkt vs. Komma in CSV)

---

## 👥 Team & Kommunikation

| Rolle | Aufgaben | Tools |
|-------|----------|-------|
| **Project Manager** | Zeitplan, Milestones | Gantt-Charts, Jira |
| **Backend Dev** | Python API, Statistik | Python, FastAPI, Git |
| **Frontend Dev** | Flutter UI, App-Logic | Dart, Flutter, VS Code |
| **Data Scientist** | Analyse, Vorhersagen | Jupyter, Pandas, Matplotlib |
| **DevOps** | Deployment, Monitoring | Docker, Kubernetes, AWS |

### Zusammenarbeit mit Git

```powershell
# Branching
git checkout -b feature/sensor-export

# Commit
git add .
git commit -m "Add sensor data export to CSV"

# Push & Pull Request
git push origin feature/sensor-export
# → PR auf GitHub öffnen
```

---

## 📊 Phase-Übersicht (Projektfortschritt)

## 💾 Datenfluss

```
CSV-Datei (Messungen)
    ↓
AppData.load() (CSV parsen)
    ↓
SensorReading-Objekte (einzelne Messungen)
    ↓
Berechnungen (μ, σ, Cp, Cpk, Warnungen)
    ↓
UI (Dashboard/Analyse/Alerts/Info)
    ↓
Anzeige im Flutter-Fenster
```

---

## 🔧 Anpassung & Erweiterung

### pH-Spezifikation ändern?
Suche in `main.dart`:
```dart
static const double lsl = 5.8;
static const double usl = 7.2;
```
Ändere die Werte → Neue Grenzen für Warnungen

### Weitere Kennzahlen hinzufügen?
In `AppData` die Berechnungen erweitern, z.B.:
- Min/Max-Werte
- Trend-Analyse (steigt/fällt die pH über Zeit?)
- Vorhersagen mit Machine Learning

### Daten exportieren?
- CSV-Datei in Excel öffnen
- Grafen erstellen
- Reports generieren

---

## � Phase-Übersicht (Projektfortschritt)

| Phase | Titel | Status | Beschreibung |
|-------|-------|--------|-------------|
| 1-3 | Planung & Analyse | ✅ Abgeschlossen | Anforderungen, Design, Architektur |
| 4-6 | Basis-Implementierung | ✅ Abgeschlossen | CSV-Datei, Python-API, erste Flutter-Version |
| **7** | **Vollständige App** | 🔄 **In Bearbeitung** | Flutter-Desktop komplett, File-Watcher, Auto-Refresh, Input-Formular |
| 8 | Testing & Optimierung | ⏳ Geplant | Unit-Tests, Performance-Tests, Bug-Fixes |
| 9 | Deployment & Dokumentation | ⏳ Geplant | Produktiv-Setup, Schulung, Übergabe |

### Phase 7 – Aktuelle Arbeiten

✅ **Erledigt**:
- Flutter Windows Desktop App komplett funktionsfähig
- CSV-Parser mit `csv` Package (robust)
- File-Watcher mit Debouncer (Auto-Reload)
- Input-Formular für neue Messungen
- Refresh-Button in AppBar
- Alle 4 Screens (Dashboard, Analyse, Alerts, Info)
- Kennzahlen-Berechnung (μ, σ, Cp, Cpk)
- Python FastAPI Server komplett
- OpenAPI-Spezifikation

🔄 **Fortlaufend**:
- Dokumentation (diese README)
- Bug-Fixes
- Performance-Optimierung

⏳ **Geplant für nächste Phase**:
- Graphen / Charts in Flutter (pH-Trend über Zeit)
- Datenbankanbindung (statt nur CSV)
- API-Integration in Flutter (POST neue Messungen)
- Erweiterte Authentifizierung

---

## 🎓 Lernziele dieses Projekts

Nach dieser Dokumentation solltest du verstehen:

✅ **Technisches Wissen**:
- [x] Wie eine **Desktop-App** mit Flutter funktioniert
- [x] Wie eine **REST API** mit Python/FastAPI gebaut wird
- [x] **CSV-Datenformate** und deren Vor/Nachteile
- [x] **Statistische Kennzahlen** (Cp, Cpk, σ) für Qualitätskontrolle
- [x] **IoT-Grundkonzepte** (Sensoren, Datenerfassung)
- [x] **Dateioperationen** (Lesen, Schreiben, Beobachen)
- [x] **Architektur-Muster** (dezentralisiert vs. Server-basiert)

✅ **Soft Skills**:
- [x] Projektdokumentation schreiben
- [x] Code für andere verständlich machen
- [x] Multi-Component-Systeme designen
- [x] Fehlerbehebung & Troubleshooting

---

## 🎯 Nächste Schritte (Für Erweiterung)

### 1. Grafische Darstellung (Priorität: Hoch)
```dart
// In Flutter: Charts zeichnen
Line Chart: pH über die Zeit
Bar Chart: Sensoren-Vergleich
Heatmap: Feldkarte mit Sensoren
```

### 2. Mehrere Sensoren (Priorität: Hoch)
```
Aktuell: 1 Feld
Zukünftig: 3+ Felder, Vergleich, Aggregation
```

### 3. Datenbank statt CSV (Priorität: Mittel)
```
CSV → SQLite / PostgreSQL
Vorteile: Schneller, Queries, Transaktionen
Nachteil: Komplexer
```

### 4. API-Integration (Priorität: Mittel)
```
Flutter → POST /measurements → Python Server
Alternative zu "Formular ausfüllen"
```

### 5. Mobile App (Priorität: Niedrig)
```
iOS/Android App
Same Code-Base (Flutter)
```

---

## ✅ Zusammenfassung

### Was wurde gebaut?

Ein **modulares Smart Agriculture System** mit 3 Komponenten:

1. **Flutter Windows App**
   - Moderne, benutzerfreundliche Oberfläche
   - Live-Daten, Analyse, Warnungen
   - Automatisches Refresh
   - Daten-Eingabeformular

2. **Python FastAPI Backend**
   - REST API für Datenabfrage
   - Statistische Berechnungen
   - Alert-System
   - Erweiterbar für IoT-Integration

3. **CSV-Datenspeicher**
   - Zentrale, einfache Datenquelle
   - Kompatibel mit Excel, Python, etc.
   - Kein Datenbankserver nötig

### Warum diese Kombination?

| Aspekt | Entscheidung | Grund |
|--------|------------|-------|
| **Frontend** | Flutter | Cross-Platform, schnell, modern |
| **Backend** | Python | Data Science, einfach, Ökosystem |
| **Daten** | CSV | Simpel, portabel, Excel-kompatibel |
| **API** | FastAPI | Modern, automatische Docs, schnell |
| **Deploy** | Lokal + Optional | Flexibel für verschiedene Umgebungen |

### Was hat der Schüler gelernt?

- 🎓 **Software Engineering**: Architektur, API-Design, Testing
- 🎓 **Programmierung**: Dart, Python, SQL-Konzepte
- 🎓 **Datenverarbeitung**: Pandas, CSV, Statistik
- 🎓 **DevOps**: Git, Deployment, Monitoring
- 🎓 **IoT**: Sensoren, Datenerfassung, Real-time Verarbeitung

---

## 📞 Support & Kontakt

### Fragen zur Dokumentation?
Siehe Glossar oder Troubleshooting-Abschnitt.

### Bugs oder Probleme?
1. Fehler reproduzieren
2. Logs sammeln
3. Issue auf GitHub öffnen (wenn vorhanden)
4. Screenshots / Code-Ausschnitte mitteilen

### Feedback zur App?
- Welche Features fehlen?
- Ist die UI verständlich?
- Zu langsam? Zu schnell?

---

*Diese Dokumentation wird regelmäßig aktualisiert.*  
*Letzte Aktualisierung: Juni 2026*  
*Version: 1.0 (Phase 7)*

---

## 📄 Datei-Übersicht des Projekts

```
Agri_Culture_Project/
│
├── README.md                                    ← Du bist hier
├── api.yml                                      ← API-Spezifikation (OpenAPI)
├── main.py                                      ← Python FastAPI Server
├── smart_agriculture_measurements.csv           ← Datenspeicher
│
├── FLM_6AAME_Smart_Agriculture.ipynb           ← Jupyter Notebook (Analyse)
├── Zwischenpraesentation.md                    ← Projekt-Status
├── Projektsteckbrief FML.docx                  ← Formelle Beschreibung
│
├── flutter_app/                                 ← Flutter Windows App
│   ├── lib/
│   │   └── main.dart                           ← Kompletter App-Code
│   ├── test/
│   │   └── widget_test.dart                    ← Tests
│   ├── pubspec.yaml                            ← Abhängigkeiten
│   ├── windows/                                ← Windows-spezifisch
│   └── README.md                               ← App-Dokumentation
│
├── .git/                                        ← Git-Repository
└── __pycache__/                                 ← Python Cache

```

---

**Viel Erfolg beim Verstehen & Erweitern des Projekts! 🚀**

| Begriff | Erklärung |
|---------|-----------|
| **Analysieren** | Daten untersuchen, um Muster/Probleme zu erkennen. |
| **Bewässerung** | Künstliches Gießen von Pflanzen (True = aktiv, False = aus). |
| **Bodenfeuchte** | Wassermenge im Boden (in %). 40–60% meist optimal. |
| **CSV-Format** | Tabelle als Text (Spalten mit Komma trennen). |
| **Debounce** | Kurze Wartezeit (500ms), um mehrfache schnelle Events zu einem zusammenzufassen. |
| **Durchschnitt** | Summe ÷ Anzahl = Mittelwert. |
| **Flutter** | Framework zum Bauen von Desktop/Mobile-Apps mit Dart. |
| **Kennzahl** | Messgröße zur Bewertung von Prozessen (z.B. Cp, Cpk). |
| **Prozessfähigkeit** | Wie stabil läuft der Prozess? Sind Fehler selten oder häufig? |
| **Sensor** | Gerät, das physikalische Größen misst (z.B. Temperatur). |
| **Spezifikation** | Zulässiger Bereich für einen Wert (LSL–USL). |
| **Standardabweichung** | Maß für Streuung der Messwerte. |
| **Systemstatus** | Zustand der Überwachungs-Hardware (OK = alles normal). |
| **Toleranz** | Zulässiger Bereich. Zu eng → schwer erreichbar, zu weit → schlechte Qualität. |
| **Warnung** | Alert, wenn ein Messwert außerhalb des gewünschten Bereichs liegt. |

---


## 👨‍💼 Autor & Projekt

**Projekt**: Smart Agriculture Monitoring System  
**Phase**: 7 (Umsetzung)  
**Kurs**: IKA-KOLLEG Future Lab – Digital Industry  
**Semester**: 2025/2026  
**Schule**: IKA (Industrie- und Handelskammer)

---


*Dokumentation aktualisiert: Juni 2026*  
*Sinn: Diese Dokumentation hilft dir, das Projekt zu verstehen, zu erweitern und anderen zu erklären.*
