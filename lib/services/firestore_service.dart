import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  // Stream of tasks for TODAY (realtime)
  Stream<List<Task>> getTasksStream() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _db
        .collection(_collection)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => Task.fromMap(doc.data()))
              .where((task) {
                // 1. Show all recurring tasks
                if (task.isRecurring) return true;

                // 2. Show tasks with no scheduled time
                if (task.scheduledTime == null) return true;

                // 3. Show tasks scheduled for today
                final taskDate = DateTime(
                  task.scheduledTime!.year,
                  task.scheduledTime!.month,
                  task.scheduledTime!.day,
                );
                return taskDate.isAtSameMomentAs(today);
              })
              .toList();
        });
  }

  // Add task
  Future<void> addTask(Task task) async {
    await _db.collection(_collection).doc(task.id).set(task.toMap());
  }

  // Toggle complete
  Future<void> toggleComplete(Task task) async {
    final isNowComplete = !task.isCompleted;
    await _db.collection(_collection).doc(task.id).update({
      'isCompleted': isNowComplete,
      'completedAt': isNowComplete
          ? Timestamp.fromDate(DateTime.now())
          : null,
    });
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // Get detailed weekly completions (last 7 days)
  Future<Map<String, dynamic>> getWeeklyStats() async {
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final snap = await _db
        .collection(_collection)
        .where('isCompleted', isEqualTo: true)
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .get();

    final Map<String, int> dailyCounts = {};
    final Map<String, int> priorityCounts = {
      'urgent': 0,
      'recurring': 0,
      'normal': 0,
    };

    // Initialize days
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      dailyCounts[_dayLabel(day)] = 0;
    }

    int totalCompletions = 0;

    for (final doc in snap.docs) {
      final task = Task.fromMap(doc.data());
      if (task.completedAt != null) {
        totalCompletions++;
        
        // Count by day
        final label = _dayLabel(task.completedAt!);
        if (dailyCounts.containsKey(label)) {
          dailyCounts[label] = dailyCounts[label]! + 1;
        }

        // Count by priority
        final priorityKey = task.priority.name;
        priorityCounts[priorityKey] = (priorityCounts[priorityKey] ?? 0) + 1;
      }
    }

    return {
      'daily': dailyCounts,
      'priority': priorityCounts,
      'total': totalCompletions,
    };
  }

  String _dayLabel(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }
}