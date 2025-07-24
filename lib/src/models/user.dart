/// User model for authentication package
class User {
  final String id;
  final String email;
  final String username;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a User instance from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Converts User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Validates user data
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) {
      errors.add('User ID cannot be empty');
    }

    if (email.isEmpty) {
      errors.add('Email cannot be empty');
    } else if (!_isValidEmail(email)) {
      errors.add('Invalid email format');
    }

    if (username.isEmpty) {
      errors.add('Username cannot be empty');
    } else if (username.length < 3) {
      errors.add('Username must be at least 3 characters long');
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
    String? id,
    String? email,
    String? username,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, username, createdAt, updatedAt);
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}