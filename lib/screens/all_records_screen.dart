import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/health_record.dart';

class AllRecordsScreen extends StatefulWidget {
  final List<HealthRecord> records;
  const AllRecordsScreen({super.key, required this.records});

  @override
  State<AllRecordsScreen> createState() => _AllRecordsScreenState();
}

class _AllRecordsScreenState extends State<AllRecordsScreen> {
  List<HealthRecord> _allRecords = [];
  List<HealthRecord> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortColumn = 'timestamp';
  bool _sortAscending = false;
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _allRecords = widget.records;
    _filteredRecords = _allRecords;
    _sortRecords();
    _searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRecords);
    _searchController.dispose();
    super.dispose();
  }

  void _filterRecords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        return record.timestamp.toString().toLowerCase().contains(query) ||
               (record.systolic?.toString().contains(query) ?? false) ||
               (record.diastolic?.toString().contains(query) ?? false) ||
               (record.sugar?.toString().contains(query) ?? false) ||
               (record.heartRate?.toString().contains(query) ?? false) ||
               (record.totalCalories.toString().contains(query)) ||
               (record.exerciseCalories?.toString().contains(query) ?? false);
      }).toList();
      _sortRecords();
    });
  }

  void _sortRecords() {
    _filteredRecords.sort((a, b) {
      int comparison = 0;
      switch (_sortColumn) {
        case 'systolic':
          comparison = (a.systolic ?? 0).compareTo(b.systolic ?? 0);
          break;
        case 'diastolic':
          comparison = (a.diastolic ?? 0).compareTo(b.diastolic ?? 0);
          break;
        case 'sugar':
          comparison = (a.sugar ?? 0).compareTo(b.sugar ?? 0);
          break;
        case 'heartRate':
          comparison = (a.heartRate ?? 0).compareTo(b.heartRate ?? 0);
          break;
        case 'calories':
          comparison = (a.totalCalories).compareTo(b.totalCalories);
          break;
        case 'steps':
          comparison = (a.steps ?? 0).compareTo(b.steps ?? 0);
          break;
        case 'exerciseCalories':
          comparison = (a.exerciseCalories ?? 0).compareTo(b.exerciseCalories ?? 0);
          break;
        case 'timestamp':
        default:
          comparison = a.timestamp.compareTo(b.timestamp);
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
      _sortRecords();
    });
  }

  Future<void> _exportToCsv() async {
    List<List<dynamic>> rows = [];
    rows.add(['Date', 'Time', 'Meal Time', 'Systolic BP', 'Diastolic BP', 'Sugar', 'Heart Rate', 'Calories In', 'Steps', 'Exercise', 'Calories Out', 'Mental', 'Spiritual']);
    for (var record in _filteredRecords) {
      rows.add([
        DateFormat.yMd().format(record.timestamp),
        DateFormat.jm().format(record.timestamp),
        record.mealTime,
        record.systolic,
        record.diastolic,
        record.sugar,
        record.heartRate,
        record.totalCalories,
        record.steps,
        record.exerciseType,
        record.exerciseCalories,
        record.mentalHealth,
        record.spiritualHealth
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'health_records.csv';
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/health_records.csv";
      final file = File(path);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to $path')),
      );
    }
  }

  

  Map<String, double> _getSummary() {
    if (_filteredRecords.isEmpty) return {};
    double totalSystolic = 0, totalDiastolic = 0, totalSugar = 0, totalHr = 0, totalCalories = 0, totalSteps = 0, totalExerciseCalories = 0;
    double minSystolic = double.maxFinite, maxSystolic = 0, minDiastolic = double.maxFinite, maxDiastolic = 0, minSugar = double.maxFinite, maxSugar = 0, minHr = double.maxFinite, maxHr = 0, minCalories = double.maxFinite, maxCalories = 0, minSteps = double.maxFinite, maxSteps = 0, minExerciseCalories = double.maxFinite, maxExerciseCalories = 0;

    for (var record in _filteredRecords) {
        totalSystolic += record.systolic ?? 0;
        totalDiastolic += record.diastolic ?? 0;
        totalSugar += record.sugar ?? 0;
        totalHr += record.heartRate ?? 0;
        totalCalories += record.totalCalories;
        totalSteps += record.steps ?? 0;
        totalExerciseCalories += record.exerciseCalories ?? 0;

        if((record.systolic ?? 0) < minSystolic) minSystolic = record.systolic ?? 0;
        if((record.systolic ?? 0) > maxSystolic) maxSystolic = record.systolic ?? 0;
        if((record.diastolic ?? 0) < minDiastolic) minDiastolic = record.diastolic ?? 0;
        if((record.diastolic ?? 0) > maxDiastolic) maxDiastolic = record.diastolic ?? 0;
        if((record.sugar ?? 0) < minSugar) minSugar = record.sugar ?? 0;
        if((record.sugar ?? 0) > maxSugar) maxSugar = record.sugar ?? 0;
        if((record.heartRate ?? 0) < minHr) minHr = record.heartRate ?? 0;
        if((record.heartRate ?? 0) > maxHr) maxHr = record.heartRate ?? 0;
        if(record.totalCalories < minCalories) minCalories = record.totalCalories.toDouble();
        if(record.totalCalories > maxCalories) maxCalories = record.totalCalories.toDouble();
        if((record.steps ?? 0) < minSteps) minSteps = (record.steps ?? 0).toDouble();
        if((record.steps ?? 0) > maxSteps) maxSteps = (record.steps ?? 0).toDouble();
        if((record.exerciseCalories ?? 0) < minExerciseCalories) minExerciseCalories = (record.exerciseCalories ?? 0).toDouble();
        if((record.exerciseCalories ?? 0) > maxExerciseCalories) maxExerciseCalories = (record.exerciseCalories ?? 0).toDouble();
    }
    int count = _filteredRecords.length;
    return {
        'avgSystolic': totalSystolic / count,
        'avgDiastolic': totalDiastolic / count,
        'avgSugar': totalSugar / count,
        'avgHr': totalHr / count,
        'avgCalories': totalCalories / count,
        'avgSteps': totalSteps / count,
        'avgExerciseCalories': totalExerciseCalories / count,
        'minSystolic': minSystolic, 'maxSystolic': maxSystolic,
        'minDiastolic': minDiastolic, 'maxDiastolic': maxDiastolic,
        'minSugar': minSugar, 'maxSugar': maxSugar,
        'minHr': minHr, 'maxHr': maxHr,
        'minCalories': minCalories, 'maxCalories': maxCalories,
        'minSteps': minSteps, 'maxSteps': maxSteps,
        'minExerciseCalories': minExerciseCalories, 'maxExerciseCalories': maxExerciseCalories,
    };
  }

  @override
  Widget build(BuildContext context) {
    final summary = _getSummary();
    final int totalRecords = _filteredRecords.length;
    final int totalPages = (totalRecords / _rowsPerPage).ceil();
    final int startIndex = _currentPage * _rowsPerPage;
    final int endIndex = startIndex + _rowsPerPage > totalRecords ? totalRecords : startIndex + _rowsPerPage;
    final List<HealthRecord> pagedRecords = _filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('All Health Records'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.download_rounded), onPressed: _exportToCsv, tooltip: 'Export to CSV'),
          
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Search...', prefixIcon: Icon(Icons.search, color: Colors.white70)),
            ),
          ),
          _buildSummaryRow(summary),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: ['timestamp', 'systolic', 'diastolic', 'sugar', 'heartRate', 'calories', 'steps', 'exerciseCalories'].indexOf(_sortColumn),
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(label: const Text('#', style: TextStyle(color: Colors.white, fontSize: 10))), 
                  DataColumn(label: const Text('Date', style: TextStyle(color: Colors.white, fontSize: 10)), onSort: (i, asc) => _onSort('timestamp')),
                  DataColumn(label: const Text('Sys', style: TextStyle(color: Colors.white, fontSize: 10)), numeric: true, onSort: (i, asc) => _onSort('systolic')),
                  DataColumn(label: const Text('Dia', style: TextStyle(color: Colors.white, fontSize: 10)), numeric: true, onSort: (i, asc) => _onSort('diastolic')),
                  DataColumn(label: const Text('Sugar', style: TextStyle(color: Colors.white, fontSize: 10)), numeric: true, onSort: (i, asc) => _onSort('sugar')),
                  DataColumn(label: const Text('HR', style: TextStyle(color: Colors.white, fontSize: 10)), numeric: true, onSort: (i, asc) => _onSort('heartRate')),
                  DataColumn(label: const Text('Cal In', style: TextStyle(color: Colors.white, fontSize: 10)), numeric: true, onSort: (i, asc) => _onSort('calories')),
                  DataColumn(label: const Text('Cal Out', style: TextStyle(color: Colors.white, fontSize: 10)), numeric: true, onSort: (i, asc) => _onSort('exerciseCalories')),
                  DataColumn(label: const Text('Steps', style: TextStyle(color: Colors.white, fontSize: 10)), numeric: true, onSort: (i, asc) => _onSort('steps')),
                  const DataColumn(label: Text('Mental', style: TextStyle(color: Colors.white, fontSize: 10))),
                  const DataColumn(label: Text('Spiritual', style: TextStyle(color: Colors.white, fontSize: 10))),
                ],
                rows: pagedRecords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                      return index.isEven ? Colors.white.withOpacity(0.1) : Colors.transparent;
                    }),
                    cells: [
                      DataCell(Text((startIndex + index + 1).toString(), style: const TextStyle(color: Colors.white70, fontSize: 10))),
                      DataCell(Text(DateFormat.yMd().add_jm().format(record.timestamp), style: const TextStyle(color: Colors.white, fontSize: 10))),
                      DataCell(Text(record.systolic?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 10))),
                      DataCell(Text(record.diastolic?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 10))),
                      DataCell(Text(record.sugar?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 10))),
                      DataCell(Text(record.heartRate?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 10))),
                      DataCell(Text(record.totalCalories.toString(), style: const TextStyle(color: Colors.white, fontSize: 10))),
                      DataCell(Text(record.exerciseCalories?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 10))),
                      DataCell(Text(record.steps?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 10))),
                      DataCell(Text(record.mentalHealth ?? '', style: const TextStyle(fontSize: 14))),
                      DataCell(Text(record.spiritualHealth ?? '', style: const TextStyle(fontSize: 14))),
                    ]
                  );
                }).toList(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.first_page), onPressed: _currentPage == 0 ? null : () => setState(() => _currentPage = 0)),
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: _currentPage == 0 ? null : () => setState(() => _currentPage--)),
              Text('Page ${_currentPage + 1} of $totalPages'),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _currentPage >= totalPages - 1 ? null : () => setState(() => _currentPage++)),
              IconButton(icon: const Icon(Icons.last_page), onPressed: _currentPage >= totalPages - 1 ? null : () => setState(() => _currentPage = totalPages - 1)),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: _rowsPerPage,
                items: _rowsPerPageOptions.map((int value) {
                  return DropdownMenuItem<int>(value: value, child: Text('$value rows'));
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _rowsPerPage = newValue!;
                    _currentPage = 0;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(Map<String, double> summary) {
    if (summary.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 16.0,
        runSpacing: 16.0,
        children: [
          _buildSummaryItem('Avg BP', '${summary['avgSystolic']?.toStringAsFixed(1)}/${summary['avgDiastolic']?.toStringAsFixed(1)}'),
          _buildSummaryItem('Avg Sugar', summary['avgSugar']?.toStringAsFixed(1) ?? '-'),
          _buildSummaryItem('Avg HR', summary['avgHr']?.toStringAsFixed(1) ?? '-'),
          _buildSummaryItem('Avg Cal In', summary['avgCalories']?.toStringAsFixed(1) ?? '-'),
          _buildSummaryItem('Avg Steps', summary['avgSteps']?.toStringAsFixed(1) ?? '-'),
          _buildSummaryItem('Avg Cal Out', summary['avgExerciseCalories']?.toStringAsFixed(1) ?? '-'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}