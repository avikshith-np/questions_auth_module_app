library;

/// Authentication result models
import 'user.dart';
import 'auth_response.dart';

/// Result model for public API responses with error handling
class AuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
  final LoginResponse? loginData;
  final SignUpResponse? signUpData;

  const AuthResult({
    required this.success,
    this.user,
    this.token,
    this.error,
    this.fieldErrors,
    this.loginData,
    this.signUpData,
  });

  /// Creates a successful AuthResult
  factory AuthResult.success({
    User? user,
    String? token,
    LoginResponse? loginData,
    SignUpResponse? signUpData,
  }) {
    return AuthResult(
      success: true,
      user: user,
      token: token,
      loginData: loginData,
      signUpData: signUpData,
    );
  }

  /// Creates a failed AuthResult with a general error message
  factory AuthResult.failure({
    String? error,
    Map<String, List<String>>? fieldErrors,
  }) {
    return AuthResult(
      success: false,
      error: error,
      fieldErrors: fieldErrors,
    );
  }

  /// Creates AuthResult from AuthResponse
  factory AuthResult.fromAuthResponse(dynamic authResponse) {
    // Handle AuthResponse object
    if (authResponse != null && authResponse.runtimeType.toString().contains('AuthResponse')) {
      final success = authResponse.success as bool? ?? false;
      final user = authResponse.user;
      final message = authResponse.message as String?;
      final errors = authResponse.errors as Map<String, List<String>>?;
      
      if (success) {
        return AuthResult.success(user: user);
      } else {
        return AuthResult.failure(
          error: message ?? 'Authentication failed',
          fieldErrors: errors,
        );
      }
    }
    
    // Handle direct JSON response
    if (authResponse is Map<String, dynamic>) {
      final success = authResponse['success'] == true || authResponse['token'] != null;
      final userData = authResponse['user'];
      final user = userData != null ? User.fromJson(userData) : null;
      final message = authResponse['message']?.toString();
      final errors = _parseFieldErrors(authResponse['errors']);
      
      if (success) {
        return AuthResult.success(user: user);
      } else {
        return AuthResult.failure(
          error: message ?? 'Authentication failed',
          fieldErrors: errors,
        );
      }
    }
    
    return AuthResult.failure(error: 'Invalid response format');
  }

  /// Parses field errors from various formats
  static Map<String, List<String>>? _parseFieldErrors(dynamic errorsData) {
    if (errorsData == null) return null;
    
    final Map<String, List<String>> parsedErrors = {};
    
    if (errorsData is Map<String, dynamic>) {
      errorsData.forEach((key, value) {
        if (value is List) {
          parsedErrors[key] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          parsedErrors[key] = [value];
        } else {
          parsedErrors[key] = [value.toString()];
        }
      });
    } else if (errorsData is List) {
      parsedErrors['general'] = errorsData.map((e) => e.toString()).toList();
    } else if (errorsData is String) {
      parsedErrors['general'] = [errorsData];
    }
    
    return parsedErrors.isEmpty ? null : parsedErrors;
  }

  /// Returns true if there are field-specific errors
  bool get hasFieldErrors => fieldErrors != null && fieldErrors!.isNotEmpty;

  /// Returns true if there is a general error message
  bool get hasError => error != null && error!.isNotEmpty;

  /// Returns true if there are any errors (general or field-specific)
  bool get hasAnyErrors => hasError || hasFieldErrors;

  /// Gets all error messages as a flat list
  List<String> get allErrorMessages {
    final List<String> allErrors = [];
    
    if (error != null) {
      allErrors.add(error!);
    }
    
    if (fieldErrors != null) {
      fieldErrors!.forEach((key, messages) {
        allErrors.addAll(messages);
      });
    }
    
    return allErrors;
  }

  /// Gets the first error message, prioritizing general error over field errors
  String? get firstErrorMessage {
    if (error != null) return error;
    
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final firstField = fieldErrors!.keys.first;
      final firstFieldErrors = fieldErrors![firstField]!;
      return firstFieldErrors.isNotEmpty ? firstFieldErrors.first : null;
    }
    
    return null;
  }

  /// Gets errors for a specific field
  List<String>? getFieldErrors(String fieldName) {
    return fieldErrors?[fieldName];
  }

  /// Gets the first error for a specific field
  String? getFirstFieldError(String fieldName) {
    final errors = getFieldErrors(fieldName);
    return errors != null && errors.isNotEmpty ? errors.first : null;
  }

  /// Converts AuthResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'user': user?.toJson(),
      'error': error,
      'fieldErrors': fieldErrors,
    };
  }

  /// Creates AuthResult from JSON
  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] == true,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      error: json['error']?.toString(),
      fieldErrors: _parseFieldErrors(json['fieldErrors']),
    );
  }

  /// Creates a copy of this AuthResult with updated fields
  AuthResult copyWith({
    bool? success,
    User? user,
    String? error,
    Map<String, List<String>>? fieldErrors,
  }) {
    return AuthResult(
      success: success ?? this.success,
      user: user ?? this.user,
      error: error ?? this.error,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResult &&
        other.success == success &&
        other.user == user &&
        other.error == error &&
        _mapEquals(other.fieldErrors, fieldErrors);
  }

  /// Helper method to compare maps with list values
  bool _mapEquals(Map<String, List<String>>? a, Map<String, List<String>>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final aList = a[key]!;
      final bList = b[key]!;
      if (aList.length != bList.length) return false;
      for (int i = 0; i < aList.length; i++) {
        if (aList[i] != bList[i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(success, user, error, fieldErrors);
  }

  @override
  String toString() {
    return 'AuthResult(success: $success, user: $user, error: $error, fieldErrors: $fieldErrors)';
  }
}