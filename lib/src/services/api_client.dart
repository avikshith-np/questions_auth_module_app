import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/exceptions.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

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

  // Specific endpoint methods

  /// Registers a new user account
  /// 
  /// [request] - The signup request containing user registration data
  /// 
  /// Returns [SignUpResponse] with registration details
  /// Throws [ValidationException] for validation errors
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  Future<SignUpResponse> register(SignUpRequest request);

  /// Authenticates a user and returns login information
  /// 
  /// [request] - The login request containing user credentials
  /// 
  /// Returns [LoginResponse] with authentication token and user profile data
  /// Throws [ApiException] for authentication failures
  /// Throws [NetworkException] for network-related errors
  Future<LoginResponse> login(LoginRequest request);

  /// Gets the current authenticated user's profile information
  /// 
  /// Returns [UserProfileResponse] with comprehensive user profile data
  /// Throws [ApiException] for authentication or authorization errors
  /// Throws [NetworkException] for network-related errors
  Future<UserProfileResponse> getCurrentUser();

  /// Logs out the current user and invalidates the token
  /// 
  /// Returns [LogoutResponse] with logout confirmation
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  Future<LogoutResponse> logout();
}

/// HTTP implementation of the ApiClient interface
class HttpApiClient implements ApiClient {
  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;
  final Map<String, String> _defaultHeaders;
  final int _maxRetries;
  final Duration _retryDelay;
  final Connectivity _connectivity;
  String? _authToken;
  
