import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config['color'], width: 1.2),
      ),
      child: Text(
        config['label'],
        style: TextStyle(
          color: config['color'],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig() {
    switch (priority) {
      case Priority.urgent:
        return {'color': AppColors.urgent, 'label': '🔴 Urgent'};
      case Priority.recurring:
        return {'color': AppColors.recurring, 'label': '🔁 Recurring'};
      case Priority.normal:
        return {'color': AppColors.normal, 'label': '🔵 Normal'};
    }
  }
}