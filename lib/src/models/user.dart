/// User model for authentication package
class User {
  final String email;
  final String displayName;
  final bool isActive;
  final bool emailVerified;
  final bool isVerified;
  final bool isNew;
  final DateTime? dateJoined;

  const User({
    required this.email,
    required this.displayName,
    this.isActive = true,
    this.emailVerified = false,
    this.isVerified = false,
    this.isNew = false,
    this.dateJoined,
  });

  /// Creates a User instance from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      emailVerified: json['email_verified'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      dateJoined: json['date_joined'] != null 
          ? DateTime.tryParse(json['date_joined'].toString())
          : null,
    );
  }

  /// Converts User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'display_name': displayName,
      'is_active': isActive,
      'email_verified': emailVerified,
      'is_verified': isVerified,
      'is_new': isNew,
      if (dateJoined != null) 'date_joined': dateJoined!.toIso8601String(),
    };
  }

  /// Validates user data
  List<String> validate() {
    final errors = <String>[];

    if (email.isEmpty) {
      errors.add('Email cannot be empty');
    } else if (!_isValidEmail(email)) {
      errors.add('Invalid email format');
    }

    if (displayName.isEmpty) {
      errors.add('Display name cannot be empty');
    } else if (displayName.length < 2) {
      errors.add('Display name must be at least 2 characters long');
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

  /// Creates a copy of this User with updated fields
  User copyWith({
    String? email,
    String? displayName,
    bool? isActive,
    bool? emailVerified,
    bool? isVerified,
    bool? isNew,
    DateTime? dateJoined,
  }) {
    return User(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      isVerified: isVerified ?? this.isVerified,
      isNew: isNew ?? this.isNew,
      dateJoined: dateJoined ?? this.dateJoined,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.email == email &&
        other.displayName == displayName &&
        other.isActive == isActive &&
        other.emailVerified == emailVerified &&
        other.isVerified == isVerified &&
        other.isNew == isNew &&
        other.dateJoined == dateJoined;
  }

  @override
  int get hashCode {
    return Object.hash(email, displayName, isActive, emailVerified, isVerified, isNew, dateJoined);
  }

  @override
  String toString() {
    return 'User(email: $email, displayName: $displayName, isActive: $isActive, emailVerified: $emailVerified, isVerified: $isVerified, isNew: $isNew, dateJoined: $dateJoined)';
  }
}