import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _stepController = TextEditingController();

  String _selectedEmoji = '📝';
  Priority _selectedPriority = Priority.normal;
  TimeOfDay? _selectedTime;
  bool _isRecurring = false;
  final List<String> _steps = [];

  final List<String> _emojiOptions = [
    '📝', '💊', '🏃', '📚', '💧', '🍎', '🛁',
    '😴', '🧘', '🎯', '🛒', '📞', '💼', '🎨',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _addStep() {
    final text = _stepController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _steps.add(text);
        _stepController.clear();
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    DateTime? scheduledTime;
    if (_selectedTime != null) {
      final now = DateTime.now();
      scheduledTime = DateTime(
        now.year, now.month, now.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );
    }

    final task = Task(
      id: context.read<TaskProvider>().generateId(),
      title: _titleController.text.trim(),
      iconEmoji: _selectedEmoji,
      priority: _selectedPriority,
      scheduledTime: scheduledTime,
      isRecurring: _isRecurring,
      steps: _steps,
    );

    context.read<TaskProvider>().addTask(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Add New Task',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Text('⬅️', style: TextStyle(fontSize: 20),),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title input
            _sectionLabel('Task Title'),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 16),
              decoration: _inputDecoration('e.g. Take Morning Medication'),
            ),
            const SizedBox(height: 20),

            // Emoji picker
            _sectionLabel('Choose Icon'),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _emojiOptions.length,
                itemBuilder: (context, index) {
                  final emoji = _emojiOptions[index];
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Priority selector
            _sectionLabel('Priority'),
            Row(
              children: Priority.values.map((p) {
                final isSelected = _selectedPriority == p;
                final config = _priorityConfig(p);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? config['color'].withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? config['color']
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(config['emoji'],
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            config['label'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? config['color']
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Time picker
            _sectionLabel('Scheduled Time (optional)'),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Text("⏱️" ,style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Tap to set a time',
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedTime != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recurring toggle
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '🔁 Recurring Task',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Repeats every day'),
                value: _isRecurring,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _isRecurring = val),
              ),
            ),
            const SizedBox(height: 20),

            // Steps for routine mode
            _sectionLabel('Routine Steps (optional)'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepController,
                    decoration: _inputDecoration('e.g. Get a glass of water'),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addStep,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("➕", style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._steps.asMap().entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Text(
                    '${entry.key + 1}.',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(entry.value,
                          style: const TextStyle(fontSize: 14))),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _steps.removeAt(entry.key)),
                    child: Text("❌", style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 30),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Task ✅',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  Map<String, dynamic> _priorityConfig(Priority p) {
    switch (p) {
      case Priority.urgent:
        return {'color': AppColors.urgent, 'label': 'Urgent', 'emoji': '🔴'};
      case Priority.recurring:
        return {'color': AppColors.recurring, 'label': 'Recurring', 'emoji': '🔁'};
      case Priority.normal:
        return {'color': AppColors.normal, 'label': 'Normal', 'emoji': '🔵'};
    }
  }
}