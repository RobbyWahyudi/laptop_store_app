import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Base API Service with common HTTP methods
class ApiService {
  final String? token;

  ApiService({this.token});

  /// GET Request
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: ApiConfig.headers(token: token),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST Request
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.headers(token: token),
        body: jsonEncode(body ?? {}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// PUT Request
  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: ApiConfig.headers(token: token),
        body: jsonEncode(body ?? {}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// DELETE Request
  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.delete(
        uri,
        headers: ApiConfig.headers(token: token),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Handle HTTP Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    // For DELETE requests with 204 No Content, return success response
    if (response.statusCode == 204) {
      return {'success': true, 'message': 'Operation successful'};
    }

    // Check if response body is empty
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Operation successful'};
      }
      throw Exception('Server returned empty response');
    }

    try {
      final body = jsonDecode(response.body);

      // Handle error responses with specific format
      if (body is Map<String, dynamic> && body.containsKey('code')) {
        // This is an error response from the backend
        final message = body['message'] ?? 'An error occurred';
        final details = body['details'];
        throw Exception('$message${details != null ? ': $details' : ''}');
      }

      // Ensure body is a Map
      if (body is! Map<String, dynamic>) {
        throw Exception('Invalid response format from server');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        final message = body['message'] ?? 'An error occurred';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to parse server response: $e');
    }
  }
}
