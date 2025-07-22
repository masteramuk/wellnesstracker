import 'package:flutter/material.dart';
import 'package:healthtracker/models/health_record.dart';
import 'package:healthtracker/screens/dashboard/overall_statistics_screen.dart';
import 'package:healthtracker/screens/dashboard/blood_pressure_screen.dart';
import 'package:healthtracker/screens/dashboard/sugar_measurement_screen.dart';
import 'package:healthtracker/screens/dashboard/pulse_rate_screen.dart';
import 'package:healthtracker/screens/dashboard/calories_in_screen.dart';
import 'package:healthtracker/screens/dashboard/calories_out_screen.dart';
import 'package:healthtracker/screens/dashboard/wellness_value_screen.dart';
import 'package:healthtracker/screens/reports/all_records_screen.dart';
import 'package:healthtracker/screens/reports/blood_pressure_report_screen.dart';
import 'package:healthtracker/screens/reports/sugar_measurement_report_screen.dart';
import 'package:healthtracker/screens/reports/pulse_rate_report_screen.dart';
import 'package:healthtracker/screens/reports/calories_in_report_screen.dart';
import 'package:healthtracker/screens/reports/calories_out_report_screen.dart';
import 'package:healthtracker/screens/reports/wellness_report_screen.dart';
import 'package:healthtracker/screens/data/calories_in_data_screen.dart';
import 'package:healthtracker/screens/data/calories_out_data_screen.dart';
import 'package:healthtracker/screens/data/blood_pressure_data_screen.dart';
import 'package:healthtracker/screens/data/sugar_data_screen.dart';
import 'package:healthtracker/screens/data/pulse_data_screen.dart';
import 'package:healthtracker/screens/data/calories_value_data_screen.dart';
import 'package:healthtracker/screens/data/wellness_data_screen.dart';
import 'package:healthtracker/screens/user_profile_screen.dart';
import 'package:healthtracker/widgets/side_menu.dart';

class MainScreen extends StatefulWidget {
  final List<HealthRecord> records;
  const MainScreen({super.key, required this.records});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isMenuExpanded = true;

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return OverallStatisticsScreen(records: widget.records);
      case 1:
        return const BloodPressureScreen();
      case 2:
        return const SugarMeasurementScreen();
      case 3:
        return const PulseRateScreen();
      case 4:
        return const CaloriesInScreen();
      case 5:
        return const CaloriesOutScreen();
      case 6:
        return const WellnessValueScreen();
      case 10:
        return AllRecordsScreen(records: widget.records);
      case 11:
        return const BloodPressureReportScreen();
      case 12:
        return const SugarMeasurementReportScreen();
      case 13:
        return const PulseRateReportScreen();
      case 14:
        return const CaloriesInReportScreen();
      case 15:
        return const CaloriesOutReportScreen();
      case 16:
        return const WellnessReportScreen();
      case 20:
        return const UserProfileScreen();
      case 21:
        return const CaloriesInDataScreen();
      case 22:
        return const CaloriesOutDataScreen();
      case 23:
        return const BloodPressureDataScreen();
      case 24:
        return const SugarDataScreen();
      case 25:
        return const PulseDataScreen();
      case 26:
        return const CaloriesValueDataScreen();
      case 27:
        return const WellnessDataScreen();
      default:
        return OverallStatisticsScreen(records: widget.records);
    }
  }

  void _onMenuItemClicked(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuExpanded = !_isMenuExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleMenu,
        ),
        title: const Text('Health Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_profile',
                child: Text('Edit Profile'),
              ),
              const PopupMenuItem(
                value: 'change_password',
                child: Text('Change Password'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              // Handle menu selection
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPhone = constraints.maxWidth < 600;
          return Row(
            children: [
              SideMenu(
                isExpanded: !isPhone,
                onMenuItemClicked: _onMenuItemClicked,
              ),
              Expanded(
                child: _getSelectedScreen(),
              ),
            ],
          );
        },
      ),
    );
  }
}
