import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/ai_provider.dart';
import 'package:task_manager/providers/project_provider.dart';
import 'package:task_manager/providers/task_provider.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showTaskOptions(context),
          ),
        ],
      ),
      body: Consumer3<TaskProvider, ProjectProvider, AIProvider>(
        builder: (context, taskProvider, projectProvider, aiProvider, child) {
          final project = projectProvider.getProjectById(task.projectId);
          final isCompleted = task.status == TaskStatus.completed;
          final isOverdue = task.isOverdue;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => taskProvider.toggleTaskStatus(task.id),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isCompleted ? Colors.green : Colors.grey,
                                  width: 2,
                                ),
                                color:
                                    isCompleted
                                        ? Colors.green
                                        : Colors.transparent,
                              ),
                              child:
                                  isCompleted
                                      ? const Icon(
                                        Icons.check,
                                        size: 20,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                decoration:
                                    isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                color: isCompleted ? Colors.grey : null,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Status and Priority Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                task.status,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              task.status.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(task.status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                task.priority,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${task.priority.name.toUpperCase()} PRIORITY',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getPriorityColor(task.priority),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Task Description
                if (task.description.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Description',
                    child: Text(
                      task.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Project Info
                if (project != null) ...[
                  _SectionCard(
                    title: 'Project',
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(
                                project.color.replaceFirst('#', '0xFF'),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.folder,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (project.description.isNotEmpty)
                                Text(
                                  project.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Due Date
                if (task.dueDate != null) ...[
                  _SectionCard(
                    title: 'Due Date',
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: isOverdue ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'EEEE, MMMM dd, yyyy',
                              ).format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isOverdue ? Colors.red : null,
                              ),
                            ),
                            Text(
                              DateFormat('hh:mm a').format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isOverdue ? Colors.red : Colors.grey[600],
                              ),
                            ),
                            if (isOverdue)
                              const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        if (isOverdue && !isCompleted) ...[
                          ElevatedButton.icon(
                            onPressed:
                                aiProvider.isLoading
                                    ? null
                                    : () =>
                                        _suggestNewTime(context, aiProvider),
                            icon:
                                aiProvider.isLoading
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.psychology, size: 16),
                            label: const Text('Suggest New Time'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Timestamps
                _SectionCard(
                  title: 'Timeline',
                  child: Column(
                    children: [
                      _TimelineItem(
                        icon: Icons.create,
                        title: 'Created',
                        date: task.createdAt,
                      ),
                      if (task.updatedAt != task.createdAt) ...[
                        const SizedBox(height: 12),
                        _TimelineItem(
                          icon: Icons.edit,
                          title: 'Last Updated',
                          date: task.updatedAt,
                        ),
                      ],
                      if (task.completedAt != null) ...[
                        const SizedBox(height: 12),
                        _TimelineItem(
                          icon: Icons.check_circle,
                          title: 'Completed',
                          date: task.completedAt!,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Task'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to edit task screen
                  },
                ),
                ListTile(
                  leading: Icon(
                    task.status == TaskStatus.completed
                        ? Icons.undo
                        : Icons.check,
                  ),
                  title: Text(
                    task.status == TaskStatus.completed
                        ? 'Mark as Incomplete'
                        : 'Mark as Complete',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    ).toggleTaskStatus(task.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Task',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text(
              'Are you sure you want to delete this task? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close task detail screen
                  Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).deleteTask(task.id);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Task deleted')));
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _suggestNewTime(
    BuildContext context,
    AIProvider aiProvider,
  ) async {
    final suggestion = await aiProvider.suggestTaskReschedule(task);

    if (suggestion != null && context.mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('AI Suggestion'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Based on your patterns and current workload, I suggest:',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Dismiss'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Implement rescheduling
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rescheduling feature coming soon!'),
                      ),
                    );
                  },
                  child: const Text('Apply Suggestion'),
                ),
              ],
            ),
      );
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.overdue:
        return Colors.red;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final DateTime date;
  final Color? color;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.date,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy at hh:mm a').format(date),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
