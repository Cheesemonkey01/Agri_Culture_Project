from fastapi import FastAPI, HTTPException, status
from datetime import datetime
from pathlib import Path
from typing import List, Dict
import pandas as pd
import uvicorn
from fastapi.middleware.cors import CORSMiddleware

DATA_FILE = Path(__file__).parent / "smart_agriculture_measurements.csv"
app = FastAPI(title="Smart Agriculture API", version="1.0")

app.add_middleware(
  CORSMiddleware,
  allow_origins=["*"],
  allow_credentials=True,
  allow_methods=["*"],
  allow_headers=["*"],
)

def load_measurements() -> pd.DataFrame:
    if not DATA_FILE.exists():
        raise FileNotFoundError(f"{DATA_FILE} not found")
    df = pd.read_csv(DATA_FILE, parse_dates=["timestamp"] )
    return df


def latest_measurement(df: pd.DataFrame) -> Dict:
    row = df.iloc[-1]
    return {
        "timestamp": row["timestamp"].isoformat(),
        "soil_moisture_percent": float(row["soil_moisture_percent"]),
        "soil_temperature_c": float(row["soil_temperature_c"]),
        "air_temperature_c": float(row["air_temperature_c"]),
        "air_humidity_percent": float(row["air_humidity_percent"]),
        "ph_value": float(row["ph_value"]),
        "irrigation_active": bool(row["irrigation_active"]),
        "system_status": str(row["system_status"]),
    }


def compute_statistics(df: pd.DataFrame) -> Dict:
    ph = df["ph_value"]
    moisture = df["soil_moisture_percent"]
    sigma = float(ph.std(ddof=0))
    mean = float(ph.mean())
    lsl = 5.8
    usl = 7.2
    cpk = min((usl - mean) / (3 * sigma), (mean - lsl) / (3 * sigma)) if sigma > 0 else 0.0
    return {
        "sample_count": int(len(df)),
        "ph_mean": round(mean, 3),
        "ph_median": round(float(ph.median()), 3),
        "ph_std": round(sigma, 3),
        "ph_variance": round(float(ph.var(ddof=0)), 3),
        "ph_cpl": round((mean - lsl) / (3 * sigma), 3) if sigma > 0 else None,
        "ph_cpu": round((usl - mean) / (3 * sigma), 3) if sigma > 0 else None,
        "ph_cp": round((usl - lsl) / (6 * sigma), 3) if sigma > 0 else None,
        "ph_cpk": round(cpk, 3),
        "soil_moisture_mean": round(float(moisture.mean()), 2),
        "soil_moisture_min": round(float(moisture.min()), 2),
        "soil_moisture_max": round(float(moisture.max()), 2),
    }


def build_alerts(measurement: Dict) -> List[Dict]:
    alerts: List[Dict] = []
    ph_value = measurement["ph_value"]
    soil_moisture = measurement["soil_moisture_percent"]
    air_temp = measurement["air_temperature_c"]
    if ph_value < 5.8:
        alerts.append({"timestamp": measurement["timestamp"], "type": "PH_TOO_LOW", "severity": "HIGH", "message": "pH below lower specification limit"})
    elif ph_value > 7.2:
        alerts.append({"timestamp": measurement["timestamp"], "type": "PH_TOO_HIGH", "severity": "HIGH", "message": "pH above upper specification limit"})
    if soil_moisture < 35:
        alerts.append({"timestamp": measurement["timestamp"], "type": "SOIL_DRY", "severity": "MEDIUM", "message": "Bodenfeuchte zu niedrig"})
    if air_temp > 28:
        alerts.append({"timestamp": measurement["timestamp"], "type": "AIR_TEMP_HIGH", "severity": "MEDIUM", "message": "Lufttemperatur zu hoch"})
    if measurement["system_status"] != "OK":
        alerts.append({"timestamp": measurement["timestamp"], "type": "SYSTEM_ALERT", "severity": "HIGH", "message": "Systemstatus ist nicht OK"})
    return alerts


@app.get("/health")
def health() -> Dict:
    return {"status": "ok", "timestamp": datetime.utcnow().isoformat()}


@app.get("/sensors")
def sensors(limit: int = 10) -> Dict:
    df = load_measurements()
    recent = df.sort_values("timestamp", ascending=False).head(limit)
    return {"count": int(len(recent)), "data": recent.to_dict(orient="records")}


@app.get("/statistics")
def statistics() -> Dict:
    df = load_measurements()
    return compute_statistics(df)


@app.get("/alerts")
def alerts() -> Dict:
    df = load_measurements()
    latest = latest_measurement(df)
    return {"alerts": build_alerts(latest), "latest_measurement": latest}


@app.post("/login")
def login(credentials: Dict[str, str]) -> Dict:
    username = credentials.get("username")
    password = credentials.get("password")
    if username == "abc" and password == "123":
        return {"access_token": "demo-token", "token_type": "bearer"}
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Ungültige Anmeldedaten")


@app.get("/")
def root() -> Dict:
    return {"message": "Smart Agriculture API ist bereit. Verwende /health, /sensors, /statistics, /alerts, /login."}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)