
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/health_record.dart';
import '../config/exercise_config.dart';

class HomeScreen extends StatefulWidget {
  final Function(HealthRecord) onRecordAdded;
  const HomeScreen({super.key, required this.onRecordAdded});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _sugarController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _stepsController = TextEditingController();
  final _exerciseCaloriesController = TextEditingController();

  // State variables
  DateTime _selectedDate = DateTime.now();
  String? _selectedMealTime = 'Before Breakfast';
  String? _selectedExercise = ExerciseConfig.exercises.first;
  String _selectedMentalEmoji = '😊';
  String _selectedSpiritualEmoji = '🙏';
  List<FoodItem> _foodItems = [];

  final List<String> _mealTimes = ['Before Breakfast', 'After Breakfast', 'Before Lunch', 'After Lunch', 'Before Dinner', 'After Dinner', 'Fasting'];
  final List<String> _emojis = ['😊', '😐', '😔', '😠', '😢', '😇', '🙏', '🧘', '💖'];

  void _addFoodItem() {
    setState(() {
      _foodItems.add(FoodItem(name: '', calories: 0));
    });
  }

  void _removeFoodItem(int index) {
    setState(() {
      _foodItems.removeAt(index);
    });
  }

  void _updateFoodItem(int index, {String? name, int? calories}) {
    setState(() {
      _foodItems[index] = FoodItem(
        name: name ?? _foodItems[index].name,
        calories: calories ?? _foodItems[index].calories,
      );
    });
  }

  Future<void> _saveHealthData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final healthDataString = prefs.getString('healthData') ?? '[]';
      final List<dynamic> healthDataList = jsonDecode(healthDataString);

      final newRecord = HealthRecord(
        timestamp: _selectedDate,
        systolic: double.tryParse(_systolicController.text),
        diastolic: double.tryParse(_diastolicController.text),
        sugar: double.tryParse(_sugarController.text),
        heartRate: double.tryParse(_heartRateController.text),
        mealTime: _selectedMealTime,
        foodAndDrinks: _foodItems,
        steps: int.tryParse(_stepsController.text),
        exerciseType: _selectedExercise,
        exerciseCalories: int.tryParse(_exerciseCaloriesController.text),
        mentalHealth: _selectedMentalEmoji,
        spiritualHealth: _selectedSpiritualEmoji,
      );

      healthDataList.add(newRecord.toMap());
      await prefs.setString('healthData', jsonEncode(healthDataList));

      widget.onRecordAdded(newRecord);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record Saved Successfully!')),
      );
      _formKey.currentState?.reset();
      setState(() {
        _foodItems = [];
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 1)));
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(_selectedDate));
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold transparent
      appBar: AppBar(
        title: const Text('Add New Record'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Add padding for button
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDateTimeCard(),
              const SizedBox(height: 16),
              _buildHealthMetricsCard(),
              const SizedBox(height: 16),
              _buildNutritionCard(),
              const SizedBox(height: 16),
              _buildActivityCard(),
              const SizedBox(height: 16),
              _buildWellbeingCard(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_rounded),
                  onPressed: _saveHealthData,
                  label: const Text('Save Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date & Time', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.yMMMEd().add_jm().format(_selectedDate), style: const TextStyle(color: Colors.white)),
                    const Icon(Icons.calendar_today, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetricsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Metrics', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextFormField(controller: _systolicController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Systolic BP'), keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: TextFormField(controller: _diastolicController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Diastolic BP'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 16),
            TextFormField(controller: _sugarController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Blood Sugar (mg/dL)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextFormField(controller: _heartRateController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Heart Rate (bpm)'), keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nutrition', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMealTime,
              decoration: const InputDecoration(labelText: 'Meal Context'),
              items: _mealTimes.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (newValue) => setState(() => _selectedMealTime = newValue),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ..._buildFoodItemInputs(),
            TextButton.icon(
              icon: const Icon(Icons.add, color: Colors.white70),
              label: const Text('Add Food/Drink', style: TextStyle(color: Colors.white70)),
              onPressed: _addFoodItem,
            ),
            const SizedBox(height: 16),
            Text('Total Calories: ${_foodItems.fold(0, (sum, item) => sum + item.calories)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFoodItemInputs() {
    return List.generate(_foodItems.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _foodItems[index].name,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Food/Drink'),
                onChanged: (value) => _updateFoodItem(index, name: value),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: _foodItems[index].calories.toString(),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateFoodItem(index, calories: int.tryParse(value) ?? 0),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () => _removeFoodItem(index),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActivityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Physical Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            TextFormField(controller: _stepsController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Steps Taken'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedExercise,
              decoration: const InputDecoration(labelText: 'Type of Exercise'),
              items: ExerciseConfig.exercises.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (newValue) => setState(() => _selectedExercise = newValue),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _exerciseCaloriesController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Calories Burned (kcal)'), keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildWellbeingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Well-being', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            _buildEmojiSelector('Mental State', _selectedMentalEmoji, (emoji) => setState(() => _selectedMentalEmoji = emoji)),
            const SizedBox(height: 16),
            _buildEmojiSelector('Spiritual State', _selectedSpiritualEmoji, (emoji) => setState(() => _selectedSpiritualEmoji = emoji)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiSelector(String title, String selectedEmoji, ValueChanged<String> onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _emojis.map((emoji) {
            return ChoiceChip(
              label: Text(emoji, style: const TextStyle(fontSize: 24)),
              selected: selectedEmoji == emoji,
              onSelected: (selected) {
                if (selected) onSelected(emoji);
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: Colors.teal[400],
            );
          }).toList(),
        ),
      ],
    );
  }
}
