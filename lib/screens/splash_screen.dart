import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthtracker/models/health_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<HealthRecord> records;

    if (kDebugMode) {
      final String jsonString = await rootBundle.loadString('assets/temp_data.json');
      final List<dynamic> jsonResponse = json.decode(jsonString);
      records = jsonResponse.map((record) => HealthRecord.fromMap(record)).toList();
      await prefs.setString('healthData', jsonEncode(records.map((r) => r.toMap()).toList()));
    } else {
      final healthDataString = prefs.getString('healthData');
      if (healthDataString != null) {
        final List<dynamic> decodedData = jsonDecode(healthDataString);
        records = decodedData.map((e) => HealthRecord.fromMap(Map<String, dynamic>.from(e))).toList();
      } else {
        records = [];
      }
    }

    Timer(
      const Duration(seconds: 5),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => MainScreen(records: records)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 20),
            Text('HealthTracker', style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
      ),
    );
  }
}
