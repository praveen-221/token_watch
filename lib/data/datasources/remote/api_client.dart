import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:token_watch/data/errors.dart';

class ApiClient {
  // Singleton private constructor
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  final http.Client _client = http.Client();
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> get(String url,
      {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final response = await _client.get(uri, headers: {
        ..._defaultHeaders,
        if (headers != null) ...headers,
      }).timeout(_defaultTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiError(408, 'Request timed out');
    }
  }

  Future<Map<String, dynamic>> post(String url,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse(url);
      final response = await _client
          .post(uri,
              headers: {
                ..._defaultHeaders,
                if (headers != null) ...headers,
              },
              body: jsonEncode(body ?? {}))
          .timeout(_defaultTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiError(408, 'Request timed out');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final status = response.statusCode;
    final String body = response.body;
    if (status >= 200 && status < 300) {
      try {
        if (body.isEmpty) return {};
        return jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        throw ParseError(body);
      }
    }

    // Rate limiting
    if (status == 429) {
      int? retrySeconds;
      try {
        final json = jsonDecode(body);
        if (json is Map && json.containsKey('retryAfter')) {
          retrySeconds = json['retryAfter'] as int?;
        }
      } catch (_) {}
      final retryAfter =
          retrySeconds != null ? Duration(seconds: retrySeconds) : null;
      throw RateLimitError(status, 'Rate limit exceeded',
          retryAfter: retryAfter);
    }

    // Auth errors
    if (status == 401 || status == 403) {
      throw AuthError(status, 'Unauthorized or forbidden');
    }

    // Other errors
    String message = 'HTTP error $status';
    try {
      final json = jsonDecode(body);
      if (json is Map && json.containsKey('message')) {
        message = json['message'];
      }
    } catch (_) {}
    throw ApiError(status, message);
  }
}
