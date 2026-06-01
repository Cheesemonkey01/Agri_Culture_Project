Run the Windows desktop Flutter app and test adding measurements:

1. Open terminal and run:

```powershell
cd flutter_app
flutter run -d windows
```

2. In the app: Use the bottom right `Neue Messung anhängen` button to open a dialog and add real sensor values.

Notes:
- The app now uses the `csv` package for robust parsing of `smart_agriculture_measurements.csv`.
- The app watches the CSV file for changes and auto-reloads.
- To append programmatically, make sure to write CSV lines with the same header order: `timestamp,soilMoisture,soilTemperature,airTemperature,airHumidity,ph,irrigation,systemStatus`.
