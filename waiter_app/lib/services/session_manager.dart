import 'dart:async';

import 'api_client.dart';
import 'backend_service.dart';

class SessionManager {
  final ApiClient apiClient;
  final String baseUrl;
  String? _token;
  Timer? _inactivityTimer;

  SessionManager({ApiClient? apiClient, this.baseUrl = 'https://localhost:3000'}) : apiClient = apiClient ?? ApiClient(baseUrl: baseUrl);

  Duration get inactivityTimeout => const Duration(minutes: 30);

  BackendService get backend => BackendService(client: apiClient, token: _token);

  Future<bool> login(String username, String password) async {
    try {
      final res = await apiClient.post('/auth/login', {'username': username, 'password': password});
      _token = res['token'] as String?;
      _resetTimer();
      return _token != null;
    } catch (e) {
      return false;
    }
  }

  String? get token => _token;

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityTimeout, () {
      _token = null;
    });
  }

  void touch() => _resetTimer();

  void logout() {
    _token = null;
    _inactivityTimer?.cancel();
  }
}
