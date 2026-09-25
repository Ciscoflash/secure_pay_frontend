import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.details});
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;
  @override
  String toString() => message;
}
class ApiClient {
  ApiClient({this.baseUrl = ApiConfig.baseUrl, http.Client? client})
    : _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;
  static const _timeout = Duration(seconds: 20);
  static Map<String, dynamic> dataOf(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected response from the server.');
    }
    return data;
  }
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) => _send('POST', path, body: body, token: token);
  Future<Map<String, dynamic>> get(
    String path, {
    String? token,
    Map<String, String>? query,
  }) => _send('GET', path, token: token, query: query);
  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: query == null || query.isEmpty ? null : query);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final http.Response response;
    try {
      response = await _request(method, uri, headers, body).timeout(_timeout);
    } on TimeoutException {
      throw ApiException('The server took too long to respond.');
    } on http.ClientException {
      throw ApiException('Unable to reach the server. Please try again.');
    } catch (_) {
      throw ApiException('A network error occurred. Please try again.');
    }
    final Map<String, dynamic> envelope;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException('Unexpected response from the server.');
      }
      envelope = decoded;
    } on FormatException {
      throw ApiException('Unexpected response from the server.');
    }
    if (response.statusCode >= 400) {
      throw ApiException(
        envelope['message']?.toString() ?? 'Request failed',
        statusCode: response.statusCode,
        details: _asStringMap(envelope['errors']),
      );
    }
    return envelope;
  }
  Future<http.Response> _request(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) {
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      default:
        return _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const {}),
        );
    }
  }
  Map<String, dynamic>? _asStringMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }
}
