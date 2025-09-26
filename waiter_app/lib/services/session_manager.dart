import 'dart:async';

import 'api_client.dart';
import 'backend_service.dart';

class SessionManager {
  ApiClient apiClient;
  String baseUrl;
  String? _token;
  Timer? _inactivityTimer;

  /// If [autoLoginToken] is provided the session will be pre-authenticated using that token.
  SessionManager({ApiClient? apiClient, this.baseUrl = 'https://localhost:3000', String? autoLoginToken}) : apiClient = apiClient ?? ApiClient(baseUrl: baseUrl) {
    if (autoLoginToken != null && autoLoginToken.isNotEmpty) {
      _token = autoLoginToken;
    }
  }

  /// Replace the API client's base URL at runtime.
  void setBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
    apiClient = ApiClient(baseUrl: newBaseUrl, timeout: apiClient.timeout);
  }

  /// Set the session token at runtime.
  void setToken(String? token) {
    _token = token;
    if (token != null) _resetTimer();
  }

  /// How often to poll backend resources when realtime push is not available.
  /// Default is 5 seconds.
  Duration backendPollInterval = const Duration(seconds: 5);

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
