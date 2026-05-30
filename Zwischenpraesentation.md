# Zwischenpräsentation: Smart Agriculture API

## 1. Projektübersicht

### Ziel
Entwicklung einer einfachen API für Smart Agriculture Messdaten mit:
- Sensordaten-Ausgabe (`/sensors`)
- Statistikberechnung (`/statistics`)
- Alert-Erzeugung (`/alerts`)
- Gesundheitsprüfung (`/health`)
- Login-Funktion (`/login`)

### Aktueller Stand
Die API ist in `main.py` implementiert und liest Messwerte aus `smart_agriculture_measurements.csv`. Eine OpenAPI-Beschreibung wurde in `api.yml` definiert.

---

## 2. Sicherheitsanalyse

### Wichtige Schwachstellen
1. **Demo-Authentifizierung mit hardcodierten Zugangsdaten**
   - Nutzername und Passwort stehen direkt im Code.
   - Token ist statisch und es gibt keine echte Sitzungsprüfung.
   - Risiko: Unbefugter Zugriff auf die API.

2. **Offene CORS-Policy**
   - `allow_origins=["*"]` erlaubt Zugriff aus beliebigen Domains.
   - Risiko: Browser können beliebigen Frontends Zugriff auf die API gewähren.

3. **Fehlendes HTTPS/TLS**
   - Die API wird aktuell nur über HTTP betrieben.
   - Risiko: Daten können abgehört oder manipuliert werden.

4. **Unzureichende Eingabevalidierung**
   - Login-Daten werden nur als generisches `Dict[str, str]` angenommen.
   - Risiko: Fehlerhafte Eingabe und mögliche Angriffsvektoren.

5. **Fehlendes Dependency-Management**
   - Keine `requirements.txt` oder `pyproject.toml` vorhanden.
   - Risiko: Unsichere oder ungeprüfte Bibliotheken.

6. **Kein Logging/Audit**
   - Zugriffe und Authentifizierungsversuche werden nicht protokolliert.
   - Risiko: Angriffe können nicht entdeckt oder nachvollzogen werden.

---

## 3. Risiko-Matrix

| Schwachstelle | Risiko | Eintrittswahrscheinlichkeit | Auswirkung | Bewertung | Gegenmaßnahmen |
|---|---|---|---|---|---|
| Demo-Authentifizierung mit hardcodierten Zugangsdaten | Unbefugter Zugriff | Hoch | Hoch | Kritisch | Echte Authentifizierung, Passwort-Hashing, Nutzerverwaltung |
| Offene CORS-Policy (`allow_origins=["*"]`) | Cross-Origin-Zugriff durch beliebige Herkunft | Hoch | Mittel | Hoch | CORS auf bekannte Domains eingrenzen |
| Keine HTTPS/TLS-Konfiguration | Abhören und Manipulation im Netz | Hoch | Hoch | Kritisch | API nur über TLS bereitstellen, z.B. Reverse-Proxy mit Zertifikat |
| Ungeprüfte Eingaben / fehlende Pydantic-Validierung | Invalid input / Injection | Mittel | Mittel | Mittel | Pydantic-Modelle für Input verwenden, Feldgrößen einschränken |
| Fehlende Abhängigkeitsdefinition (`requirements.txt`/`pyproject.toml`) | Unsichere Bibliotheken, schwer prüfbar | Mittel | Mittel | Mittel | Abhängigkeiten festschreiben und regelmäßig prüfen |
| Unzureichendes Error-Handling | Informationsleak / Debug-Infos | Mittel | Mittel | Mittel | Fehler sauber abfangen, keine internen Details veröffentlichen |
| Kein Logging/Audit | Erkennen von Angriffen schwierig | Mittel | Mittel | Mittel | Authentifizierungs- und API-Zugriffe protokollieren |
| Keine Zugriffsbeschränkung auf Sensordaten | Unautorisierter Datenzugriff | Mittel | Mittel | Mittel | Rollen-/Token-basierte Zugriffskontrolle implementieren |

---

## 4. Priorisierte Maßnahmen

### Sofort umsetzen
- Sicheres Login-System mit Nutzerverwaltung und gehashten Passwörtern
- HTTPS/TLS für die API einführen
- CORS auf erlaubte Domains einschränken

### Kurzfristig
- Eingabevalidierung mit Pydantic-Modellen
- Fehlerbehandlung verbessern
- Logging und Audit einbauen

### Mittelfristig
- Abhängigkeiten festschreiben und Sicherheitsupdates prüfen
- Zugriffskontrolle für sensible Endpunkte einführen
- Struktur für Produktionsbetrieb anpassen (z. B. Reverse-Proxy, Secrets-Management)

---

## 5. Fazit
Die aktuelle API ist funktional, aber aus Sicht der Cybersecurity noch nicht produktionsreif. Die größten Risiken sind die unsichere Authentifizierung, die offene CORS-Konfiguration und das Fehlen von TLS. Mit gezielten Maßnahmen lässt sich der Schutz deutlich verbessern.
