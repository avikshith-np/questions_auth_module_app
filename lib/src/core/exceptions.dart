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

  /// Gets all error messages for a specific field
  /// Returns an empty list if the field has no errors
  List<String> getFieldErrors(String fieldName) {
    return fieldErrors[fieldName] ?? [];
  }

  /// Gets the first error message for a specific field
  /// Returns null if the field has no errors
  String? getFirstFieldError(String fieldName) {
    final errors = getFieldErrors(fieldName);
    return errors.isNotEmpty ? errors.first : null;
  }

  /// Checks if a specific field has validation errors
  bool hasFieldError(String fieldName) {
    return fieldErrors.containsKey(fieldName) && fieldErrors[fieldName]!.isNotEmpty;
  }

  /// Gets all field names that have validation errors
  List<String> get errorFields => fieldErrors.entries
      .where((entry) => entry.value.isNotEmpty)
      .map((entry) => entry.key)
      .toList();

  /// Gets all error messages as a flat list
  List<String> get allErrorMessages {
    final List<String> allErrors = [];
    fieldErrors.forEach((field, errors) {
      allErrors.addAll(errors);
    });
    return allErrors;
  }

  /// Gets the first error message from any field
  /// Returns null if there are no errors
  String? get firstErrorMessage {
    for (final errors in fieldErrors.values) {
      if (errors.isNotEmpty) {
        return errors.first;
      }
    }
    return null;
  }

  /// Gets the total number of validation errors across all fields
  int get totalErrorCount {
    return fieldErrors.values.fold(0, (sum, errors) => sum + errors.length);
  }

  /// Creates a user-friendly error message that combines all field errors
  String get detailedMessage {
    if (fieldErrors.isEmpty) {
      return message;
    }

    final buffer = StringBuffer();
    if (message.isNotEmpty) {
      buffer.writeln(message);
    }

    fieldErrors.forEach((field, errors) {
      final fieldName = _formatFieldName(field);
      for (final error in errors) {
        buffer.writeln('• $fieldName: $error');
      }
    });

    return buffer.toString().trim();
  }

  /// Formats field names for user-friendly display
  String _formatFieldName(String fieldName) {
    // Convert snake_case and camelCase to Title Case
    return fieldName
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match.group(1)} ${match.group(2)}')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
  
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
  const TimeoutException(super.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

/// Exception thrown when device is offline or has no connectivity
class ConnectivityException extends NetworkException {
  const ConnectivityException(super.message);
  
  @override
  String toString() => 'ConnectivityException: $message';
}