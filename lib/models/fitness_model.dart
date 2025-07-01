import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WorkoutPlan {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> equipment;
  final String difficulty;
  final int duration; // in minutes
  final List<WorkoutExercise> exercises;

  WorkoutPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.equipment,
    required this.difficulty,
    required this.duration,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'equipment': equipment,
    'difficulty': difficulty,
    'duration': duration,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    imageUrl: json['imageUrl'],
    equipment: List<String>.from(json['equipment']),
    difficulty: json['difficulty'],
    duration: json['duration'],
    exercises: (json['exercises'] as List)
        .map((e) => WorkoutExercise.fromJson(e))
        .toList(),
  );
}

class WorkoutExercise {
  final String name;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final int sets;
  final int reps;
  final int restTime; // in seconds

  WorkoutExercise({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.sets,
    required this.reps,
    required this.restTime,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
    'sets': sets,
    'reps': reps,
    'restTime': restTime,
  };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
    name: json['name'],
    description: json['description'],
    imageUrl: json['imageUrl'],
    videoUrl: json['videoUrl'],
    sets: json['sets'],
    reps: json['reps'],
    restTime: json['restTime'],
  );
}

class FitnessGoal {
  final String type; // e.g., 'weight_loss', 'muscle_gain', 'endurance'
  final String target;
  final DateTime deadline;
  final double progress;

  FitnessGoal({
    required this.type,
    required this.target,
    required this.deadline,
    required this.progress,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'target': target,
    'deadline': deadline.toIso8601String(),
    'progress': progress,
  };

  factory FitnessGoal.fromJson(Map<String, dynamic> json) => FitnessGoal(
    type: json['type'],
    target: json['target'],
    deadline: DateTime.parse(json['deadline']),
    progress: json['progress'].toDouble(),
  );
}

class FitnessModel extends ChangeNotifier {
  List<WorkoutPlan> _workoutPlans = [];
  List<FitnessGoal> _goals = [];
  late SharedPreferences _prefs;
  bool _initialized = false;

  FitnessModel() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    _initialized = true;
  }

  Future<void> _loadData() async {
    final String? workoutPlansJson = _prefs.getString('workoutPlans');
    final String? goalsJson = _prefs.getString('fitnessGoals');

    if (workoutPlansJson != null) {
      final List<dynamic> workoutPlansList = json.decode(workoutPlansJson);
      _workoutPlans = workoutPlansList
          .map((plan) => WorkoutPlan.fromJson(plan))
          .toList();
    }

    if (goalsJson != null) {
      final List<dynamic> goalsList = json.decode(goalsJson);
      _goals = goalsList
          .map((goal) => FitnessGoal.fromJson(goal))
          .toList();
    }
  }

  Future<void> _saveData() async {
    if (!_initialized) return;

    final String workoutPlansJson = json.encode(
      _workoutPlans.map((plan) => plan.toJson()).toList(),
    );
    final String goalsJson = json.encode(
      _goals.map((goal) => goal.toJson()).toList(),
    );

    await _prefs.setString('workoutPlans', workoutPlansJson);
    await _prefs.setString('fitnessGoals', goalsJson);
  }

  List<WorkoutPlan> get workoutPlans => [..._workoutPlans];
  List<FitnessGoal> get goals => [..._goals];

  void addWorkoutPlan(WorkoutPlan plan) {
    _workoutPlans.add(plan);
    _saveData();
    notifyListeners();
  }

  void removeWorkoutPlan(String id) {
    _workoutPlans.removeWhere((plan) => plan.id == id);
    _saveData();
    notifyListeners();
  }

  void addGoal(FitnessGoal goal) {
    _goals.add(goal);
    _saveData();
    notifyListeners();
  }

  void updateGoalProgress(String type, double progress) {
    final goalIndex = _goals.indexWhere((goal) => goal.type == type);
    if (goalIndex >= 0) {
      _goals[goalIndex] = FitnessGoal(
        type: _goals[goalIndex].type,
        target: _goals[goalIndex].target,
        deadline: _goals[goalIndex].deadline,
        progress: progress,
      );
      _saveData();
      notifyListeners();
    }
  }

  void removeGoal(String type) {
    _goals.removeWhere((goal) => goal.type == type);
    _saveData();
    notifyListeners();
  }
} 