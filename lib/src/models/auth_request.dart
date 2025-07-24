/// Authentication request models

/// Request model for user signup
class SignUpRequest {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;

  const SignUpRequest({
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
  });

  /// Converts SignUpRequest to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'confirm_password': confirmPassword,
    };
  }

  /// Validates the signup request data
  List<String> validate() {
    final errors = <String>[];

    // Email validation
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!_isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    // Username validation
    if (username.isEmpty) {
      errors.add('Username is required');
    } else if (username.length < 3) {
      errors.add('Username must be at least 3 characters long');
    } else if (username.length > 30) {
      errors.add('Username must be less than 30 characters');
    } else if (!_isValidUsername(username)) {
      errors.add('Username can only contain letters, numbers, and underscores');
    }

    // Password validation
    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (password.length < 8) {
      errors.add('Password must be at least 8 characters long');
    }

    // Confirm password validation
    if (confirmPassword.isEmpty) {
      errors.add('Please confirm your password');
    } else if (password != confirmPassword) {
      errors.add('Passwords do not match');
    }

    return errors;
  }

  /// Validates email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates username format
  bool _isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(username);
  }

  /// Creates a copy of this SignUpRequest with updated fields
  SignUpRequest copyWith({
    String? email,
    String? username,
    String? password,
    String? confirmPassword,
  }) {
    return SignUpRequest(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignUpRequest &&
        other.email == email &&
        other.username == username &&
        other.password == password &&
        other.confirmPassword == confirmPassword;
  }

  @override
  int get hashCode {
    return Object.hash(email, username, password, confirmPassword);
  }

  @override
  String toString() {
    return 'SignUpRequest(email: $email, username: $username, password: [HIDDEN], confirmPassword: [HIDDEN])';
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

  /// Validates the login request data
  List<String> validate() {
    final errors = <String>[];

    // Email validation
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!_isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    // Password validation
    if (password.isEmpty) {
      errors.add('Password is required');
    }

    return errors;
  }

  /// Validates email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
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