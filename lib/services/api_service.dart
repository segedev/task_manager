class ApiService {
  static const String baseUrl = 'https://api.example.com';

  // Mock API responses with delays to simulate real network calls

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'test@example.com' && password == 'password') {
      return {
        'success': true,
        'token': 'mock_jwt_token',
        'user': {'id': '1', 'email': email, 'name': 'Test User'},
      };
    }

    return {'success': false, 'error': 'Invalid credentials'};
  }

  Future<Map<String, dynamic>> syncProjects(
    List<Map<String, dynamic>> projects,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {'success': true, 'synced': projects.length};
  }

  Future<Map<String, dynamic>> syncTasks(
    List<Map<String, dynamic>> tasks,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {'success': true, 'synced': tasks.length};
  }
}
