import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/models/project.dart';
import 'package:task_manager/services/api_service.dart';
import 'package:uuid/uuid.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();
  final Box<Project> _projectBox = Hive.box<Project>('projects');

  ProjectProvider() {
    _loadProjectsFromLocal();
  }

  void _loadProjectsFromLocal() {
    _projects = _projectBox.values.where((p) => !p.isArchived).toList();
    _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  Future<void> loadProjects(String userId) async {
    _setLoading(true);

    try {
      // Load from local first
      _loadProjectsFromLocal();

      // Simulate API sync
      await Future.delayed(const Duration(milliseconds: 800));

      // Filter by user
      _projects = _projects.where((p) => p.userId == userId).toList();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createProject({
    required String name,
    required String description,
    required String userId,
    String color = '#2196F3',
  }) async {
    _setLoading(true);

    try {
      final project = Project(
        id: const Uuid().v4(),
        name: name,
        description: description,
        color: color,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save locally first
      await _projectBox.put(project.id, project);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _projects.insert(0, project);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      final updatedProject = project.copyWith(updatedAt: DateTime.now());

      await _projectBox.put(updatedProject.id, updatedProject);

      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = updatedProject;
        notifyListeners();
      }

      // Simulate API sync
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _projectBox.delete(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();

      // Simulate API sync
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _setError(e.toString());
    }
  }

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
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
