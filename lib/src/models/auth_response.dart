library;

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

/// Response model for signup data
class SignUpData {
  final String email;
  final String verificationTokenExpiresIn;

  const SignUpData({
    required this.email,
    required this.verificationTokenExpiresIn,
  });

  /// Creates SignUpData from JSON data
  factory SignUpData.fromJson(Map<String, dynamic> json) {
    return SignUpData(
      email: json['email']?.toString() ?? '',
      verificationTokenExpiresIn: json['verification_token_expires_in']?.toString() ?? '',
    );
  }

  /// Converts SignUpData to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'verification_token_expires_in': verificationTokenExpiresIn,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignUpData &&
        other.email == email &&
        other.verificationTokenExpiresIn == verificationTokenExpiresIn;
  }

  @override
  int get hashCode {
    return Object.hash(email, verificationTokenExpiresIn);
  }

  @override
  String toString() {
    return 'SignUpData(email: $email, verificationTokenExpiresIn: $verificationTokenExpiresIn)';
  }
}

/// Response model for signup endpoint
class SignUpResponse {
  final String detail;
  final SignUpData? data;

  const SignUpResponse({
    required this.detail,
    this.data,
  });

  /// Creates SignUpResponse from JSON data
  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      detail: json['detail']?.toString() ?? '',
      data: json['data'] != null 
          ? SignUpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts SignUpResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'detail': detail,
      if (data != null) 'data': data!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignUpResponse &&
        other.detail == detail &&
        other.data == data;
  }

  @override
  int get hashCode {
    return Object.hash(detail, data);
  }

  @override
  String toString() {
    return 'SignUpResponse(detail: $detail, data: $data)';
  }
}

/// Response model for login endpoint
class LoginResponse {
  final String token;
  final User user;
  final List<String> roles;
  final Map<String, bool> profileComplete;
  final bool onboardingComplete;
  final List<String> incompleteRoles;
  final String appAccess;
  final String redirectTo;

  const LoginResponse({
    required this.token,
    required this.user,
    required this.roles,
    required this.profileComplete,
    required this.onboardingComplete,
    required this.incompleteRoles,
    required this.appAccess,
    required this.redirectTo,
  });

