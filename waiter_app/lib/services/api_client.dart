import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  final String baseUrl;
  final Duration timeout;

  ApiClient({required this.baseUrl, this.timeout = const Duration(seconds: 10)});

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _defaultHeaders([String? token]) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {String? token}) async {
    final uri = _uri(path);
    final res = await http
        .post(uri, body: jsonEncode(body), headers: _defaultHeaders(token))
        .timeout(timeout);
    return _decodeOrThrow(res.statusCode, res.body);
  }

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final uri = _uri(path);
    final res = await http.get(uri, headers: _defaultHeaders(token)).timeout(timeout);
    return _decodeOrThrow(res.statusCode, res.body);
  }

  Future<List<dynamic>> getList(String path, {String? token}) async {
    final uri = _uri(path);
    final res = await http.get(uri, headers: _defaultHeaders(token)).timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw ApiException('GET $path failed: ${res.statusCode} ${res.body}');
  }

  Map<String, dynamic> _decodeOrThrow(int statusCode, String body) {
    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) return {};
      return jsonDecode(body) as Map<String, dynamic>;
    }
    throw ApiException('Request failed: $statusCode $body');
  }
}

