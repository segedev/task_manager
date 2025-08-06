import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/models/user.dart';
import 'package:task_manager/services/api_service.dart';
import 'package:uuid/uuid.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  final ApiService _apiService = ApiService();
  final Box<User> _userBox = Hive.box<User>('users');

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      // Try to get user from local storage
      final userId = prefs.getString('user_id');
      if (userId != null) {
        _user = _userBox.get(userId);
        if (_user != null) {
          _isAuthenticated = true;
          notifyListeners();
        }
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      if (!email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Create or get existing user
      final existingUser = _userBox.values.firstWhere(
        (user) => user.email == email,
        orElse:
            () => User(
              id: const Uuid().v4(),
              email: email,
              name: email.split('@')[0],
              createdAt: DateTime.now(),
            ),
      );

      // Save user locally
      await _userBox.put(existingUser.id, existingUser);

      // Save auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_token_${existingUser.id}');
      await prefs.setString('user_id', existingUser.id);

      _user = existingUser;
      _isAuthenticated = true;

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }

      if (!email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Check if user already exists
      final existingUser = _userBox.values.where((user) => user.email == email);
      if (existingUser.isNotEmpty) {
        throw Exception('User with this email already exists');
      }

      final newUser = User(
        id: const Uuid().v4(),
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _userBox.put(newUser.id, newUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_token_${newUser.id}');
      await prefs.setString('user_id', newUser.id);

      _user = newUser;
      _isAuthenticated = true;

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');

    _user = null;
    _isAuthenticated = false;
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
