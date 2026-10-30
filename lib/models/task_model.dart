import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { urgent, recurring, normal }

class Task {
  final String id;
  final String title;
  final String iconEmoji;
  final Priority priority;
  final DateTime? scheduledTime;
  final bool isCompleted;
  final bool isRecurring;
  final List<String> steps;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.iconEmoji,
    required this.priority,
    this.scheduledTime,
    this.isCompleted = false,
    this.isRecurring = false,
    this.steps = const [],
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'iconEmoji': iconEmoji,
    'priority': priority.name,
    'scheduledTime': scheduledTime != null
        ? Timestamp.fromDate(scheduledTime!)
        : null,
    'isCompleted': isCompleted,
    'isRecurring': isRecurring,
    'steps': steps,
    'completedAt': completedAt != null
        ? Timestamp.fromDate(completedAt!)
        : null,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    iconEmoji: map['iconEmoji'] ?? '📝',
    priority: Priority.values.byName(map['priority'] ?? 'normal'),
    scheduledTime: map['scheduledTime'] != null
        ? (map['scheduledTime'] as Timestamp).toDate()
        : null,
    isCompleted: map['isCompleted'] ?? false,
    isRecurring: map['isRecurring'] ?? false,
    steps: List<String>.from(map['steps'] ?? []),
    completedAt: map['completedAt'] != null
        ? (map['completedAt'] as Timestamp).toDate()
        : null,
  );

  Task copyWith({bool? isCompleted, DateTime? completedAt}) => Task(
    id: id,
    title: title,
    iconEmoji: iconEmoji,
    priority: priority,
    scheduledTime: scheduledTime,
    isCompleted: isCompleted ?? this.isCompleted,
    isRecurring: isRecurring,
    steps: steps,
    completedAt: completedAt ?? this.completedAt,
  );
}