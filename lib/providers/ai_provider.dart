import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/ai_service.dart';

class AIProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Task> _generatedTasks = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Task> get generatedTasks => _generatedTasks;

  final AIService _aiService = AIService();

  Future<void> generateTasks(String prompt, String projectId) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate AI processing time
      await Future.delayed(const Duration(seconds: 3));

      final tasks = await _aiService.generateTasksFromPrompt(prompt, projectId);
      _generatedTasks = tasks;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> suggestTaskReschedule(Task task) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final suggestion = await _aiService.suggestReschedule(task);
      return suggestion;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void clearGeneratedTasks() {
    _generatedTasks = [];
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
