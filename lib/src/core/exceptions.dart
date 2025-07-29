/// Base class for all authentication-related exceptions
abstract class AuthException implements Exception {
  /// The error message
  final String message;
  
  /// Optional error code for categorizing errors
  final String? code;
  
  const AuthException(this.message, [this.code]);
  
  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when network-related errors occur
class NetworkException extends AuthException {
  const NetworkException(String message) : super(message, 'NETWORK_ERROR');
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when validation errors occur
class ValidationException extends AuthException {
  /// Field-specific validation errors
  final Map<String, List<String>> fieldErrors;
  
  const ValidationException(String message, this.fieldErrors) 
      : super(message, 'VALIDATION_ERROR');
  
  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when API-related errors occur
class ApiException extends AuthException {
  /// HTTP status code from the API response
  final int statusCode;
  
  const ApiException(String message, this.statusCode, [String? code]) 
      : super(message, code);
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when token-related errors occur
class TokenException extends AuthException {
  const TokenException(String message) : super(message, 'TOKEN_ERROR');
  
  @override
  String toString() => 'TokenException: $message';
}

/// Exception thrown when request timeout occurs
class TimeoutException extends NetworkException {
  const TimeoutException(String message) : super(message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

/// Exception thrown when device is offline or has no connectivity
class ConnectivityException extends NetworkException {
  const ConnectivityException(String message) : super(message);
  
  @override
  String toString() => 'ConnectivityException: $message';
}