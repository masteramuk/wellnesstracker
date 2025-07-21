import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

// PDF specific imports
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Contains PdfGoogleFonts

import '../../models/health_record.dart';

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
  String _searchColumn = 'All';
  final List<String> _searchableColumns = ['All', 'Date', 'Meal Time', 'Systolic BP', 'Diastolic BP', 'Sugar', 'Pulse Rate', 'Calories In', 'Steps', 'Exercise', 'Calories Out', 'Mental', 'Spiritual'];

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
        if (query.isEmpty) return true;
        switch (_searchColumn) {
          case 'Date':
            return DateFormat('dd/MM/yyyy').format(record.timestamp).toLowerCase().contains(query);
          case 'Meal Time':
            return record.mealTime?.toLowerCase().contains(query) ?? false;
          case 'Systolic BP':
            return record.systolic?.toString().toLowerCase().contains(query) ?? false;
          case 'Diastolic BP':
            return record.diastolic?.toString().toLowerCase().contains(query) ?? false;
          case 'Sugar':
            return record.sugar != null ? record.sugar!.toStringAsFixed(1).toLowerCase().contains(query) : false;
          case 'Pulse Rate':
            return record.heartRate?.toString().toLowerCase().contains(query) ?? false;
          case 'Calories In':
            return record.totalCalories.toString().toLowerCase().contains(query);
          case 'Steps':
            return record.steps?.toString().toLowerCase().contains(query) ?? false;
          case 'Exercise':
            return record.exerciseType?.toLowerCase().contains(query) ?? false;
          case 'Calories Out':
            return record.exerciseCalories?.toString().toLowerCase().contains(query) ?? false;
          case 'Mental':
            return record.mentalHealth?.toLowerCase().contains(query) ?? false;
          case 'Spiritual':
            return record.spiritualHealth?.toLowerCase().contains(query) ?? false;
          case 'All':
          default:
            return record.timestamp.toString().toLowerCase().contains(query) ||
                (record.systolic?.toString().contains(query) ?? false) ||
                (record.diastolic?.toString().contains(query) ?? false) ||
                (record.sugar?.toStringAsFixed(1).contains(query) ?? false) ||
                (record.heartRate?.toString().contains(query) ?? false) ||
                (record.totalCalories.toString().contains(query)) ||
                (record.exerciseCalories?.toString().contains(query) ?? false) ||
                (record.mealTime?.toLowerCase().contains(query) ?? false) ||
                (record.steps?.toString().toLowerCase().contains(query) ?? false) ||
                (record.exerciseType?.toLowerCase().contains(query) ?? false) ||
                (record.mentalHealth?.toLowerCase().contains(query) ?? false) ||
                (record.spiritualHealth?.toLowerCase().contains(query) ?? false);
        }
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
        case 'mealTime':
          comparison = (a.mealTime ?? '').compareTo(b.mealTime ?? '');
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
    rows.add(['Date', 'Time', 'Meal Time', 'Systolic BP', 'Diastolic BP', 'Sugar (mmol/L)', 'Pulse Rate', 'Calories In', 'Steps', 'Exercise', 'Calories Out', 'Mental', 'Spiritual']);
    for (var record in _filteredRecords) {
      rows.add([
        DateFormat('dd/MM/yyyy').format(record.timestamp),
        DateFormat.jm().format(record.timestamp),
        record.mealTime,
        record.systolic,
        record.diastolic,
        record.sugar?.toStringAsFixed(1),
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

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    // Load necessary fonts
    // Changed openSansRegular to openSans for better compatibility with current pdf version and previous code.
    final defaultFont = await PdfGoogleFonts.openSansRegular();
    final materialIcons = await PdfGoogleFonts.materialIconsRegular();
    final emojiFont = await PdfGoogleFonts.notoColorEmoji(); // NEW: Load emoji font for emoji support

    // Define table headers
    final List<pw.Text> headers = [
      'Date', 'Time', 'Meal Time', 'Sys BP', 'Dia BP', 'Sugar (mmol/L)', 'PR', 'Cal In', 'Steps', 'Exercise', 'Cal Out', 'Mental', 'Spiritual'
    ].map((header) => pw.Text(header, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, font: defaultFont, fontFallback: [emojiFont]))).toList();

    // Define table rows, using pw.Widget for cells to support rich text
    final List<List<pw.Widget>> data = _filteredRecords.map((record) {
      return [
        pw.Text(DateFormat('dd/MM/yyyy').format(record.timestamp), style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(DateFormat.jm().format(record.timestamp), style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(record.mealTime ?? '-', style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(record.systolic?.toString() ?? '-', style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(record.diastolic?.toString() ?? '-', style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(record.sugar?.toStringAsFixed(1) ?? '-', style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(record.heartRate?.toString() ?? '-', style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(record.totalCalories.toString(), style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(record.steps?.toString() ?? '-', style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(record.exerciseType ?? '-', style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),
        pw.Text(record.exerciseCalories?.toString() ?? '-', style: pw.TextStyle(fontSize: 8, font: defaultFont, fontFallback: [emojiFont])),

        // Mental Health Cell with Icon
        pw.RichText( // Changed from pw.Text.rich to pw.RichText as per previous correction
          text: pw.TextSpan(
            children: [
              //pw.TextSpan(
              //  text: String.fromCharCode(Icons.psychology_outlined.codePoint),
              //  style: pw.TextStyle(font: materialIcons, fontSize: 9, color: PdfColors.black, fontFallback: [emojiFont]), // Added fallback
              //),
              pw.TextSpan(
                text: ' ${record.mentalHealth ?? '-'}',
                style: pw.TextStyle(fontSize: 8, font: defaultFont, color: PdfColors.black, fontFallback: [emojiFont]), // Added fallback
              ),
            ],
          ),
        ),

        // Spiritual Health Cell with Icon
        pw.RichText( // Changed from pw.Text.rich to pw.RichText as per previous correction
          text: pw.TextSpan(
            children: [
              //pw.TextSpan(
              //  text: String.fromCharCode(Icons.self_improvement_outlined.codePoint),
              //  style: pw.TextStyle(font: materialIcons, fontSize: 9, color: PdfColors.black, fontFallback: [emojiFont]), // Added fallback
              //),
              pw.TextSpan(
                text: ' ${record.spiritualHealth ?? '-'}',
                style: pw.TextStyle(fontSize: 8, font: defaultFont, color: PdfColors.black, fontFallback: [emojiFont]), // Added fallback
              ),
            ],
          ),
        ),
      ];
    }).toList();

    final summary = _getSummary();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              'Health Records Summary',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: defaultFont, fontFallback: [emojiFont]), // Added fallback
            ),
          ),
          pw.SizedBox(height: 20),
          // Summary Section in PDF with Icons
          pw.Text('Average Measurements:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: defaultFont, fontFallback: [emojiFont])), // Added fallback
          pw.SizedBox(height: 5),
          pw.Wrap(
            spacing: 12.0,
            runSpacing: 8.0,
            children: [
              _buildPdfSummaryItem(
                materialIcons,
                Icons.favorite_rounded.codePoint,
                '\u2764',
                'Avg BP: ${summary['avgSystolic']?.toStringAsFixed(1) ?? '-'}/${summary['avgDiastolic']?.toStringAsFixed(1) ?? '-'}',
                defaultFont,
                emojiFont, // Pass emojiFont
              ),
              _buildPdfSummaryItem(
                materialIcons,
                Icons.bloodtype.codePoint,
                '\u{1FA78}',
                'Avg Sugar: ${summary['avgSugar']?.toStringAsFixed(1) ?? '-'}',
                defaultFont,
                emojiFont, // Pass emojiFont
              ),
              _buildPdfSummaryItem(
                materialIcons,
                Icons.speed.codePoint,
                '\u{26F0}',
                'Avg PR: ${summary['avgHr']?.toStringAsFixed(1) ?? '-'}',
                defaultFont,
                emojiFont, // Pass emojiFont
              ),
              _buildPdfSummaryItem(
                materialIcons,
                Icons.restaurant.codePoint,
                '\u{1F37D}',
                'Avg Cal In: ${summary['avgCalories']?.toStringAsFixed(1) ?? '-'}',
                defaultFont,
                emojiFont, // Pass emojiFont
              ),
              _buildPdfSummaryItem(
                materialIcons,
                Icons.directions_walk.codePoint,
                '\u{1F6B6}',
                'Avg Steps: ${summary['avgSteps']?.toStringAsFixed(0) ?? '-'}',
                defaultFont,
                emojiFont, // Pass emojiFont
              ),
              _buildPdfSummaryItem(
                materialIcons,
                Icons.local_fire_department.codePoint,
                '\u{1F525}',
                'Avg Cal Out: ${summary['avgExerciseCalories']?.toStringAsFixed(1) ?? '-'}',
                defaultFont,
                emojiFont, // Pass emojiFont
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: defaultFont, fontFallback: [emojiFont]), // Added fallback
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellPadding: const pw.EdgeInsets.all(2),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.centerRight,
                9: pw.Alignment.centerLeft,
                10: pw.Alignment.centerRight,
                11: pw.Alignment.centerLeft, // Alignment for Mental Health cell
                12: pw.Alignment.centerLeft, // Alignment for Spiritual Health cell
              },
              columnWidths: {
                0: const pw.FixedColumnWidth(60),
                1: const pw.FixedColumnWidth(40),
                2: const pw.FixedColumnWidth(50),
                3: const pw.FixedColumnWidth(35),
                4: const pw.FixedColumnWidth(35),
                5: const pw.FixedColumnWidth(45),
                6: const pw.FixedColumnWidth(30),
                7: const pw.FixedColumnWidth(40),
                8: const pw.FixedColumnWidth(35),
                9: const pw.FixedColumnWidth(50),
                10: const pw.FixedColumnWidth(40),
                11: const pw.FixedColumnWidth(55), // Adjusted width for icon + text
                12: const pw.FixedColumnWidth(55), // Adjusted width for icon + text
              }
          ),
        ],
      ),
    );

    final String filename = 'health_records_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    if (kIsWeb) {
      await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
    } else {
      final output = await getApplicationDocumentsDirectory();
      final file = File("${output.path}/$filename");
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    }
  }

  // Helper function to build summary items for PDF
  pw.Widget _buildPdfSummaryItem(
      pw.Font materialIconsFont,
      int iconCodePoint,
      String icon,
      String text,
      pw.Font defaultFont, // Added default font parameter
      pw.Font emojiFont, // NEW: emojiFont parameter
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.green200,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(icon, style: pw.TextStyle(font: defaultFont, fontFallback: [emojiFont])),
          /*pw.Text(
            String.fromCharCode(iconCodePoint),
            style: pw.TextStyle(font: materialIconsFont, fontSize: 10, color: PdfColors.black, fontFallback: [emojiFont]), // Added fallback to icon
          ),*/
          pw.SizedBox(width: 4),
          pw.Text(
            text,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black, font: defaultFont, fontFallback: [emojiFont]), // Added fallback to text
          ),
        ],
      ),
    );
  }

  Map<String, double> _getSummary() {
    if (_filteredRecords.isEmpty) return {};
    double totalSystolic = 0, totalDiastolic = 0, totalSugar = 0, totalHr = 0, totalCalories = 0, totalSteps = 0, totalExerciseCalories = 0;
    double minSystolic = double.maxFinite, maxSystolic = 0, minDiastolic = double.maxFinite, maxDiastolic = 0, minSugar = double.maxFinite, maxSugar = 0, minHr = double.maxFinite, maxHr = 0, minCalories = double.maxFinite, maxCalories = 0, minSteps = double.maxFinite, maxSteps = 0, minExerciseCalories = double.maxFinite, maxExerciseCalories = 0;
    int countWithSystolic = 0, countWithDiastolic = 0, countWithSugar = 0, countWithHr = 0, countWithSteps = 0, countWithExerciseCalories = 0;


    for (var record in _filteredRecords) {
      if (record.systolic != null) {
        totalSystolic += record.systolic!;
        countWithSystolic++;
        if(record.systolic! < minSystolic) minSystolic = record.systolic!;
        if(record.systolic! > maxSystolic) maxSystolic = record.systolic!;
      }
      if (record.diastolic != null) {
        totalDiastolic += record.diastolic!;
        countWithDiastolic++;
        if(record.diastolic! < minDiastolic) minDiastolic = record.diastolic!;
        if(record.diastolic! > maxDiastolic) maxDiastolic = record.diastolic!;
      }
      if (record.sugar != null) {
        totalSugar += record.sugar!;
        countWithSugar++;
        if(record.sugar! < minSugar) minSugar = record.sugar!;
        if(record.sugar! > maxSugar) maxSugar = record.sugar!;
      }
      if (record.heartRate != null) {
        totalHr += record.heartRate!;
        countWithHr++;
        if(record.heartRate! < minHr) minHr = record.heartRate!;
        if(record.heartRate! > maxHr) maxHr = record.heartRate!;
      }
      totalCalories += record.totalCalories;
      if(record.totalCalories < minCalories) minCalories = record.totalCalories.toDouble();
      if(record.totalCalories > maxCalories) maxCalories = record.totalCalories.toDouble();

      if (record.steps != null) {
        totalSteps += record.steps!;
        countWithSteps++;
        if(record.steps! < minSteps) minSteps = record.steps!.toDouble();
        if(record.steps! > maxSteps) maxSteps = record.steps!.toDouble();
      }
      if (record.exerciseCalories != null) {
        totalExerciseCalories += record.exerciseCalories!;
        countWithExerciseCalories++;
        if(record.exerciseCalories! < minExerciseCalories) minExerciseCalories = record.exerciseCalories!.toDouble();
        if(record.exerciseCalories! > maxExerciseCalories) maxExerciseCalories = record.exerciseCalories!.toDouble();
      }
    }

    return {
      'avgSystolic': countWithSystolic > 0 ? totalSystolic / countWithSystolic : 0,
      'avgDiastolic': countWithDiastolic > 0 ? totalDiastolic / countWithDiastolic : 0,
      'avgSugar': countWithSugar > 0 ? totalSugar / countWithSugar : 0,
      'avgHr': countWithHr > 0 ? totalHr / countWithHr : 0,
      'avgCalories': _filteredRecords.isNotEmpty ? totalCalories / _filteredRecords.length : 0,
      'avgSteps': countWithSteps > 0 ? totalSteps / countWithSteps : 0,
      'avgExerciseCalories': countWithExerciseCalories > 0 ? totalExerciseCalories / countWithExerciseCalories : 0,
      'minSystolic': minSystolic == double.maxFinite ? 0 : minSystolic, 'maxSystolic': maxSystolic,
      'minDiastolic': minDiastolic == double.maxFinite ? 0 : minDiastolic, 'maxDiastolic': maxDiastolic,
      'minSugar': minSugar == double.maxFinite ? 0 : minSugar, 'maxSugar': maxSugar,
      'minHr': minHr == double.maxFinite ? 0 : minHr, 'maxHr': maxHr,
      'minCalories': minCalories == double.maxFinite ? 0 : minCalories, 'maxCalories': maxCalories,
      'minSteps': minSteps == double.maxFinite ? 0 : minSteps, 'maxSteps': maxSteps,
      'minExerciseCalories': minExerciseCalories == double.maxFinite ? 0 : minExerciseCalories, 'maxExerciseCalories': maxExerciseCalories,
    };
  }

  // Helper function to determine color based on health metrics
  Color _getHealthColor(String metric, double value1, {double? value2}) {
    switch (metric) {
      case 'BP':
        if (value1 > 180 || (value2 != null && value2 > 120)) return Colors.red[900]!;
        if (value1 >= 140 || (value2 != null && value2 >= 90)) return Colors.red[700]!;
        if (value1 >= 130 || (value2 != null && value2 >= 80)) return Colors.orange[700]!;
        if (value1 >= 120 && value1 < 130 && (value2 != null && value2 < 80)) return Colors.yellow[700]!;
        if (value1 < 90 || (value2 != null && value2 < 60)) return Colors.blue[700]!;
        return Colors.green[700]!;

      case 'Sugar':
        if (value1 >= 7.0 && value1 < 100) return Colors.red[700]!;
        if (value1 >= 5.6 && value1 < 7.0) return Colors.yellow[700]!;
        if (value1 < 3.9 && value1 > 0) return Colors.blue[700]!;
        return Colors.green[700]!;

      case 'PR':
        if (value1 > 100) return Colors.orange[700]!;
        if (value1 < 60 && value1 > 0) return Colors.blue[700]!;
        return Colors.green[700]!;

      case 'Steps':
        if (value1 >= 10000) return Colors.green[700]!;
        if (value1 >= 7500) return Colors.lightGreen[700]!;
        if (value1 >= 5000) return Colors.yellow[700]!;
        return Colors.red[700]!;

      case 'Calories In':
      case 'Calories Out':
        return Colors.blueGrey[700]!;
      default:
        return Colors.grey[700]!;
    }
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
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _exportToPdf, tooltip: 'Export to PDF'),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Search...', prefixIcon: Icon(Icons.search, color: Colors.white70)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _searchColumn,
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        items: _searchableColumns.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(color: Colors.white)));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _searchColumn = newValue!;
                            _filterRecords();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Wrap(
                    alignment: WrapAlignment.spaceAround,
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      _buildSummaryCard(
                        'Avg BP',
                        '${summary['avgSystolic']?.toStringAsFixed(1) ?? '-'}/${summary['avgDiastolic']?.toStringAsFixed(1) ?? '-'}',
                        Icons.favorite_rounded,
                        _getHealthColor('BP', summary['avgSystolic'] ?? 0, value2: summary['avgDiastolic']),
                      ),
                      _buildSummaryCard(
                        'Avg Sugar',
                        summary['avgSugar']?.toStringAsFixed(1) ?? '-',
                        Icons.bloodtype,
                        _getHealthColor('Sugar', summary['avgSugar'] ?? 0),
                      ),
                      _buildSummaryCard(
                        'Avg PR',
                        summary['avgHr']?.toStringAsFixed(1) ?? '-',
                        Icons.speed,
                        _getHealthColor('PR', summary['avgHr'] ?? 0),
                      ),
                      _buildSummaryCard(
                        'Avg Cal In',
                        summary['avgCalories']?.toStringAsFixed(1) ?? '-',
                        Icons.restaurant,
                        _getHealthColor('Calories In', summary['avgCalories'] ?? 0),
                      ),
                      _buildSummaryCard(
                        'Avg Steps',
                        summary['avgSteps']?.toStringAsFixed(0) ?? '-',
                        Icons.directions_walk,
                        _getHealthColor('Steps', summary['avgSteps'] ?? 0),
                      ),
                      if(isTablet)
                        _buildSummaryCard(
                          'Avg Cal Out',
                          summary['avgExerciseCalories']?.toStringAsFixed(1) ?? '-',
                          Icons.local_fire_department,
                          _getHealthColor('Calories Out', summary['avgExerciseCalories'] ?? 0),
                        ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: WidgetStateColor.resolveWith((states) => Colors.black),
                      sortColumnIndex: ['timestamp', 'systolic', 'diastolic', 'sugar', 'heartRate', 'calories', 'exerciseCalories', 'steps', 'mealTime'].indexOf(_sortColumn),
                      sortAscending: _sortAscending,
                      columns: [
                        const DataColumn(label: Text('#', style: TextStyle(color: Colors.white, fontSize: 14))),
                        DataColumn(label: const Text('Date', style: TextStyle(color: Colors.white, fontSize: 14)), onSort: (i, asc) => _onSort('timestamp')),
                        if(isTablet) DataColumn(label: const Text('Meal Time', style: TextStyle(color: Colors.white, fontSize: 14)), onSort: (i, asc) => _onSort('mealTime')),
                        DataColumn(label: const Text('Sys', style: TextStyle(color: Colors.white, fontSize: 14)), numeric: true, onSort: (i, asc) => _onSort('systolic')),
                        DataColumn(label: const Text('Dia', style: TextStyle(color: Colors.white, fontSize: 14)), numeric: true, onSort: (i, asc) => _onSort('diastolic')),
                        DataColumn(label: const Text('Sugar', style: TextStyle(color: Colors.white, fontSize: 14)), numeric: true, onSort: (i, asc) => _onSort('sugar')),
                        DataColumn(label: const Text('PR', style: TextStyle(color: Colors.white, fontSize: 14)), numeric: true, onSort: (i, asc) => _onSort('heartRate')),
                        if(isTablet) DataColumn(label: const Text('Cal In', style: TextStyle(color: Colors.white, fontSize: 14)), numeric: true, onSort: (i, asc) => _onSort('calories')),
                        if(isTablet) DataColumn(label: const Text('Cal Out', style: TextStyle(color: Colors.white, fontSize: 14)), numeric: true, onSort: (i, asc) => _onSort('exerciseCalories')),
                        DataColumn(label: const Text('Steps', style: TextStyle(color: Colors.white, fontSize: 14)), numeric: true, onSort: (i, asc) => _onSort('steps')),
                        if (isTablet) const DataColumn(label: Text('Mental', style: TextStyle(color: Colors.white, fontSize: 14))),
                        if (isTablet) const DataColumn(label: Text('Spiritual', style: TextStyle(color: Colors.white, fontSize: 14))),
                      ],
                      rows: pagedRecords.asMap().entries.map((entry) {
                        final index = entry.key;
                        final record = entry.value;
                        return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                              return index.isEven ? Colors.white.withValues(alpha:0.1) : Colors.transparent;
                            }),
                            cells: [
                              DataCell(Text((startIndex + index + 1).toString(), style: const TextStyle(color: Colors.white70, fontSize: 14))),
                              DataCell(Text(isTablet ? DateFormat('dd/MM/yyyy h:mm a').format(record.timestamp) : DateFormat('dd/MM/yyyy a').format(record.timestamp), style: const TextStyle(color: Colors.white, fontSize: 14))),
                              if(isTablet) DataCell(Text(record.mealTime ?? '-', style: const TextStyle(color: Colors.white, fontSize: 14))),
                              DataCell(Text(record.systolic?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 14))),
                              DataCell(Text(record.diastolic?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 14))),
                              DataCell(Text(record.sugar != null ? record.sugar!.toStringAsFixed(1) : '-', style: const TextStyle(color: Colors.white, fontSize: 14))),
                              DataCell(Text(record.heartRate?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 14))),
                              if(isTablet) DataCell(Text(record.totalCalories.toString(), style: const TextStyle(color: Colors.white, fontSize: 14))),
                              if(isTablet) DataCell(Text(record.exerciseCalories?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 14))),
                              DataCell(Text(record.steps?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 14))),
                              if (isTablet) DataCell(Text(record.mentalHealth ?? '', style: const TextStyle(fontSize: 14))),
                              if (isTablet) DataCell(Text(record.spiritualHealth ?? '', style: const TextStyle(fontSize: 14))),
                            ]
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20.0, top: 8.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.first_page, color: Colors.white),
                        onPressed: _currentPage == 0 ? null : () => setState(() => _currentPage = 0),
                        color: Colors.white,
                      ),
                      IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: _currentPage == 0 ? null : () => setState(() => _currentPage--)),
                      Text(
                        'Page ${_currentPage + 1} of $totalPages',
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: _currentPage >= totalPages - 1 ? null : () => setState(() => _currentPage++)),
                      IconButton(
                          icon: const Icon(Icons.last_page, color: Colors.white),
                          onPressed: _currentPage >= totalPages - 1 ? null : () => setState(() => _currentPage = totalPages - 1)),
                      const SizedBox(width: 20),
                      DropdownButton<int>(
                        value: _rowsPerPage,
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        items: _rowsPerPageOptions.map((int value) {
                          return DropdownMenuItem<int>(value: value, child: Text('$value rows', style: const TextStyle(color: Colors.white)));
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _rowsPerPage = newValue!;
                            _currentPage = 0;
                          });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.zero,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}