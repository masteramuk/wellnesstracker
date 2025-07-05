import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/health_record.dart';

class StatisticsScreen extends StatefulWidget {
  final List<HealthRecord> records;
  const StatisticsScreen({super.key, required this.records});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<HealthRecord> _healthData = [];
  Map<String, double> _averages = {};
  Map<String, double> _mins = {};
  Map<String, double> _maxs = {};
  HealthRecord? _bestRecord;
  int _stepsToday = 0;
  int _stepsLastWeek = 0;
  int _stepsLastMonth = 0;
  int _stepsAll = 0;
  int _stepsSinceJanuary = 0;
  int _caloriesInToday = 0;
  int _caloriesInLastWeek = 0;
  int _caloriesInLastMonth = 0;
  int _caloriesInAll = 0;
  int _caloriesInSinceJanuary = 0;
  int _caloriesOutToday = 0;
  int _caloriesOutLastWeek = 0;
  int _caloriesOutLastMonth = 0;
  int _caloriesOutAll = 0;
  int _caloriesOutSinceJanuary = 0;
  List<HealthRecord> recentRecords = [];
  Map<String, int> _topExercises = {};

  @override
  void initState() {
    super.initState();
    _healthData = widget.records;
    _healthData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _calculateStatistics();
  }

  void _calculateStatistics() {
    if (_healthData.isEmpty) return;

    double totalSugar = 0, minSugar = double.maxFinite, maxSugar = 0;
    int sugarCount = 0;
    double totalSystolic = 0, minSystolic = double.maxFinite, maxSystolic = 0;
    double totalDiastolic = 0, minDiastolic = double.maxFinite, maxDiastolic = 0;
    int bpCount = 0;
    double totalHeartRate = 0, minHeartRate = double.maxFinite, maxHeartRate = 0;
    int heartRateCount = 0;
    int totalCalories = 0, minCalories = 2147483647, maxCalories = 0;
    int caloriesCount = 0;
    int totalSteps = 0, minSteps = 2147483647, maxSteps = 0;
    int stepsCount = 0;
    final exerciseCounts = <String, int>{};

    for (var record in _healthData) {
      if (record.sugar != null) {
        totalSugar += record.sugar! / 18;
        if (record.sugar! / 18 < minSugar) minSugar = record.sugar! / 18;
        if (record.sugar! / 18 > maxSugar) maxSugar = record.sugar! / 18;
        sugarCount++;
      }
      if (record.systolic != null && record.diastolic != null) {
        totalSystolic += record.systolic!;
        totalDiastolic += record.diastolic!;
        if (record.systolic! < minSystolic) minSystolic = record.systolic!;
        if (record.systolic! > maxSystolic) maxSystolic = record.systolic!;
        if (record.diastolic! < minDiastolic) minDiastolic = record.diastolic!;
        if (record.diastolic! > maxDiastolic) maxDiastolic = record.diastolic!;
        bpCount++;
      }
      if (record.heartRate != null) {
        totalHeartRate += record.heartRate!;
        if (record.heartRate! < minHeartRate) minHeartRate = record.heartRate!;
        if (record.heartRate! > maxHeartRate) maxHeartRate = record.heartRate!;
        heartRateCount++;
      }
      if (record.totalCalories > 0) {
        totalCalories += record.totalCalories;
        if (record.totalCalories < minCalories) minCalories = record.totalCalories;
        if (record.totalCalories > maxCalories) maxCalories = record.totalCalories;
        caloriesCount++;
      }
      if (record.steps != null) {
        totalSteps += record.steps!;
        if (record.steps! < minSteps) minSteps = record.steps!;
        if (record.steps! > maxSteps) maxSteps = record.steps!;
        stepsCount++;

        final now = DateTime.now();
        if (record.timestamp.year == now.year && record.timestamp.month == now.month && record.timestamp.day == now.day) {
          _stepsToday += record.steps!;
        }
        if (record.timestamp.isAfter(now.subtract(const Duration(days: 7)))) {
          _stepsLastWeek += record.steps!;
        }
        if (record.timestamp.isAfter(now.subtract(const Duration(days: 30)))) {
          _stepsLastMonth += record.steps!;
        }
        if (record.timestamp.year == now.year && record.timestamp.month >= 1) {
          _stepsSinceJanuary += record.steps!;
        }
        _stepsAll += record.steps!;
      }

      if (record.totalCalories > 0) {
        _caloriesInAll += record.totalCalories;
        final now = DateTime.now();
        if (record.timestamp.year == now.year && record.timestamp.month == now.month && record.timestamp.day == now.day) {
          _caloriesInToday += record.totalCalories;
        }
        if (record.timestamp.isAfter(now.subtract(const Duration(days: 7)))) {
          _caloriesInLastWeek += record.totalCalories;
        }
        if (record.timestamp.isAfter(now.subtract(const Duration(days: 30)))) {
          _caloriesInLastMonth += record.totalCalories;
        }
        if (record.timestamp.year == now.year && record.timestamp.month >= 1) {
          _caloriesInSinceJanuary += record.totalCalories;
        }
      }

      if (record.exerciseCalories != null) {
        _caloriesOutAll += record.exerciseCalories!;
        final now = DateTime.now();
        if (record.timestamp.year == now.year && record.timestamp.month == now.month && record.timestamp.day == now.day) {
          _caloriesOutToday += record.exerciseCalories!;
        }
        if (record.timestamp.isAfter(now.subtract(const Duration(days: 7)))) {
          _caloriesOutLastWeek += record.exerciseCalories!;
        }
        if (record.timestamp.isAfter(now.subtract(const Duration(days: 30)))) {
          _caloriesOutLastMonth += record.exerciseCalories!;
        }
        if (record.timestamp.year == now.year && record.timestamp.month >= 1) {
          _caloriesOutSinceJanuary += record.exerciseCalories!;
        }
      }

      if (record.exerciseType != null) {
        exerciseCounts[record.exerciseType!] = (exerciseCounts[record.exerciseType!] ?? 0) + 1;
      }
    }

    final sortedExercises = exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _topExercises = Map.fromEntries(sortedExercises.take(3));

    _bestRecord = _healthData.reduce((a, b) => (a.systolic ?? 999) < (b.systolic ?? 999) ? a : b);

    setState(() {
      _averages = {
        'sugar': sugarCount > 0 ? totalSugar / sugarCount : 0,
        'systolic': bpCount > 0 ? totalSystolic / bpCount : 0,
        'diastolic': bpCount > 0 ? totalDiastolic / bpCount : 0,
        'heartRate': heartRateCount > 0 ? totalHeartRate / heartRateCount : 0,
        'calories': caloriesCount > 0 ? totalCalories / caloriesCount : 0,
        'steps': stepsCount > 0 ? totalSteps / stepsCount : 0,
      };
      _mins = {
        'sugar': sugarCount > 0 ? minSugar : double.infinity,
        'systolic': bpCount > 0 ? minSystolic : double.infinity,
        'diastolic': bpCount > 0 ? minDiastolic : double.infinity,
        'heartRate': heartRateCount > 0 ? minHeartRate : double.infinity,
        'calories': caloriesCount > 0 ? minCalories.toDouble() : double.infinity,
        'steps': stepsCount > 0 ? minSteps.toDouble() : double.infinity,
      };
      _maxs = {
        'sugar': sugarCount > 0 ? maxSugar : 0,
        'systolic': bpCount > 0 ? maxSystolic : 0,
        'diastolic': bpCount > 0 ? maxDiastolic : 0,
        'heartRate': heartRateCount > 0 ? maxHeartRate : 0,
        'calories': caloriesCount > 0 ? maxCalories.toDouble() : 0,
        'steps': stepsCount > 0 ? maxSteps.toDouble() : 0,
      };
    });
  }

