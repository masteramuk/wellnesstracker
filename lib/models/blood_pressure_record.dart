
import 'package:flutter/material.dart';

class BloodPressureRecord {
  final DateTime date;
  final int systolic;
  final int diastolic;
  final int pulse;

  BloodPressureRecord({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
  });

  factory BloodPressureRecord.fromJson(Map<String, dynamic> json) {
    return BloodPressureRecord(
      date: DateTime.parse(json['date']),
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      pulse: json['pulse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
    };
  }
}

enum BloodPressureStatus {
  low,
  normal,
  elevated,
  highStage1,
  highStage2,
  crisis,
}

BloodPressureStatus getBloodPressureStatus(int systolic, int diastolic) {
  if (systolic < 90 || diastolic < 60) {
    return BloodPressureStatus.low;
  } else if (systolic < 120 && diastolic < 80) {
    return BloodPressureStatus.normal;
  } else if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
    return BloodPressureStatus.elevated;
  } else if (systolic >= 130 && systolic <= 139 || diastolic >= 80 && diastolic <= 89) {
    return BloodPressureStatus.highStage1;
  } else if (systolic >= 140 || diastolic >= 90) {
    return BloodPressureStatus.highStage2;
  } else if (systolic > 180 || diastolic > 120) {
    return BloodPressureStatus.crisis;
  }
  return BloodPressureStatus.normal; // Default case
}

Color getStatusColor(BloodPressureStatus status) {
  switch (status) {
    case BloodPressureStatus.low:
      return Colors.blue;
    case BloodPressureStatus.normal:
      return Colors.green;
    case BloodPressureStatus.elevated:
      return Colors.yellow;
    case BloodPressureStatus.highStage1:
      return Colors.orange;
    case BloodPressureStatus.highStage2:
      return Colors.red;
    case BloodPressureStatus.crisis:
      return Colors.purple;
  }
}

Icon getStatusIcon(BloodPressureStatus status) {
  switch (status) {
    case BloodPressureStatus.low:
      return const Icon(Icons.arrow_downward, color: Colors.blue);
    case BloodPressureStatus.normal:
      return const Icon(Icons.check_circle, color: Colors.green);
    case BloodPressureStatus.elevated:
      return const Icon(Icons.trending_up, color: Colors.yellow);
    case BloodPressureStatus.highStage1:
      return const Icon(Icons.warning, color: Colors.orange);
    case BloodPressureStatus.highStage2:
      return const Icon(Icons.error, color: Colors.red);
    case BloodPressureStatus.crisis:
      return const Icon(Icons.dangerous, color: Colors.purple);
  }
}
