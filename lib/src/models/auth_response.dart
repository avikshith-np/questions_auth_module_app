/// Authentication response models
import 'user.dart';

/// Response model for API authentication responses
class AuthResponse {
  final String? token;
  final User? user;
  final bool success;
  final String? message;
  final Map<String, List<String>>? errors;

  const AuthResponse({
    this.token,
    this.user,
    required this.success,
    this.message,
    this.errors,
  });

  /// Creates AuthResponse from JSON data received from API
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      success: json['success'] == true || json['token'] != null,
      message: json['message']?.toString(),
      errors: _parseErrors(json['errors']),
    );
  }

  /// Parses error object from API response
  static Map<String, List<String>>? _parseErrors(dynamic errorsData) {
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

  /// Converts AuthResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
      'success': success,
      'message': message,
      'errors': errors,
    };
  }

  /// Creates a success response
  factory AuthResponse.success({
    String? token,
    User? user,
    String? message,
  }) {
    return AuthResponse(
      token: token,
      user: user,
      success: true,
      message: message,
    );
  }

  /// Creates an error response
  factory AuthResponse.error({
    String? message,
    Map<String, List<String>>? errors,
  }) {
    return AuthResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }

  /// Returns true if the response indicates a successful authentication
  bool get isSuccess => success && token != null;

  /// Returns true if the response has validation errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Gets all error messages as a flat list
  List<String> get allErrorMessages {
    if (errors == null) return [];
    
    final List<String> allErrors = [];
    errors!.forEach((key, messages) {
      allErrors.addAll(messages);
    });
    return allErrors;
  }

  /// Gets the first error message, if any
  String? get firstErrorMessage {
    if (message != null) return message;
    final allErrors = allErrorMessages;
    return allErrors.isNotEmpty ? allErrors.first : null;
  }

  /// Creates a copy of this AuthResponse with updated fields
  AuthResponse copyWith({
    String? token,
    User? user,
    bool? success,
    String? message,
    Map<String, List<String>>? errors,
  }) {
    return AuthResponse(
      token: token ?? this.token,
      user: user ?? this.user,
      success: success ?? this.success,
      message: message ?? this.message,
      errors: errors ?? this.errors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponse &&
        other.token == token &&
        other.user == user &&
        other.success == success &&
        other.message == message &&
        _mapEquals(other.errors, errors);
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
    return Object.hash(token, user, success, message, errors);
  }

  @override
  String toString() {
    return 'AuthResponse(token: ${token != null ? '[PRESENT]' : 'null'}, user: $user, success: $success, message: $message, errors: $errors)';
  }
}