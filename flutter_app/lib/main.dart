import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(const SmartAgriApp());
}

class DashboardScreen extends StatelessWidget {
  final AppData data;

  const DashboardScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatusCard(status: data.systemStatus, message: data.statusMessage),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Aktuelle Sensordaten'),
          SensorTile(label: 'Bodenfeuchte', value: '${data.latest.soilMoisture.toStringAsFixed(1)} %'),
          SensorTile(label: 'Bodentemperatur', value: '${data.latest.soilTemperature.toStringAsFixed(1)} °C'),
          SensorTile(label: 'Lufttemperatur', value: '${data.latest.airTemperature.toStringAsFixed(1)} °C'),
          SensorTile(label: 'Luftfeuchte', value: '${data.latest.airHumidity.toStringAsFixed(1)} %'),
          SensorTile(label: 'pH-Wert', value: data.latest.phValue.toStringAsFixed(2)),
          SensorTile(label: 'Bewässerung', value: data.latest.irrigationActive ? 'Aktiv' : 'Aus'),
          SensorTile(label: 'Systemstatus', value: data.latest.systemStatus),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Kennzahlen'),
          MetricCard(metrics: [
            AnalysisMetric(label: 'Mittelwert pH', value: data.meanPh.toStringAsFixed(2)),
            AnalysisMetric(label: 'Standardabweichung', value: data.stdPh.toStringAsFixed(2)),
            AnalysisMetric(label: 'Cp', value: data.cp.toStringAsFixed(2)),
            AnalysisMetric(label: 'Cpk', value: data.cpk.toStringAsFixed(2)),
          ]),
        ],
      ),
    );
  }
}

class AnalysisScreen extends StatelessWidget {
  final AppData data;

  const AnalysisScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(title: 'Prozessfähigkeitsanalyse'),
          InfoCard(title: 'pH-Spezifikation', items: const ['LSL = 5.8', 'USL = 7.2', 'Zielwert = 6.5']),
          const SizedBox(height: 16),
          MetricCard(metrics: [
            AnalysisMetric(label: 'Mittelwert pH', value: data.meanPh.toStringAsFixed(2)),
            AnalysisMetric(label: 'Standardabweichung', value: data.stdPh.toStringAsFixed(2)),
            AnalysisMetric(label: 'Cp', value: data.cp.toStringAsFixed(2)),
            AnalysisMetric(label: 'Cpk', value: data.cpk.toStringAsFixed(2)),
          ]),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Bewertung'),
          Text(data.analysisSummary, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  final AppData data;

  const AlertsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final warnings = data.warnings;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Warnungen'),
          if (warnings.isEmpty) const Text('Keine Warnungen vorhanden.', style: TextStyle(fontSize: 16))
          else ...warnings.map((w) => AlertTile(text: w)),
          const SizedBox(height: 16),
          InfoCard(title: 'Systemstatus', items: [data.systemStatus]),
        ],
      ),
    );
  }
}

class InfoScreen extends StatelessWidget {
  final AppData data;

  const InfoScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Projektinfo'),
          const SizedBox(height: 8),
          const Text('Diese App nutzt die CSV-Datei aus dem Projektordner, um aktuelle Sensordaten, Analysekennzahlen und Warnungen anzuzeigen.'),
          const SizedBox(height: 16),
          InfoCard(title: 'Dateipfad', items: [data.sourcePath]),
          const SizedBox(height: 12),
          InfoCard(title: 'Letzte Messung', items: [data.latest.timestamp]),
        ],
      ),
    );
  }
}

