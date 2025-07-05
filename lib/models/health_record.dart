class FoodItem {
  final String name;
  final int calories;

  FoodItem({required this.name, required this.calories});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
    );
  }
}

class HealthRecord {
  final double? sugar;
  final double? systolic;
  final double? diastolic;
  final double? heartRate;
  final DateTime timestamp;
  final String? mealTime;
  final String? mentalHealth;
  final String? spiritualHealth;
  final List<FoodItem> foodAndDrinks;
  final int? steps;
  final String? exerciseType;
  final int? exerciseCalories;

  HealthRecord({
    this.sugar,
    this.systolic,
    this.diastolic,
    this.heartRate,
    required this.timestamp,
    this.mealTime,
    this.mentalHealth,
    this.spiritualHealth,
    this.foodAndDrinks = const [],
    this.steps,
    this.exerciseType,
    this.exerciseCalories,
  });

  int get totalCalories {
    return foodAndDrinks.fold(0, (sum, item) => sum + item.calories);
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    var foodList = (map['foodAndDrinks'] as List?)
        ?.map((item) => FoodItem.fromMap(Map<String, dynamic>.from(item)))
        .toList() ?? [];

    return HealthRecord(
      sugar: double.tryParse(map['sugar']?.toString() ?? ''),
      systolic: double.tryParse(map['systolic']?.toString() ?? ''),
      diastolic: double.tryParse(map['diastolic']?.toString() ?? ''),
      heartRate: double.tryParse(map['heartRate']?.toString() ?? ''),
      timestamp: DateTime.parse(map['timestamp']),
      mealTime: map['mealTime'],
      mentalHealth: map['mentalHealth'],
      spiritualHealth: map['spiritualHealth'],
      foodAndDrinks: foodList,
      steps: int.tryParse(map['steps']?.toString() ?? ''),
      exerciseType: map['exerciseType'],
      exerciseCalories: int.tryParse(map['exerciseCalories']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sugar': sugar?.toString(),
      'systolic': systolic?.toString(),
      'diastolic': diastolic?.toString(),
      'heartRate': heartRate?.toString(),
      'timestamp': timestamp.toIso8601String(),
      'mealTime': mealTime,
      'mentalHealth': mentalHealth,
      'spiritualHealth': spiritualHealth,
      'foodAndDrinks': foodAndDrinks.map((item) => item.toMap()).toList(),
      'steps': steps?.toString(),
      'exerciseType': exerciseType,
      'exerciseCalories': exerciseCalories?.toString(),
    };
  }
}