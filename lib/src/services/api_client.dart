import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/exceptions.dart';

/// Abstract interface for API client operations
abstract class ApiClient {
  /// Sends a POST request to the specified endpoint with the given data
  /// 
  /// [endpoint] - The API endpoint path (relative to base URL)
  /// [data] - The request body data to be sent as JSON
  /// 
  /// Returns the parsed JSON response as a Map
  /// Throws [NetworkException] for network-related errors
  /// Throws [ApiException] for API-related errors
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data);
  
  /// Sends a GET request to the specified endpoint
  /// 
  /// [endpoint] - The API endpoint path (relative to base URL)
  /// 
  /// Returns the parsed JSON response as a Map
  /// Throws [NetworkException] for network-related errors
  /// Throws [ApiException] for API-related errors
  Future<Map<String, dynamic>> get(String endpoint);
  
  /// Sets the authentication token for subsequent requests
  /// 
  /// [token] - The authentication token to be used in Authorization header
  void setAuthToken(String token);
  
  /// Clears the authentication token
  void clearAuthToken();
}

/// HTTP implementation of the ApiClient interface
class HttpApiClient implements ApiClient {
  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;
  final Map<String, String> _defaultHeaders;
  String? _authToken;
  
  /// Creates an HttpApiClient instance
  /// 
  /// [baseUrl] - The base URL for all API requests
  /// [client] - Optional HTTP client (useful for testing)
  /// [timeout] - Request timeout duration (defaults to 30 seconds)
  /// [defaultHeaders] - Default headers to include in all requests
  HttpApiClient({
    required String baseUrl,
    http.Client? client,
    Duration timeout = const Duration(seconds: 30),
    Map<String, String> defaultHeaders = const {},
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
       _timeout = timeout,
       _defaultHeaders = Map.from(defaultHeaders);

  @override
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = _buildHeaders();
      
      final response = await _client
          .post(
            uri,
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw NetworkException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = _buildHeaders();
      
      final response = await _client
          .get(uri, headers: headers)
          .timeout(_timeout);
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw NetworkException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  void setAuthToken(String token) {
    _authToken = token;
  }

  @override
  void clearAuthToken() {
    _authToken = null;
  }

  /// Builds the complete URI for the given endpoint
  Uri _buildUri(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return Uri.parse('$_baseUrl$cleanEndpoint');
  }

  /// Builds headers for the request including auth token if available
  Map<String, String> _buildHeaders() {
    final headers = Map<String, String>.from(_defaultHeaders);
    headers['Content-Type'] = 'application/json';
    headers['Accept'] = 'application/json';
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  /// Handles HTTP response and converts to Map or throws appropriate exceptions
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // Try to parse response body as JSON
    Map<String, dynamic>? responseData;
    try {
      if (response.body.isNotEmpty) {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // If JSON parsing fails, create a simple error response
      responseData = {'error': 'Invalid JSON response', 'message': response.body};
    }
    
    // Handle successful responses (2xx status codes)
    if (statusCode >= 200 && statusCode < 300) {
      return responseData ?? {};
    }
    
    // Extract error message from response
    String errorMessage = 'Request failed';
    String? errorCode;
    
    if (responseData != null) {
      errorMessage = responseData['message'] ?? 
                    responseData['error'] ?? 
                    responseData['detail'] ?? 
                    'Request failed';
      errorCode = responseData['code']?.toString();
    }
    
    // Handle specific HTTP status codes
    switch (statusCode) {
      case 400:
        throw ApiException('Bad Request: $errorMessage', statusCode, errorCode);
      case 401:
        throw ApiException('Unauthorized: $errorMessage', statusCode, errorCode);
      case 403:
        throw ApiException('Forbidden: $errorMessage', statusCode, errorCode);
      case 404:
        throw ApiException('Not Found: $errorMessage', statusCode, errorCode);
      case 422:
        // Handle validation errors specially
        if (responseData != null && responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>?;
          if (errors != null) {
            final fieldErrors = <String, List<String>>{};
            errors.forEach((key, value) {
              if (value is List) {
                fieldErrors[key] = value.map((e) => e.toString()).toList();
              } else {
                fieldErrors[key] = [value.toString()];
              }
            });
            throw ValidationException(errorMessage, fieldErrors);
          }
        }
        throw ApiException('Validation Error: $errorMessage', statusCode, errorCode);
      case 500:
        throw ApiException('Internal Server Error: $errorMessage', statusCode, errorCode);
      case 502:
        throw NetworkException('Bad Gateway: Server is temporarily unavailable');
      case 503:
        throw NetworkException('Service Unavailable: Server is temporarily unavailable');
      case 504:
        throw NetworkException('Gateway Timeout: Server response timeout');
      default:
        throw ApiException('HTTP Error $statusCode: $errorMessage', statusCode, errorCode);
    }
  }

  /// Disposes of the HTTP client resources
  void dispose() {
    _client.close();
  }
}