import 'package:flutter/material.dart';
import 'package:healthtracker/models/health_record.dart';

import 'statistics_screen.dart';
import 'home_screen.dart';
import 'all_records_screen.dart';

class MainScreen extends StatefulWidget {
  final List<HealthRecord> records;
  const MainScreen({super.key, required this.records});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;
  late List<HealthRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = widget.records;
    _widgetOptions = <Widget>[
      StatisticsScreen(records: _records),
      AllRecordsScreen(records: _records),
      HomeScreen(onRecordAdded: (newRecord) {
        setState(() {
          _records.add(newRecord);
        });
      }),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Extend body behind navigation bar
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[900]!, Colors.grey[850]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _widgetOptions.elementAt(_selectedIndex),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'All Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'Add Record',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