  List<FlSpot> _getChartData(String type) {
    List<FlSpot> spots = [];
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentRecords = _healthData.where((record) => record.timestamp.isAfter(thirtyDaysAgo)).toList();

    for (int i = 0; i < recentRecords.length; i++) {
      final record = recentRecords[i];
      double? value;
      switch (type) {
        case 'sugar':
          value = record.sugar != null ? record.sugar! / 18 : null;
          break;
        case 'systolic':
          value = record.systolic;
          break;
        case 'diastolic':
          value = record.diastolic;
          break;
        case 'heartRate':
          value = record.heartRate;
          break;
      }
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    recentRecords = _healthData.where((record) => record.timestamp.isAfter(thirtyDaysAgo)).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _healthData.isEmpty
          ? const Center(child: Text('No data yet.', style: TextStyle(color: Colors.white)))
          : ListView(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
                children: [
                  _buildOverallAnalyticsCard(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTotalRecordsCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTopExercisesCard()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStepsCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCaloriesCard()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatisticCard(
                    'Blood Pressure',
                    'mmHg',
                    [
                      LineChartBarData(spots: _getChartData('systolic'), isCurved: true, barWidth: 3, color: Colors.green[50]!),
                      LineChartBarData(spots: _getChartData('diastolic'), isCurved: true, barWidth: 3, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatisticCard(
                    'Sugar (mmol/L)',
                    'mmol/L',
                    [LineChartBarData(spots: _getChartData('sugar'), isCurved: true, barWidth: 3, color: Colors.orange[900]!)],
                  ),
                  const SizedBox(height: 16),
                  _buildStatisticCard(
                    'Pulse Rate',
                    'bpm',
                    [LineChartBarData(spots: _getChartData('heartRate'), isCurved: true, barWidth: 3, color: Colors.red[900]!)],
                  ),
                  const SizedBox(height: 16),
                  _buildLast7RecordsTable(),
                ],
              ),
    );
  }

  Widget _buildOverallAnalyticsCard() {
    if (_bestRecord == null) return const SizedBox.shrink();

    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overall Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            _buildAnalyticsRow(Icons.star_border_rounded, 'Best BP Day', '${_bestRecord!.systolic}/${_bestRecord!.diastolic} on ${DateFormat.yMd().format(_bestRecord!.timestamp)}'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.local_fire_department_rounded, 'Avg Calories In', '${_averages['calories']?.toStringAsFixed(0)} kcal/day'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.directions_walk_rounded, 'Avg Steps', '${_averages['steps']?.toStringAsFixed(0)} steps/day'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.favorite, 'Avg Pulse Rate', '${_averages['heartRate']?.toStringAsFixed(0)} bpm'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.water_drop, 'Avg Sugar', '${_averages['sugar']?.toStringAsFixed(1)} mmol/L'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.yellow),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        )
      ],
    );
  }

  Widget _buildStatisticCard(String title, String unit, List<LineChartBarData> lineBarsData) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: lineBarsData,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                      final record = recentRecords[value.toInt()];
                      return Text(DateFormat.Md().format(record.timestamp), style: const TextStyle(color: Colors.white, fontSize: 10));
                    })),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      ],
    );
  }*/

  Widget _buildLast7RecordsTable() {
    final last7Records = _healthData.length > 7 ? _healthData.sublist(_healthData.length - 7) : _healthData;
    last7Records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return Card(
      color: const Color(0xFFBB4101),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 7 Records', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('BP', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Sugar', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Pulse Rate', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Cal In', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Cal Out', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Steps', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Mental', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Spiritual', style: TextStyle(color: Colors.white))),
                  ],
                  rows: last7Records.map((record) {
                    return DataRow(cells: [
                      DataCell(Text(DateFormat.yMd().add_jm().format(record.timestamp), style: const TextStyle(color: Colors.white))),
                      DataCell(Text('${record.systolic}/${record.diastolic}', style: const TextStyle(color: Colors.white))),
                      DataCell(Text((record.sugar! / 18).toStringAsFixed(1), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(record.heartRate.toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(record.totalCalories.toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(record.exerciseCalories.toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(record.steps.toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(record.mentalHealth ?? '')),
                      DataCell(Text(record.spiritualHealth ?? '')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRecordsCard() {
    return Card(
      color: Colors.teal[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Records', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _healthData.length.toString(),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsCard() {
    return Card(
      color: Colors.teal[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Steps', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            _buildAnalyticsRow(Icons.directions_walk_rounded, 'Today', '$_stepsToday steps'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.directions_walk_rounded, 'Last Week', '$_stepsLastWeek steps'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.directions_walk_rounded, 'Last Month', '$_stepsLastMonth steps'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.directions_walk_rounded, 'All Records', '$_stepsAll steps'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.directions_walk_rounded, 'Since January', '$_stepsSinceJanuary steps'),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesCard() {
    return Card(
      color: Colors.teal[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Calories', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            _buildAnalyticsRow(Icons.local_fire_department_rounded, 'Today', 'In: $_caloriesInToday kcal, Out: $_caloriesOutToday kcal'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.local_fire_department_rounded, 'Last Week', 'In: $_caloriesInLastWeek kcal, Out: $_caloriesOutLastWeek kcal'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.local_fire_department_rounded, 'Last Month', 'In: $_caloriesInLastMonth kcal, Out: $_caloriesOutLastMonth kcal'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.local_fire_department_rounded, 'All Records', 'In: $_caloriesInAll kcal, Out: $_caloriesOutAll kcal'),
            const Divider(height: 24),
            _buildAnalyticsRow(Icons.local_fire_department_rounded, 'Since January', 'In: $_caloriesInSinceJanuary kcal, Out: $_caloriesOutSinceJanuary kcal'),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExercisesCard() {
    return Card(
      color: Colors.teal[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top 3 Exercises', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            for (var entry in _topExercises.entries)
              _buildAnalyticsRow(Icons.fitness_center_rounded, entry.key, '${entry.value} times'),
          ],
        ),
      ),
    );
  }
}
