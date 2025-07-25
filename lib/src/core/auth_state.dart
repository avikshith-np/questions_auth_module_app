import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Authentication status enumeration
enum AuthStatus {
  /// Authentication status is unknown (initial state)
  unknown,
  
  /// User is authenticated
  authenticated,
  
  /// User is not authenticated
  unauthenticated,
}

/// Represents the current authentication state
class AuthState {
  /// The current authentication status
  final AuthStatus status;
  
  /// The authenticated user (null if not authenticated)
  final User? user;
  
  /// Error message if authentication failed
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  /// Creates an unknown authentication state
  const AuthState.unknown() : this(status: AuthStatus.unknown);

  /// Creates an authenticated state with user
  const AuthState.authenticated(User user) : this(
    status: AuthStatus.authenticated,
    user: user,
  );

  /// Creates an unauthenticated state with optional error
  const AuthState.unauthenticated([String? error]) : this(
    status: AuthStatus.unauthenticated,
    error: error,
  );

  /// Creates a copy of this AuthState with updated fields
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Whether the user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Whether the user is unauthenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Whether the authentication status is unknown
  bool get isUnknown => status == AuthStatus.unknown;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(status, user, error);

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, error: $error)';
  }
}

/// Notifier for authentication state changes
class AuthStateNotifier extends ValueNotifier<AuthState> {
  late final StreamController<AuthState> _streamController;
  
  /// Creates an AuthStateNotifier with unknown initial state
  AuthStateNotifier() : super(const AuthState.unknown()) {
    _streamController = StreamController<AuthState>.broadcast();
    // Add initial state to stream
    _streamController.add(value);
    // Listen to value changes and add to stream
    addListener(() {
      _streamController.add(value);
    });
  }
  
  /// Stream of authentication state changes
  Stream<AuthState> get stream => _streamController.stream;

  /// Sets the authentication state to authenticated with user
  void setAuthenticated(User user) {
    value = AuthState.authenticated(user);
  }

  /// Sets the authentication state to unauthenticated with optional error
  void setUnauthenticated([String? error]) {
    value = AuthState.unauthenticated(error);
  }

  /// Sets the authentication state to unknown
  void setUnknown() {
    value = const AuthState.unknown();
  }

  /// Clears any error in the current state
  void clearError() {
    if (value.error != null) {
      value = value.copyWith(clearError: true);
    }
  }

  /// Whether the user is currently authenticated
  bool get isAuthenticated => value.isAuthenticated;

  /// Whether the user is currently unauthenticated
  bool get isUnauthenticated => value.isUnauthenticated;

  /// Whether the authentication status is unknown
  bool get isUnknown => value.isUnknown;

  /// The current authenticated user (null if not authenticated)
  User? get currentUser => value.user;

  /// The current error message (null if no error)
  String? get currentError => value.error;
  
  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}