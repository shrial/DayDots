import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/task_card.dart';
import '../widgets/progress_ring.dart';
import '../models/task_model.dart';
import 'add_task_screen.dart';
import 'routine_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DayDots ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              formatDate(DateTime.now()),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          // Dashboard button
          IconButton(
            icon: Text('📊', style: TextStyle(fontSize: 20),),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DashboardScreen()),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Progress ring + summary row
            _buildSummaryCard(provider),

            const SizedBox(height: 20),

            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Tasks (${provider.incompleteTasks.length} left)",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See all',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),

            // Task list
            Expanded(
              child: provider.isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
                  : provider.tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                itemCount: provider.tasks.length,
                itemBuilder: (context, index) {
                  final task = provider.tasks[index];
                  return TaskCard(
                    task: task,
                    onToggle: () => provider.toggleComplete(task.id),
                    onDelete: () => provider.deleteTask(task.id),
                    onStartRoutine: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoutineScreen(task: task),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB to add task
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: Text('➕', style: TextStyle(fontSize: 20),),
        label: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ProgressRing(
            progress: provider.completionRate,
            size: 90,
            label: 'Done',
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.completedTasks.length} of ${provider.tasks.length} tasks done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statChip('🔴 ${_countPriority(provider, Priority.urgent)}', AppColors.urgent),
                    const SizedBox(width: 8),
                    _statChip('🔁 ${_countPriority(provider, Priority.recurring)}', AppColors.recurring),
                    const SizedBox(width: 8),
                    _statChip('🔵 ${_countPriority(provider, Priority.normal)}', AppColors.normal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  int _countPriority(TaskProvider provider, Priority p) =>
      provider.tasks.where((t) => t.priority == p).length;

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + Add Task to get started',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}