import 'dart:convert';
import './api_exception.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  });
  
// GET REQUEST
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {...defaultHeaders, ...?headers},
      );
      return _handleResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }
  
// POST REQUEST
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {...defaultHeaders, ...?headers},
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

// PATCH REQUEST
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl$endpoint"),
        headers: {...defaultHeaders, ...?headers},
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

// DELETE REQUEST
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);
      final response = await http.delete(
        uri,
        headers: {...defaultHeaders, ...?headers},
      );
      return _handleResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

// PUT REQUEST (Optional)
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl$endpoint"),
        headers: {...defaultHeaders, ...?headers},
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
  final statusCode = response.statusCode;
  
  // Handle empty response body
  if (response.body.isEmpty) {
    if (statusCode >= 200 && statusCode < 300) {
      return {'success': true, 'statusCode': statusCode};
    }
    throw ApiException(
      'Request failed with status: $statusCode',
      statusCode: statusCode,
    );
  }

  try {
    final responseBody = jsonDecode(response.body);
    
    print('Response body decoded: $responseBody');
    print('Response body type: ${responseBody.runtimeType}');

    if (statusCode >= 200 && statusCode < 300) {
      // Success response
      if (responseBody is List) {
        return {'data': responseBody};
      }
      if (responseBody is Map<String, dynamic>) {
        return responseBody;
      }
      throw ApiException("Unknown format Exception");
    }

    // Handle error responses (400, 401, 403, 404, 500, etc.)
    // The error body could be a List or a Map
    String errorMessage = 'Request failed';
    
    if (responseBody is List) {
      // If it's a list of errors, join them
      if (responseBody.isNotEmpty) {
        errorMessage = responseBody.map((e) => e.toString()).join(', ');
      }
    } else if (responseBody is Map<String, dynamic>) {
      errorMessage = responseBody['message'] ?? 
                     responseBody['error'] ?? 
                     responseBody['errors']?.toString() ??
                     'Request failed';
    } else if (responseBody is String) {
      errorMessage = responseBody;
    }
    
    print('Error message: $errorMessage');
    
    // Throw appropriate exception based on status code
    switch (statusCode) {
      case 400:
        throw BadRequestException(errorMessage);
      case 401:
        throw UnauthorizedException(errorMessage);
      case 403:
        throw ForbiddenException(errorMessage);
      case 404:
        throw NotFoundException(errorMessage);
      case 500:
      case 502:
      case 503:
        throw ServerException(errorMessage);
      default:
        throw ApiException(errorMessage, statusCode: statusCode);
    }
    
  } catch (e) {
    if (e is ApiException) rethrow;
    if (e is FormatException) {
      throw FormatException("Invalid JSON response: ${response.body}");
    }
    throw ApiException(
      "Error processing response: $e",
      statusCode: statusCode,
    );
  }
}

  Exception _handleError(dynamic error) {
    if (error is http.ClientException) {
      return NetworkException('No internet connection or network error');
    }
    if (error is FormatException) {
      return ApiException('Invalid data format: ${error.message}');
    }
    if (error is ApiException) {
      return error;
    }
    return ApiException('Unknown error occurred: $error');
  }
}

// Add NotFoundException if not already in your api_exceptions.dart
class NotFoundException extends ApiException {
  NotFoundException(super.message) : super(statusCode: 404);
}