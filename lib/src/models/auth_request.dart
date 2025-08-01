library;

/// Authentication request models

/// Request model for user signup
class SignUpRequest {
  final String email;
  final String displayName;
  final String password;
  final String confirmPassword;

  const SignUpRequest({
    required this.email,
    required this.displayName,
    required this.password,
    required this.confirmPassword,
  });

  /// Converts SignUpRequest to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'display_name': displayName,
      'password': password,
      'confirm_password': confirmPassword,
    };
  }

  /// Validates the signup request data and returns general errors
  List<String> validate() {
    final fieldErrors = validateFields();
    final errors = <String>[];
    
    for (final fieldErrorList in fieldErrors.values) {
      errors.addAll(fieldErrorList);
    }
    
    return errors;
  }

  /// Validates the signup request data and returns field-specific errors
  Map<String, List<String>> validateFields() {
    final fieldErrors = <String, List<String>>{};

    // Email validation
    final emailErrors = <String>[];
    if (email.isEmpty) {
      emailErrors.add('Email is required');
    } else if (!_isValidEmail(email)) {
      emailErrors.add('Please enter a valid email address');
    }
    if (emailErrors.isNotEmpty) {
      fieldErrors['email'] = emailErrors;
    }

    // Display name validation
    final displayNameErrors = <String>[];
    if (displayName.isEmpty) {
      displayNameErrors.add('Display name is required');
    } else if (displayName.length < 2) {
      displayNameErrors.add('Display name must be at least 2 characters long');
    } else if (displayName.length > 50) {
      displayNameErrors.add('Display name must be less than 50 characters');
    }
    if (displayNameErrors.isNotEmpty) {
      fieldErrors['displayName'] = displayNameErrors;
    }

    // Password validation
    final passwordErrors = <String>[];
    if (password.isEmpty) {
      passwordErrors.add('Password is required');
    } else {
      if (password.length < 8) {
        passwordErrors.add('Password must be at least 8 characters long');
      }
      if (password.length > 128) {
        passwordErrors.add('Password must be less than 128 characters');
      }
      if (!_hasValidPasswordStrength(password)) {
        passwordErrors.add('Password must contain at least one letter and one number');
      }
    }
    if (passwordErrors.isNotEmpty) {
      fieldErrors['password'] = passwordErrors;
    }

    // Confirm password validation
    final confirmPasswordErrors = <String>[];
    if (confirmPassword.isEmpty) {
      confirmPasswordErrors.add('Please confirm your password');
    } else if (password != confirmPassword) {
      confirmPasswordErrors.add('Passwords do not match');
    }
    if (confirmPasswordErrors.isNotEmpty) {
      fieldErrors['confirmPassword'] = confirmPasswordErrors;
    }

    return fieldErrors;
  }

  /// Returns true if the signup request is valid
  bool get isValid => validateFields().isEmpty;

  /// Validates email format using a comprehensive regex pattern
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }



  /// Validates password strength (at least one letter and one number)
  bool _hasValidPasswordStrength(String password) {
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    return hasLetter && hasNumber;
  }

  /// Creates a copy of this SignUpRequest with updated fields
  SignUpRequest copyWith({
    String? email,
    String? displayName,
    String? password,
    String? confirmPassword,
  }) {
    return SignUpRequest(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignUpRequest &&
        other.email == email &&
        other.displayName == displayName &&
        other.password == password &&
        other.confirmPassword == confirmPassword;
  }

  @override
  int get hashCode {
    return Object.hash(email, displayName, password, confirmPassword);
  }

  @override
  String toString() {
    return 'SignUpRequest(email: $email, displayName: $displayName, password: [HIDDEN], confirmPassword: [HIDDEN])';
  }
}

/// Request model for user login
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// Converts LoginRequest to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  /// Validates the login request data and returns general errors
  List<String> validate() {
    final fieldErrors = validateFields();
    final errors = <String>[];
    
    for (final fieldErrorList in fieldErrors.values) {
      errors.addAll(fieldErrorList);
    }
    
    return errors;
  }

  /// Validates the login request data and returns field-specific errors
  Map<String, List<String>> validateFields() {
    final fieldErrors = <String, List<String>>{};

    // Email validation
    final emailErrors = <String>[];
    if (email.isEmpty) {
      emailErrors.add('Email is required');
    } else if (!_isValidEmail(email)) {
      emailErrors.add('Please enter a valid email address');
    }
    if (emailErrors.isNotEmpty) {
      fieldErrors['email'] = emailErrors;
    }

    // Password validation
    final passwordErrors = <String>[];
    if (password.isEmpty) {
      passwordErrors.add('Password is required');
    }
    if (passwordErrors.isNotEmpty) {
      fieldErrors['password'] = passwordErrors;
    }

    return fieldErrors;
  }

  /// Returns true if the login request is valid
  bool get isValid => validateFields().isEmpty;

  /// Validates email format using a comprehensive regex pattern
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Creates a copy of this LoginRequest with updated fields
  LoginRequest copyWith({
    String? email,
    String? password,
  }) {
    return LoginRequest(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequest &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode {
    return Object.hash(email, password);
  }

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: [HIDDEN])';
  }
}