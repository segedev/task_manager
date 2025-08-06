import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/api_service.dart';
import 'package:uuid/uuid.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Task> get overdueTasks => _tasks.where((t) => t.isOverdue).toList();
  List<Task> get todayTasks =>
      _tasks
          .where(
            (t) =>
                t.dueDate != null &&
                t.status != TaskStatus.completed &&
                isSameDay(t.dueDate!, DateTime.now()),
          )
          .toList();

  final ApiService _apiService = ApiService();
  final Box<Task> _taskBox = Hive.box<Task>('tasks');

  TaskProvider() {
    _loadTasksFromLocal();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _loadTasksFromLocal() {
    _tasks = _taskBox.values.toList();
    _updateTaskStatuses();
    _tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  void _updateTaskStatuses() {
    final now = DateTime.now();
    for (var task in _tasks) {
      if (task.status != TaskStatus.completed &&
          task.dueDate != null &&
          now.isAfter(task.dueDate!)) {
        final updatedTask = task.copyWith(status: TaskStatus.overdue);
        _taskBox.put(task.id, updatedTask);
      }
    }
  }

  Future<void> loadTasks() async {
    _setLoading(true);

    try {
      _loadTasksFromLocal();

      // Simulate API sync
      await Future.delayed(const Duration(milliseconds: 600));
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((t) => t.projectId == projectId).toList();
  }

  Future<void> createTask({
    required String title,
    required String description,
    required String projectId,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    try {
      final task = Task(
        id: const Uuid().v4(),
        title: title,
        description: description,
        projectId: projectId,
        priority: priority,
        status: TaskStatus.pending,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _taskBox.put(task.id, task);
      _tasks.insert(0, task);
      notifyListeners();

      // Simulate API sync
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = task.copyWith(updatedAt: DateTime.now());

      await _taskBox.put(updatedTask.id, updatedTask);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }

      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> toggleTaskStatus(String taskId) async {
    try {
      final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex == -1) return;

      final task = _tasks[taskIndex];
      final newStatus =
          task.status == TaskStatus.completed
              ? TaskStatus.pending
              : TaskStatus.completed;

      final completedAt =
          newStatus == TaskStatus.completed ? DateTime.now() : null;

      final updatedTask = task.copyWith(
        status: newStatus,
        completedAt: completedAt,
        updatedAt: DateTime.now(),
      );

      await _taskBox.put(updatedTask.id, updatedTask);
      _tasks[taskIndex] = updatedTask;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskBox.delete(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> addTasksFromAI(List<Task> aiTasks) async {
    try {
      for (final task in aiTasks) {
        await _taskBox.put(task.id, task);
        _tasks.insert(0, task);
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<String?> suggestNewTime(String taskId) async {
    try {
      // Simulate AI processing
      await Future.delayed(const Duration(seconds: 2));

      final now = DateTime.now();
      final suggestions = [
        'Tomorrow at 10:00 AM',
        'Next Monday at 2:00 PM',
        'This weekend at 9:00 AM',
        'End of this week at 3:00 PM',
      ];

      return suggestions[now.millisecond % suggestions.length];
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