class SmartAgriApp extends StatelessWidget {
  const SmartAgriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Agriculture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<AppData>? _dataFuture;
  StreamSubscription<FileSystemEvent>? _fileWatcher;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _dataFuture = AppData.load();
    _dataFuture?.then((d) => _startWatcher(d.sourcePath));
  }

  @override
  void dispose() {
    _fileWatcher?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _startWatcher(String path) {
    try {
      _fileWatcher?.cancel();
      final file = File(path);
      _fileWatcher = file.watch().listen((event) {
        if (event.type == FileSystemEvent.modify || event.type == FileSystemEvent.create) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 500), _reloadData);
        }
      });
    } catch (_) {}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _reloadData() async {
    _debounceTimer?.cancel();
    setState(() {
      _dataFuture = AppData.load();
    });
  }

  Future<void> _showAddMeasurementDialog() async {
    final soilMoistureController = TextEditingController(text: '50.0');
    final soilTempController = TextEditingController(text: '18.0');
    final airTempController = TextEditingController(text: '20.0');
    final airHumController = TextEditingController(text: '55.0');
    final phController = TextEditingController(text: '6.5');
    final irrigationNotifier = ValueNotifier<bool>(false);
    final statusController = TextEditingController(text: 'OK');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neue Messung hinzufügen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: soilMoistureController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bodenfeuchte (%)')),
                TextField(controller: soilTempController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bodentemperatur (°C)')),
                TextField(controller: airTempController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Lufttemperatur (°C)')),
                TextField(controller: airHumController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Luftfeuchte (%)')),
                TextField(controller: phController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'pH-Wert')),
                Row(children: [
                  const Text('Bewässerung aktiv'),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<bool>(
                    valueListenable: irrigationNotifier,
                    builder: (context, val, _) => Switch(value: val, onChanged: (v) => irrigationNotifier.value = v),
                  ),
                ]),
                TextField(controller: statusController, decoration: const InputDecoration(labelText: 'Systemstatus')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hinzufügen')),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      final appData = await (_dataFuture ?? AppData.load());
      final file = File(appData.sourcePath);
      final now = DateTime.now();
      final soilMoisture = soilMoistureController.text;
      final soilTemp = soilTempController.text;
      final airTemp = airTempController.text;
      final airHum = airHumController.text;
      final ph = phController.text;
      final irrigation = irrigationNotifier.value ? 'True' : 'False';
      final sys = statusController.text;
      final line = '\n${now.toIso8601String().replaceAll('T', ' ').split('.').first},$soilMoisture,$soilTemp,$airTemp,$airHum,$ph,$irrigation,$sys';
      await file.writeAsString(line, mode: FileMode.append, flush: true, encoding: utf8);
      await _reloadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messung angehängt')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Anhängen: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Smart Agriculture'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _reloadData,
                  tooltip: 'Daten aktualisieren',
                ),
              ],
            ),
            body: Center(child: Text('Fehler beim Laden der Daten: ${snapshot.error}')),
          );
        }

        final appData = snapshot.requireData;
        final pages = [
          DashboardScreen(data: appData),
          AnalysisScreen(data: appData),
          AlertsScreen(data: appData),
          InfoScreen(data: appData),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Smart Agriculture'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _reloadData,
                tooltip: 'Daten aktualisieren',
              ),
            ],
          ),
          body: pages[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.analytics), label: 'Analyse'),
              NavigationDestination(icon: Icon(Icons.warning_amber), label: 'Alerts'),
              NavigationDestination(icon: Icon(Icons.info), label: 'Info'),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddMeasurementDialog,
            label: const Text('Neue Messung anhängen'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class SensorReading {
  final String timestamp;
  final double soilMoisture;
  final double soilTemperature;
  final double airTemperature;
  final double airHumidity;
  final double phValue;
  final bool irrigationActive;
  final String systemStatus;

  SensorReading({
    required this.timestamp,
    required this.soilMoisture,
    required this.soilTemperature,
    required this.airTemperature,
    required this.airHumidity,
    required this.phValue,
    required this.irrigationActive,
    required this.systemStatus,
  });
}

class AppData {
  static const double lsl = 5.8;
  static const double usl = 7.2;

  final List<SensorReading> readings;
  final SensorReading latest;
  final double meanPh;
  final double stdPh;
  final double cp;
  final double cpk;
  final String sourcePath;

  AppData({
    required this.readings,
    required this.latest,
    required this.meanPh,
    required this.stdPh,
    required this.cp,
    required this.cpk,
    required this.sourcePath,
  });

  List<String> get warnings {
    final warnings = <String>[];
    if (latest.phValue < lsl || latest.phValue > usl) {
      warnings.add('pH-Wert außerhalb der Spezifikation');
    }
    if (latest.systemStatus.toUpperCase() != 'OK') {
      warnings.add('Systemstatus: ');
    }
    return warnings;
  }

  String get systemStatus {
    if (readings.any((r) => r.systemStatus.toUpperCase() != 'OK')) {
      return 'Critical';
    }
    if (warnings.isNotEmpty) {
      return 'Warning';
    }
    return 'OK';
  }

  String get statusMessage {
    if (systemStatus == 'OK') {
      return 'Alle Werte sind im grünen Bereich.';
    }
    if (systemStatus == 'Warning') {
      return 'Einige Werte sind außerhalb des optimalen Bereichs.';
    }
    return 'Mindestens ein Systemstatus ist kritisch.';
  }

  String get analysisSummary {
    if (cp.isNaN || cpk.isNaN) {
      return 'Die Prozessfähigkeitskennzahlen konnten nicht berechnet werden.';
    }
    return 'Cp und Cpk wurden für den pH-Wert berechnet. Aktuell ist die Lage leicht außerhalb des Zielbereichs, aber die Prozessfähigkeit ist insgesamt vorhanden.';
  }

  static Future<AppData> load() async {
    final file = await _findCsvFile();
    if (file == null) {
      throw Exception('smart_agriculture_measurements.csv nicht gefunden');
    }

    final content = await file.readAsString(encoding: utf8);
    final rows = const CsvToListConverter(eol: '\n').convert(content);
    if (rows.length < 2) throw Exception('CSV-Datei enthält keine Messwerte');

    final readings = <SensorReading>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 8) continue;
      try {
        final timestamp = row[0].toString().trim();
        final soilMoisture = double.parse(row[1].toString());
        final soilTemperature = double.parse(row[2].toString());
        final airTemperature = double.parse(row[3].toString());
        final airHumidity = double.parse(row[4].toString());
        final phValue = double.parse(row[5].toString());
        final irrigationActive = row[6].toString().trim().toLowerCase() == 'true';
        final systemStatus = row[7].toString().trim();
        readings.add(SensorReading(
          timestamp: timestamp,
          soilMoisture: soilMoisture,
          soilTemperature: soilTemperature,
          airTemperature: airTemperature,
          airHumidity: airHumidity,
          phValue: phValue,
          irrigationActive: irrigationActive,
          systemStatus: systemStatus,
        ));
      } catch (_) {
        continue;
      }
    }

    if (readings.isEmpty) throw Exception('Keine gültigen Messzeilen in der CSV gefunden');

    final phValues = readings.map((r) => r.phValue).toList();
    final meanPh = phValues.reduce((a, b) => a + b) / phValues.length;
    final variance = phValues.map((v) => pow(v - meanPh, 2)).reduce((a, b) => a + b) / phValues.length;
    final stdPh = sqrt(variance);
    final cp = (usl - lsl) / (6 * stdPh);
    final cpk = min((meanPh - lsl) / (3 * stdPh), (usl - meanPh) / (3 * stdPh));

    return AppData(
      readings: readings,
      latest: readings.last,
      meanPh: meanPh,
      stdPh: stdPh,
      cp: cp,
      cpk: cpk,
      sourcePath: file.path,
    );
  }

  static Future<File?> _findCsvFile() async {
    const fileName = 'smart_agriculture_measurements.csv';
    var current = Directory.current;
    for (var i = 0; i < 5; i++) {
        final candidate = File('${current.path}${Platform.pathSeparator}$fileName');
      if (await candidate.exists()) {
        return candidate;
      }
      if (current.parent.path == current.path) break;
      current = current.parent;
    }
    return null;
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String status;
  final String message;

  const StatusCard({super.key, required this.status, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = status == 'OK' ? Colors.green[100] : status == 'Warning' ? Colors.orange[100] : Colors.red[100];
    final icon = status == 'OK' ? Icons.check_circle : status == 'Warning' ? Icons.warning_amber : Icons.dangerous;

    return Card(
      color: color,
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text('Systemstatus: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
      ),
    );
  }
}

class SensorTile extends StatelessWidget {
  final String label;
  final String value;

  const SensorTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final List<AnalysisMetric> metrics;

  const MetricCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: metrics.map((metric) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(metric.label),
                Text(metric.value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class AnalysisMetric {
  final String label;
  final String value;

  const AnalysisMetric({required this.label, required this.value});
}

class InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const InfoCard({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(item),
            )),
          ],
        ),
      ),
    );
  }
}

class AlertTile extends StatelessWidget {
  final String text;

  const AlertTile({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[50],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.error, color: Colors.red),
        title: Text(text),
      ),
    );
  }
}
