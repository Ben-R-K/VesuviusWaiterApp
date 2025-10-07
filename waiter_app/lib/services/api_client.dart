import 'dart:async';
import 'dart:convert';


import 'package:http/http.dart' as http;
import 'dart:io' show SocketException;
import '../config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}


class ApiClient {
  final String baseUrl;
  final Duration timeout;

  ApiClient({String? baseUrl, this.timeout = const Duration(seconds: 10)})
      : baseUrl = baseUrl ?? apiBaseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Uri _uriForHost(String hostBase, String path) => Uri.parse('$hostBase$path');

  bool get _canUseEmulatorFallback => baseUrl.contains('localhost');

  String _emulatorBase() => baseUrl.replaceFirst('localhost', '10.0.2.2');

  Map<String, String> _defaultHeaders([String? token]) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {String? token}) async {
    final uri = _uri(path);
    try {
      final res = await http
          .post(uri, body: jsonEncode(body), headers: _defaultHeaders(token))
          .timeout(timeout);
      return _decodeOrThrow(res.statusCode, res.body);
    } on http.ClientException catch (e) {
      if (_canUseEmulatorFallback) {
        final altBase = _emulatorBase();
        final altUri = _uriForHost(altBase, path);
        try {
          final altRes = await http.post(altUri, body: jsonEncode(body), headers: _defaultHeaders(token)).timeout(timeout);
          return _decodeOrThrow(altRes.statusCode, altRes.body);
        } on Exception {
          throw ApiException('Network error posting to $uri and emulator fallback $altUri failed: ${e.message}.');
        }
      }
      throw ApiException('Network error posting to $uri: ${e.message}.');
    } on SocketException catch (e) {
      if (_canUseEmulatorFallback) {
        final altBase = _emulatorBase();
        final altUri = _uriForHost(altBase, path);
        try {
          final altRes = await http.post(altUri, body: jsonEncode(body), headers: _defaultHeaders(token)).timeout(timeout);
          return _decodeOrThrow(altRes.statusCode, altRes.body);
        } on Exception {
          throw ApiException('Socket error posting to $uri and emulator fallback $altUri failed: ${e.message}.');
        }
      }
      throw ApiException('Socket error posting to $uri: ${e.message}.');
    } on TimeoutException {
      throw ApiException('Request to $uri timed out after ${timeout.inSeconds}s.');
    } catch (e) {
      throw ApiException('Unknown error posting to $uri: $e');
    }
  }

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final uri = _uri(path);
    try {
      final res = await http.get(uri, headers: _defaultHeaders(token)).timeout(timeout);
      return _decodeOrThrow(res.statusCode, res.body);
    } on http.ClientException catch (e) {
      if (_canUseEmulatorFallback) {
        final altBase = _emulatorBase();
        final altUri = _uriForHost(altBase, path);
        try {
          final altRes = await http.get(altUri, headers: _defaultHeaders(token)).timeout(timeout);
          return _decodeOrThrow(altRes.statusCode, altRes.body);
        } on Exception {
          throw ApiException('Network error fetching $uri and emulator fallback $altUri failed: ${e.message}.');
        }
      }
      throw ApiException('Network error fetching $uri: ${e.message}.');
    } on SocketException catch (e) {
      if (_canUseEmulatorFallback) {
        final altBase = _emulatorBase();
        final altUri = _uriForHost(altBase, path);
        try {
          final altRes = await http.get(altUri, headers: _defaultHeaders(token)).timeout(timeout);
          return _decodeOrThrow(altRes.statusCode, altRes.body);
        } on Exception {
          throw ApiException('Socket error fetching $uri and emulator fallback $altUri failed: ${e.message}.');
        }
      }
      throw ApiException('Socket error fetching $uri: ${e.message}.');
    } on TimeoutException {
      throw ApiException('Request to $uri timed out after ${timeout.inSeconds}s.');
    } catch (e) {
      throw ApiException('Unknown error fetching $uri: $e');
    }
  }

  Future<List<dynamic>> getList(String path, {String? token}) async {
    final uri = _uri(path);
    try {
      final res = await http.get(uri, headers: _defaultHeaders(token)).timeout(timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as List<dynamic>;
      }
      throw ApiException('GET $path failed: ${res.statusCode} ${res.body}');
    } on http.ClientException catch (e) {
      if (_canUseEmulatorFallback) {
        final altBase = _emulatorBase();
        final altUri = _uriForHost(altBase, path);
        try {
          final altRes = await http.get(altUri, headers: _defaultHeaders(token)).timeout(timeout);
          if (altRes.statusCode >= 200 && altRes.statusCode < 300) return jsonDecode(altRes.body) as List<dynamic>;
          throw ApiException('GET $path fallback failed: ${altRes.statusCode} ${altRes.body}');
        } on Exception {
          throw ApiException('Network error fetching $uri and emulator fallback $altUri failed: ${e.message}.');
        }
      }
      throw ApiException('Network error fetching $uri: ${e.message}.');
    } on SocketException catch (e) {
      if (_canUseEmulatorFallback) {
        final altBase = _emulatorBase();
        final altUri = _uriForHost(altBase, path);
        try {
          final altRes = await http.get(altUri, headers: _defaultHeaders(token)).timeout(timeout);
          if (altRes.statusCode >= 200 && altRes.statusCode < 300) return jsonDecode(altRes.body) as List<dynamic>;
          throw ApiException('GET $path fallback failed: ${altRes.statusCode} ${altRes.body}');
        } on Exception {
          throw ApiException('Socket error fetching $uri and emulator fallback $altUri failed: ${e.message}.');
        }
      }
      throw ApiException('Socket error fetching $uri: ${e.message}.');
    } on TimeoutException {
      throw ApiException('Request to $uri timed out after ${timeout.inSeconds}s.');
    } catch (e) {
      throw ApiException('Unknown error fetching $uri: $e');
    }
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body, {String? token}) async {
    final uri = _uri(path);
    try {
      final res = await http
          .patch(uri, body: jsonEncode(body), headers: _defaultHeaders(token))
          .timeout(timeout);
      return _decodeOrThrow(res.statusCode, res.body);
    } on http.ClientException catch (e) {
      if (_canUseEmulatorFallback) {
        final altBase = _emulatorBase();
        final altUri = _uriForHost(altBase, path);
        try {
          final altRes = await http.patch(altUri, body: jsonEncode(body), headers: _defaultHeaders(token)).timeout(timeout);
          return _decodeOrThrow(altRes.statusCode, altRes.body);
        } on Exception {
          throw ApiException('Network error patching to $uri and emulator fallback $altUri failed: ${e.message}.');
        }
      }
      throw ApiException('Network error patching to $uri: ${e.message}.');
    } on SocketException catch (e) {
      if (_canUseEmulatorFallback) {
        final altBase = _emulatorBase();
        final altUri = _uriForHost(altBase, path);
        try {
          final altRes = await http.patch(altUri, body: jsonEncode(body), headers: _defaultHeaders(token)).timeout(timeout);
          return _decodeOrThrow(altRes.statusCode, altRes.body);
        } on Exception {
          throw ApiException('Socket error patching to $uri and emulator fallback $altUri failed: ${e.message}.');
        }
      }
      throw ApiException('Socket error patching to $uri: ${e.message}.');
    } on TimeoutException {
      throw ApiException('Request to $uri timed out after ${timeout.inSeconds}s.');
    } catch (e) {
      throw ApiException('Unknown error patching to $uri: $e');
    }
  }

  Map<String, dynamic> _decodeOrThrow(int statusCode, String body) {
    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) return {};
      return jsonDecode(body) as Map<String, dynamic>;
    }
    throw ApiException('Request failed: $statusCode $body');
  }
}

