import 'dart:async';
import 'dart:io';

import 'api_client.dart';
import 'backend_service.dart';

class SessionManager {
  ApiClient apiClient;
  String baseUrl;
  String? _token;
  Timer? _inactivityTimer;

  /// If [autoLoginToken] is provided the session will be pre-authenticated using that token.
  SessionManager({ApiClient? apiClient, this.baseUrl = 'http://localhost:3000', String? autoLoginToken}) : apiClient = apiClient ?? ApiClient(baseUrl: baseUrl) {
    if (autoLoginToken != null && autoLoginToken.isNotEmpty) {
      _token = autoLoginToken;
    }
  }

  /// Replace the API client's base URL at runtime.
  void setBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
    apiClient = ApiClient(baseUrl: newBaseUrl, timeout: apiClient.timeout);
  }

  /// Helper to return a host suitable for Android emulator when using a
  /// development server running on the host machine. Use `10.0.2.2` for the
  /// default Android emulator when testing instead of `localhost`.
  static String emulatorHostFor(String host) {
    if (host.startsWith('http://localhost') || host.startsWith('https://localhost')) {
      return host.replaceFirst('localhost', '10.0.2.2');
    }
    return host;
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

  /// Try a list of candidate base URLs and pick the first that responds to
  /// GET /api/menu. This helps when running the app on emulators/devices.
  /// Returns a list of probe results. Each result contains:
  /// { 'base': String, 'ok': bool, 'error': String? }
  Future<List<Map<String, dynamic>>> detectAndSetWorkingBaseUrl({Duration timeout = const Duration(seconds: 2)}) async {
    final tried = <String>{};
    final candidates = <String>['http://localhost:3000', 'http://127.0.0.1:3000', 'http://10.0.2.2:3000'];

    // Add local LAN addresses if available
    try {
      for (final iface in await NetworkInterface.list()) {
        for (final addr in iface.addresses) {
          final a = addr.address;
          if (a.contains('.') && !a.startsWith('127.') && !a.startsWith('10.')) {
            candidates.add('http://$a:3000');
          }
        }
      }
    } catch (_) {
      // ignore network interface errors
    }

    final results = <Map<String, dynamic>>[];
    for (final c in candidates) {
      if (tried.contains(c)) continue;
      tried.add(c);
      final probe = ApiClient(baseUrl: c, timeout: timeout);
      try {
        await probe.get('/api/menu');
        // success
        baseUrl = c;
        apiClient = ApiClient(baseUrl: c, timeout: apiClient.timeout);
        results.add({'base': c, 'ok': true, 'error': null});
        return results;
      } catch (e) {
        results.add({'base': c, 'ok': false, 'error': e.toString()});
      }
    }
    // If none worked, keep existing baseUrl
    return results;
  }

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