  /// Creates an HttpApiClient instance
  /// 
  /// [baseUrl] - The base URL for all API requests
  /// [client] - Optional HTTP client (useful for testing)
  /// [timeout] - Request timeout duration (defaults to 30 seconds)
  /// [defaultHeaders] - Default headers to include in all requests
  /// [maxRetries] - Maximum number of retry attempts for failed requests (defaults to 3)
  /// [retryDelay] - Delay between retry attempts (defaults to 1 second)
  /// [connectivity] - Connectivity checker (useful for testing)
  HttpApiClient({
    required String baseUrl,
    http.Client? client,
    Duration timeout = const Duration(seconds: 30),
    Map<String, String> defaultHeaders = const {},
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    Connectivity? connectivity,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
       _timeout = timeout,
       _defaultHeaders = Map.from(defaultHeaders),
       _maxRetries = maxRetries,
       _retryDelay = retryDelay,
       _connectivity = connectivity ?? Connectivity();

  @override
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    return _executeWithRetry(() async {
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
    });
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    return _executeWithRetry(() async {
      final uri = _buildUri(endpoint);
      final headers = _buildHeaders();
      
      final response = await _client
          .get(uri, headers: headers)
          .timeout(_timeout);
      
      return _handleResponse(response);
    });
  }

  @override
  void setAuthToken(String token) {
    _authToken = token;
  }

  @override
  void clearAuthToken() {
    _authToken = null;
  }

  @override
  Future<SignUpResponse> register(SignUpRequest request) async {
    try {
      final response = await post('/accounts/register/', request.toJson());
      return SignUpResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await post('/accounts/login/', request.toJson());
      return LoginResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProfileResponse> getCurrentUser() async {
    try {
      final response = await get('/accounts/me/');
      return UserProfileResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LogoutResponse> logout() async {
    try {
      final response = await post('/logout/', {});
      return LogoutResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
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
      headers['Authorization'] = 'Token $_authToken';
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
    String errorMessage = _extractErrorMessage(responseData, statusCode);
    String? errorCode = responseData?['code']?.toString();
    
    // Handle specific HTTP status codes with user-friendly messages
    switch (statusCode) {
      case 400:
        // Handle field-specific validation errors for 400 status
        if (responseData != null) {
          final fieldErrors = _parseFieldErrorsFromResponse(responseData);
          // Only throw ValidationException if we have actual field errors (not just general errors)
          if (fieldErrors.isNotEmpty && _hasActualFieldErrors(fieldErrors, responseData)) {
            throw ValidationException(_getUserFriendlyMessage(400, errorMessage), fieldErrors);
          }
        }
        throw ApiException(_getUserFriendlyMessage(400, errorMessage), statusCode, errorCode);
      case 401:
        throw ApiException(_getUserFriendlyMessage(401, errorMessage), statusCode, errorCode);
      case 403:
        throw ApiException(_getUserFriendlyMessage(403, errorMessage), statusCode, errorCode);
      case 404:
        throw ApiException(_getUserFriendlyMessage(404, errorMessage), statusCode, errorCode);
      case 422:
        // Handle validation errors specially
        if (responseData != null && responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>?;
          if (errors != null) {
            final fieldErrors = _parseFieldErrors(errors);
            throw ValidationException(_getUserFriendlyMessage(422, errorMessage), fieldErrors);
          }
        }
        throw ApiException(_getUserFriendlyMessage(422, errorMessage), statusCode, errorCode);
      case 429:
        throw ApiException(_getUserFriendlyMessage(429, errorMessage), statusCode, errorCode);
      case 500:
        throw ApiException(_getUserFriendlyMessage(500, errorMessage), statusCode, errorCode);
      case 502:
        throw NetworkException(_getUserFriendlyMessage(502, 'Server is temporarily unavailable'));
      case 503:
        throw NetworkException(_getUserFriendlyMessage(503, 'Server is temporarily unavailable'));
      case 504:
        throw TimeoutException('Server response timeout');
      default:
        throw ApiException(_getUserFriendlyMessage(statusCode, errorMessage), statusCode, errorCode);
    }
  }

  /// Extracts error message from response data
  String _extractErrorMessage(Map<String, dynamic>? responseData, int statusCode) {
    if (responseData == null) {
      return _getDefaultErrorMessage(statusCode);
    }

    // Try different common error message fields
    final message = responseData['message'] ?? 
                   responseData['error'] ?? 
                   responseData['detail'] ?? 
                   responseData['error_description'] ??
                   responseData['msg'];

    if (message != null) {
      return message.toString();
    }

    // If no message found, try to extract from errors object
    if (responseData.containsKey('errors')) {
      final errors = responseData['errors'];
      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        } else if (firstError is String) {
          return firstError;
        }
      } else if (errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      } else if (errors is String) {
        return errors;
      }
    }

    return _getDefaultErrorMessage(statusCode);
  }

  /// Parses field errors from API response
  Map<String, List<String>> _parseFieldErrors(Map<String, dynamic> errors) {
    final fieldErrors = <String, List<String>>{};
    
    errors.forEach((key, value) {
      if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        fieldErrors[key] = [value];
      } else {
        fieldErrors[key] = [value.toString()];
      }
    });
    
    return fieldErrors;
  }

  /// Parses field-specific errors from API response data
  /// Handles various error response formats from the API
  Map<String, List<String>> _parseFieldErrorsFromResponse(Map<String, dynamic> responseData) {
    final fieldErrors = <String, List<String>>{};
    
    // Check for direct field errors (e.g., {"email": ["user with this email already exists."]})
    responseData.forEach((key, value) {
      // Skip non-field keys like 'detail', 'message', 'code', etc.
      if (_isFieldErrorKey(key)) {
        if (value is List) {
          fieldErrors[key] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          fieldErrors[key] = [value];
        } else if (value != null) {
          fieldErrors[key] = [value.toString()];
        }
      }
    });
    
    // Check for nested errors object
    if (responseData.containsKey('errors') && responseData['errors'] is Map<String, dynamic>) {
      final nestedErrors = responseData['errors'] as Map<String, dynamic>;
      final parsedNestedErrors = _parseFieldErrors(nestedErrors);
      fieldErrors.addAll(parsedNestedErrors);
    }
    
    return fieldErrors;
  }

  /// Determines if a response key represents a field error
  bool _isFieldErrorKey(String key) {
    // Common non-field keys that should not be treated as field errors
    const nonFieldKeys = {
      'detail',
      'message',
      'error',
      'code',
      'status',
      'success',
      'data',
      'errors',
      'non_field_errors',
      '__all__',
    };
    
    return !nonFieldKeys.contains(key.toLowerCase());
  }

  /// Determines if the field errors represent actual field validation errors
  /// vs general error messages that happen to be in field-like format
  bool _hasActualFieldErrors(Map<String, List<String>> fieldErrors, Map<String, dynamic> responseData) {
    // If we have a nested 'errors' object, it's likely field validation errors
    if (responseData.containsKey('errors') && responseData['errors'] is Map<String, dynamic>) {
      return true;
    }
    
    // If we have multiple field errors, it's likely validation errors
    if (fieldErrors.length > 1) {
      return true;
    }
    
    // If we have common field names, it's likely validation errors
    const commonFieldNames = {
      'email', 'password', 'username', 'display_name', 'confirm_password',
      'first_name', 'last_name', 'phone', 'address', 'name'
    };
    
    for (final fieldName in fieldErrors.keys) {
      if (commonFieldNames.contains(fieldName.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }

  /// Returns user-friendly error messages based on status code
  String _getUserFriendlyMessage(int statusCode, String originalMessage) {
    switch (statusCode) {
      case 400:
        return _isGenericMessage(originalMessage) 
            ? 'The request contains invalid data. Please check your input and try again.'
            : originalMessage;
      case 401:
        return _isGenericMessage(originalMessage)
            ? 'Authentication failed. Please check your credentials and try again.'
            : originalMessage;
      case 403:
        return _isGenericMessage(originalMessage)
            ? 'You do not have permission to perform this action.'
            : originalMessage;
      case 404:
        return _isGenericMessage(originalMessage)
            ? 'The requested resource was not found.'
            : originalMessage;
      case 422:
        return _isGenericMessage(originalMessage)
            ? 'The provided data is invalid. Please correct the errors and try again.'
            : originalMessage;
      case 429:
        return _isGenericMessage(originalMessage)
            ? 'Too many requests. Please wait a moment and try again.'
            : originalMessage;
      case 500:
        return _isGenericMessage(originalMessage)
            ? 'A server error occurred. Please try again later.'
            : originalMessage;
      case 502:
        return 'The server is temporarily unavailable. Please try again later.';
      case 503:
        return 'The service is temporarily unavailable. Please try again later.';
      case 504:
        return 'The request timed out. Please check your connection and try again.';
      default:
        return _isGenericMessage(originalMessage)
            ? 'An unexpected error occurred. Please try again later.'
            : originalMessage;
    }
  }

  /// Returns default error message for status code
  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 422:
        return 'Validation Error';
      case 429:
        return 'Too Many Requests';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      case 504:
        return 'Gateway Timeout';
      default:
        return 'Request Failed';
    }
  }

  /// Checks if the message is generic and should be replaced with user-friendly version
  bool _isGenericMessage(String message) {
    final genericMessages = [
      'Request failed',
      'Bad Request',
      'Unauthorized',
      'Forbidden',
      'Not Found',
      'Validation Error',
      'Too Many Requests',
      'Internal Server Error',
      'Bad Gateway',
      'Service Unavailable',
      'Gateway Timeout',
    ];
    
    return genericMessages.any((generic) => 
        message.toLowerCase().contains(generic.toLowerCase()));
  }

  /// Executes a request with retry logic and connectivity checking
  Future<Map<String, dynamic>> _executeWithRetry(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    // Check connectivity before making the request
    await _checkConnectivity();
    
    int attempts = 0;
    Exception? lastException;
    
    while (attempts <= _maxRetries) {
      try {
        return await request();
      } on TimeoutException catch (e) {
        lastException = e;
        attempts++;
        if (attempts <= _maxRetries) {
          await Future.delayed(_retryDelay * attempts); // Exponential backoff
          continue;
        }
        rethrow;
      } on SocketException catch (e) {
        lastException = NetworkException('Network connection failed: ${e.message}');
        attempts++;
        if (attempts <= _maxRetries && _shouldRetryOnSocketException(e)) {
          await Future.delayed(_retryDelay * attempts);
          // Re-check connectivity before retry
          await _checkConnectivity();
          continue;
        }
        throw lastException!;
      } on HttpException catch (e) {
        lastException = NetworkException('HTTP error: ${e.message}');
        attempts++;
        if (attempts <= _maxRetries) {
          await Future.delayed(_retryDelay * attempts);
          continue;
        }
        throw lastException!;
      } on FormatException catch (e) {
        // Don't retry format exceptions as they're likely permanent
        throw NetworkException('Invalid response format: ${e.message}');
      } on ApiException catch (e) {
        // Only retry on server errors (5xx), not client errors (4xx)
        if (e.statusCode >= 500 && e.statusCode < 600) {
          lastException = e;
          attempts++;
          if (attempts <= _maxRetries) {
            await Future.delayed(_retryDelay * attempts);
            continue;
          }
        }
        rethrow;
      } on AuthException {
        // Don't retry auth exceptions
        rethrow;
      } catch (e) {
        if (e.toString().contains('TimeoutException')) {
          lastException = TimeoutException('Request timed out after ${_timeout.inSeconds} seconds');
          attempts++;
          if (attempts <= _maxRetries) {
            await Future.delayed(_retryDelay * attempts);
            continue;
          }
          throw lastException!;
        }
        
        lastException = NetworkException('Unexpected error: ${e.toString()}');
        attempts++;
        if (attempts <= _maxRetries) {
          await Future.delayed(_retryDelay * attempts);
          continue;
        }
        throw lastException!;
      }
    }
    
    // This should never be reached, but just in case
    throw lastException ?? NetworkException('Request failed after $attempts attempts');
  }
  
  /// Checks network connectivity and throws ConnectivityException if offline
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      // Check if connectivity result is 'none' (offline)
      if (connectivityResult == ConnectivityResult.none) {
        throw const ConnectivityException(
          'No internet connection available. Please check your network settings and try again.'
        );
      }
    } catch (e) {
      if (e is ConnectivityException) {
        rethrow;
      }
      // If connectivity check fails, continue with the request
      // The actual network error will be caught during the HTTP request
    }
  }
  
  /// Determines if a SocketException should trigger a retry
  bool _shouldRetryOnSocketException(SocketException e) {
    // Retry on connection refused, timeout, or network unreachable
    final retryableMessages = [
      'Connection refused',
      'Connection timed out',
      'Network is unreachable',
      'Host is unreachable',
      'Connection reset by peer',
      'Broken pipe',
    ];
    
    return retryableMessages.any((message) => 
        e.message.toLowerCase().contains(message.toLowerCase()));
  }

  /// Disposes of the HTTP client resources
  void dispose() {
    _client.close();
  }
}