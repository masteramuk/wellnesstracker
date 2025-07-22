import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:healthtracker/models/blood_pressure_record.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class BloodPressureDataScreen extends StatefulWidget {
  const BloodPressureDataScreen({super.key});

  @override
  _BloodPressureDataScreenState createState() =>
      _BloodPressureDataScreenState();
}

class _BloodPressureDataScreenState extends State<BloodPressureDataScreen> {
  List<BloodPressureRecord> _records = [];
  List<BloodPressureRecord> _filteredRecords = [];
  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  DateTime? _startDate;
  DateTime? _endDate;
  BloodPressureStatus? _selectedStatus;

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
          _filteredRecords = _records;
        });
      }
    } else {
      try {
        final file = await _localFile;
        final contents = await file.readAsString();
        final List<dynamic> json = jsonDecode(contents);
        setState(() {
          _records = json.map((e) => BloodPressureRecord.fromJson(e)).toList();
          _filteredRecords = _records;
        });
      } catch (e) {
        if (e is PathNotFoundException || e is FileSystemException) {
          await _saveRecords([]);
        } else {
          print('Error loading records: $e');
        }
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

  Future<void> _saveRecords(List<BloodPressureRecord> records) async {
    final json = records.map((e) => e.toJson()).toList();
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('blood_pressure_records', jsonEncode(json));
    } else {
      final file = await _localFile;
      await file.writeAsString(jsonEncode(json));
    }
  }

  Future<void> _addRecord(BloodPressureRecord record) async {
    _records.add(record);
    await _saveRecords(_records);
    _filterRecords();
  }

  void _filterRecords() {
    setState(() {
      _filteredRecords = _records.where((record) {
        final recordDate = record.date;
        if (_startDate != null && recordDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null &&
            recordDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }
        if (_selectedStatus != null &&
            getBloodPressureStatus(record.systolic, record.diastolic) !=
                _selectedStatus) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Pearl white
      appBar: AppBar(
        title: const Text('Blood Pressure'),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildDataTable(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRecordDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                  _filterRecords();
                });
              }
            },
            child: const Text('Filter by Date'),
          ),
          DropdownButton<BloodPressureStatus>(
            hint: const Text('Filter by Status'),
            value: _selectedStatus,
            onChanged: (BloodPressureStatus? newValue) {
              setState(() {
                _selectedStatus = newValue;
                _filterRecords();
              });
            },
            items: BloodPressureStatus.values
                .map((BloodPressureStatus status) {
              return DropdownMenuItem<BloodPressureStatus>(
                value: status,
                child: Row(
                  children: [
                    getStatusIcon(status),
                    const SizedBox(width: 8),
                    Text(status.toString().split('.').last.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ')
.replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase())),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return PaginatedDataTable(
      header: const Text('Blood Pressure Records'),
      rowsPerPage: _rowsPerPage,
      onRowsPerPageChanged: (value) {
        setState(() {
          _rowsPerPage = value!;
        });
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        DataColumn(
          label: Text('Date', style: TextStyle(color: Theme.of(context).primaryColor)),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
              _filteredRecords.sort((a, b) =>
                  a.date.compareTo(b.date) * (ascending ? 1 : -1));
            });
          },
        ),
        DataColumn(label: Text('Time', style: TextStyle(color: Theme.of(context).primaryColor))),
        DataColumn(label: Text('Systolic', style: TextStyle(color: Theme.of(context).primaryColor))),
        DataColumn(label: Text('Diastolic', style: TextStyle(color: Theme.of(context).primaryColor))),
        DataColumn(label: Text('Pulse', style: TextStyle(color: Theme.of(context).primaryColor))),
        DataColumn(label: Text('Healthy', style: TextStyle(color: Theme.of(context).primaryColor))),
      ],
      source: _DataSource(context, _filteredRecords),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final pulseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.favorite),
              SizedBox(width: 8),
              Text('Add New Data'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: systolicController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: const InputDecoration(labelText: 'Systolic'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diastolicController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: const InputDecoration(labelText: 'Diastolic'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: pulseController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: const InputDecoration(labelText: 'Pulse'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newRecord = BloodPressureRecord(
                  date: DateTime.now(),
                  systolic: int.parse(systolicController.text),
                  diastolic: int.parse(diastolicController.text),
                  pulse: int.parse(pulseController.text),
                );
                _addRecord(newRecord);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _DataSource extends DataTableSource {
  final BuildContext context;
  final List<BloodPressureRecord> _records;

  _DataSource(this.context, this._records);

  @override
  DataRow getRow(int index) {
    final record = _records[index];
    final status = getBloodPressureStatus(record.systolic, record.diastolic);
    return DataRow(cells: [
      DataCell(Text(DateFormat('yyyy-MM-dd').format(record.date))),
      DataCell(Text(DateFormat('HH:mm').format(record.date))),
      DataCell(Text(record.systolic.toString())),
      DataCell(Text(record.diastolic.toString())),
      DataCell(Text(record.pulse.toString())),
      DataCell(getStatusIcon(status)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _records.length;

  @override
  int get selectedRowCount => 0;
}