  /// Creates LoginResponse from JSON data
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token']?.toString() ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      roles: List<String>.from(json['roles'] as List? ?? []),
      profileComplete: Map<String, bool>.from(json['profile_complete'] as Map? ?? {}),
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      incompleteRoles: List<String>.from(json['incomplete_roles'] as List? ?? []),
      appAccess: json['app_access']?.toString() ?? '',
      redirectTo: json['redirect_to']?.toString() ?? '',
    );
  }

  /// Converts LoginResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'roles': roles,
      'profile_complete': profileComplete,
      'onboarding_complete': onboardingComplete,
      'incomplete_roles': incompleteRoles,
      'app_access': appAccess,
      'redirect_to': redirectTo,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponse &&
        other.token == token &&
        other.user == user &&
        _listEquals(other.roles, roles) &&
        _mapEquals(other.profileComplete, profileComplete) &&
        other.onboardingComplete == onboardingComplete &&
        _listEquals(other.incompleteRoles, incompleteRoles) &&
        other.appAccess == appAccess &&
        other.redirectTo == redirectTo;
  }

  @override
  int get hashCode {
    return Object.hash(
      token,
      user,
      Object.hashAll(roles),
      Object.hashAll(profileComplete.entries.map((e) => Object.hash(e.key, e.value))),
      onboardingComplete,
      Object.hashAll(incompleteRoles),
      appAccess,
      redirectTo,
    );
  }

  @override
  String toString() {
    return 'LoginResponse(token: [PRESENT], user: $user, roles: $roles, profileComplete: $profileComplete, onboardingComplete: $onboardingComplete, incompleteRoles: $incompleteRoles, appAccess: $appAccess, redirectTo: $redirectTo)';
  }

  /// Helper method to compare lists
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Helper method to compare maps
  bool _mapEquals(Map<String, bool> a, Map<String, bool> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Response model for user profile endpoint
class UserProfileResponse {
  final User user;
  final bool isNew;
  final String mode;
  final List<String> roles;
  final List<String> availableRoles;
  final List<String> removableRoles;
  final Map<String, bool> profileComplete;
  final bool onboardingComplete;
  final List<String> incompleteRoles;
  final String appAccess;
  final String viewType;
  final String redirectTo;

  const UserProfileResponse({
    required this.user,
    required this.isNew,
    required this.mode,
    required this.roles,
    required this.availableRoles,
    required this.removableRoles,
    required this.profileComplete,
    required this.onboardingComplete,
    required this.incompleteRoles,
    required this.appAccess,
    required this.viewType,
    required this.redirectTo,
  });

  /// Creates UserProfileResponse from JSON data
  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      isNew: json['is_new'] as bool? ?? false,
      mode: json['mode']?.toString() ?? '',
      roles: List<String>.from(json['roles'] as List? ?? []),
      availableRoles: List<String>.from(json['available_roles'] as List? ?? []),
      removableRoles: List<String>.from(json['removable_roles'] as List? ?? []),
      profileComplete: Map<String, bool>.from(json['profile_complete'] as Map? ?? {}),
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      incompleteRoles: List<String>.from(json['incomplete_roles'] as List? ?? []),
      appAccess: json['app_access']?.toString() ?? '',
      viewType: json['viewType']?.toString() ?? '',
      redirectTo: json['redirect_to']?.toString() ?? '',
    );
  }

  /// Converts UserProfileResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'is_new': isNew,
      'mode': mode,
      'roles': roles,
      'available_roles': availableRoles,
      'removable_roles': removableRoles,
      'profile_complete': profileComplete,
      'onboarding_complete': onboardingComplete,
      'incomplete_roles': incompleteRoles,
      'app_access': appAccess,
      'viewType': viewType,
      'redirect_to': redirectTo,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileResponse &&
        other.user == user &&
        other.isNew == isNew &&
        other.mode == mode &&
        _listEquals(other.roles, roles) &&
        _listEquals(other.availableRoles, availableRoles) &&
        _listEquals(other.removableRoles, removableRoles) &&
        _mapEquals(other.profileComplete, profileComplete) &&
        other.onboardingComplete == onboardingComplete &&
        _listEquals(other.incompleteRoles, incompleteRoles) &&
        other.appAccess == appAccess &&
        other.viewType == viewType &&
        other.redirectTo == redirectTo;
  }

  @override
  int get hashCode {
    return Object.hash(
      user,
      isNew,
      mode,
      Object.hashAll(roles),
      Object.hashAll(availableRoles),
      Object.hashAll(removableRoles),
      Object.hashAll(profileComplete.entries.map((e) => Object.hash(e.key, e.value))),
      onboardingComplete,
      Object.hashAll(incompleteRoles),
      appAccess,
      viewType,
      redirectTo,
    );
  }

  @override
  String toString() {
    return 'UserProfileResponse(user: $user, isNew: $isNew, mode: $mode, roles: $roles, availableRoles: $availableRoles, removableRoles: $removableRoles, profileComplete: $profileComplete, onboardingComplete: $onboardingComplete, incompleteRoles: $incompleteRoles, appAccess: $appAccess, viewType: $viewType, redirectTo: $redirectTo)';
  }

  /// Helper method to compare lists
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Helper method to compare maps
  bool _mapEquals(Map<String, bool> a, Map<String, bool> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Response model for logout endpoint
class LogoutResponse {
  final String detail;

  const LogoutResponse({required this.detail});

  /// Creates LogoutResponse from JSON data
  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(detail: json['detail']?.toString() ?? '');
  }

  /// Converts LogoutResponse to JSON
  Map<String, dynamic> toJson() {
    return {'detail': detail};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogoutResponse && other.detail == detail;
  }

  @override
  int get hashCode {
    return detail.hashCode;
  }

  @override
  String toString() {
    return 'LogoutResponse(detail: $detail)';
  }
}