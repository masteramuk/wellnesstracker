import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthtracker/models/blood_pressure_record.dart';
import 'package:healthtracker/screens/data/blood_pressure_data_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  _BloodPressureScreenState createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  List<BloodPressureRecord> _records = [];
  BloodPressureRecord? _latestRecord;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('blood_pressure_records');
      if (jsonString != null) {
        final List<dynamic> json = jsonDecode(jsonString);
        setState(() {
          _records = json.map((e) => BloodPressureRecord.fromJson(e)).toList();
          if (_records.isNotEmpty) {
            _latestRecord = _records.last;
          }
        });
      }
    } else {
      try {
        final file = await _localFile;
        final contents = await file.readAsString();
        final List<dynamic> json = jsonDecode(contents);
        setState(() {
          _records = json.map((e) => BloodPressureRecord.fromJson(e)).toList();
          if (_records.isNotEmpty) {
            _latestRecord = _records.last;
          }
        });
      } catch (e) {
        print('Error loading records: $e');
      }
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/blood_pressure_records.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Pressure Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BloodPressureDataScreen(),
                ),
              );
              _loadRecords();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentStatus(),
            const SizedBox(height: 20),
            _buildHistoricalChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus() {
    if (_latestRecord == null) {
      return const Center(child: Text('No data available.'));
    }

    final status = getBloodPressureStatus(
      _latestRecord!.systolic,
      _latestRecord!.diastolic,
    );
    final color = getStatusColor(status);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Reading',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '${_latestRecord!.systolic}/${_latestRecord!.diastolic} mmHg',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
            ),
            const SizedBox(height: 5),
            Text(
              'Pulse: ${_latestRecord!.pulse} BPM',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              status.toString().split('.').last.toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricalChart() {
    if (_records.isEmpty) {
      return const Center(child: Text('No historical data.'));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _records.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.systolic.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: _records.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.diastolic.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}