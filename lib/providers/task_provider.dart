import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _alarmTimer;
  String? _lastNotifiedTaskId;

  List<Task> _tasks = [];
  Map<String, int> _dailyStats = {};
  Map<String, int> _priorityStats = {};
  int _totalWeeklyCompletions = 0;
  bool _isLoading = true;

  List<Task> get tasks => _tasks;
  List<Task> get completedTasks  => _tasks.where((t) => t.isCompleted).toList();
  List<Task> get incompleteTasks => _tasks.where((t) => !t.isCompleted).toList();
  double get completionRate =>
      _tasks.isEmpty ? 0 : completedTasks.length / _tasks.length;
  
  Map<String, int> get dailyStats => _dailyStats;
  Map<String, int> get priorityStats => _priorityStats;
  int get totalWeeklyCompletions => _totalWeeklyCompletions;
  bool get isLoading => _isLoading;

  TaskProvider() {
    _listenToTasks();
    _loadWeeklyStats();
    _startAlarmTimer();
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    super.dispose();
  }

  // Realtime listener
  void _listenToTasks() {
    _service.getTasksStream().listen((tasks) {
      _tasks = tasks;
      _isLoading = false;
      notifyListeners();
    });
  }

  void _startAlarmTimer() {
    _alarmTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAlarms();
    });
  }

  void _checkAlarms() {
    final now = DateTime.now();
    for (var task in _tasks) {
      if (!task.isCompleted && task.scheduledTime != null) {
        if (task.scheduledTime!.hour == now.hour &&
            task.scheduledTime!.minute == now.minute) {
          if (_lastNotifiedTaskId != task.id) {
            _lastNotifiedTaskId = task.id;
            _showAlarmDialog(task);
          }
        }
      }
    }
  }

  Function(Task)? onTaskAlarm;

  void _showAlarmDialog(Task task) {
    _playAlarmSound();
    if (onTaskAlarm != null) {
      onTaskAlarm!(task);
    }
  }

  Future<void> _playAlarmSound() async {
    try {
      await _audioPlayer.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  Future<void> _loadWeeklyStats() async {
    final stats = await _service.getWeeklyStats();
    _dailyStats = Map<String, int>.from(stats['daily']);
    _priorityStats = Map<String, int>.from(stats['priority']);
    _totalWeeklyCompletions = stats['total'];
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _service.addTask(task);
    await _loadWeeklyStats();
  }

  Future<void> toggleComplete(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await _service.toggleComplete(task);
    await _loadWeeklyStats();
  }

  Future<void> deleteTask(String id) async {
    await _service.deleteTask(id);
    await _loadWeeklyStats();
  }

  String generateId() => const Uuid().v4();
}
