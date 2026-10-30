import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class MockTaskService {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Take Morning Medication',
      iconEmoji: '💊',
      priority: Priority.urgent,
      scheduledTime: DateTime.now().copyWith(hour: 8, minute: 0),
      isRecurring: true,
      steps: ['Get water', 'Open pill box', 'Take tablet', 'Mark done'],
    ),
    Task(
      id: '2',
      title: 'Morning Walk',
      iconEmoji: '🏃',
      priority: Priority.recurring,
      scheduledTime: DateTime.now().copyWith(hour: 7, minute: 0),
      isRecurring: true,
      steps: ['Put on shoes', 'Go outside', 'Walk for 20 mins', 'Return home'],
    ),
    Task(
      id: '3',
      title: 'Read a Book',
      iconEmoji: '📚',
      priority: Priority.normal,
      scheduledTime: DateTime.now().copyWith(hour: 20, minute: 0),
      steps: ['Pick your book', 'Read 10 pages', 'Mark your page'],
    ),
    Task(
      id: '4',
      title: 'Drink Water',
      iconEmoji: '💧',
      priority: Priority.recurring,
      isRecurring: true,
      steps: ['Get a glass', 'Fill with water', 'Drink fully'],
    ),
  ];

  List<Task> getTasks() => List.from(_tasks);

  void addTask(Task task) => _tasks.add(task);

  void toggleComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
    }
  }

  void deleteTask(String id) => _tasks.removeWhere((t) => t.id == id);

  String generateId() => const Uuid().v4();
}