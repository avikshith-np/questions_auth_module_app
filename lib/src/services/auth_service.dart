import 'dart:async';

import '../models/auth_request.dart';
import '../models/auth_result.dart';
import '../models/user.dart';
import '../core/auth_state.dart';
import '../repositories/auth_repository.dart';
import '../core/exceptions.dart';

abstract class AuthService {
  Future<AuthResult> signUp(SignUpRequest request);
  Future<AuthResult> login(LoginRequest request);
  Future<User> getCurrentUser();
  Future<void> logout();
  Stream<AuthState> get authStateStream;
  bool get isAuthenticated;
  User? get currentUser;
  AuthState get currentAuthState;
  Future<void> initialize();
}

class AuthServiceImpl implements AuthService {
  final AuthRepository _repository;
  final AuthStateNotifier _stateNotifier;
  
  AuthServiceImpl({
    required AuthRepository repository,
    AuthStateNotifier? stateNotifier,
  }) : _repository = repository,
       _stateNotifier = stateNotifier ?? AuthStateNotifier();

  @override
  Stream<AuthState> get authStateStream => _stateNotifier.stream;

  @override
  bool get isAuthenticated => _stateNotifier.isAuthenticated;

  @override
  User? get currentUser => _stateNotifier.currentUser;

  @override
  AuthState get currentAuthState => _stateNotifier.value;

  @override
  Future<void> initialize() async {
    try {
      // Check if we have a stored token
      final hasToken = await _repository.hasStoredToken();
      if (!hasToken) {
        _stateNotifier.setUnauthenticated();
        return;
      }
      
      // Check if token is expired
      final isExpired = await _repository.isTokenExpired();
      if (isExpired) {
        // Clear expired token and set unauthenticated
        await _repository.clearExpiredToken();
        _stateNotifier.setUnauthenticated('Session expired');
        return;
      }
      
      // Try to get current user with stored token
      final user = await _repository.getCurrentUser();
      _stateNotifier.setAuthenticated(user);
    } on TokenException catch (e) {
      // Token is invalid or expired, clear it
      await _repository.clearExpiredToken();
      _stateNotifier.setUnauthenticated(e.message);
    } on ApiException catch (e) {
      // API error (e.g., 401 Unauthorized), likely expired token
      if (e.statusCode == 401) {
        await _repository.clearExpiredToken();
        _stateNotifier.setUnauthenticated('Session expired');
      } else {
        _stateNotifier.setUnauthenticated(e.message);
      }
    } on NetworkException {
      // Network error during initialization - keep unknown state
      // Don't clear token as it might be valid, just network issue
      _stateNotifier.setUnknown();
    } catch (e) {
      // Unexpected error - set to unauthenticated for security
      _stateNotifier.setUnauthenticated('Authentication initialization failed');
    }
  }

  @override
  Future<AuthResult> signUp(SignUpRequest request) async {
    try {
      _stateNotifier.clearError();
      final authResponse = await _repository.signUp(request);
      
      if (authResponse.success && authResponse.user != null) {
        _stateNotifier.setAuthenticated(authResponse.user!);
        return AuthResult.success(user: authResponse.user);
      } else {
        final errorMessage = authResponse.message ?? 'Signup failed';
        _stateNotifier.setUnauthenticated(errorMessage);
        return AuthResult.failure(
          error: errorMessage,
          fieldErrors: authResponse.errors,
        );
      }
    } on ValidationException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
    } on ApiException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(error: e.message);
    } on NetworkException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(error: e.message);
    } catch (e) {
      const errorMessage = 'An unexpected error occurred during signup';
      _stateNotifier.setUnauthenticated(errorMessage);
      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  Future<AuthResult> login(LoginRequest request) async {
    try {
      _stateNotifier.clearError();
      final authResponse = await _repository.login(request);
      
      if (authResponse.success && authResponse.user != null) {
        _stateNotifier.setAuthenticated(authResponse.user!);
        return AuthResult.success(user: authResponse.user);
      } else {
        final errorMessage = authResponse.message ?? 'Login failed';
        _stateNotifier.setUnauthenticated(errorMessage);
        return AuthResult.failure(
          error: errorMessage,
          fieldErrors: authResponse.errors,
        );
      }
    } on ValidationException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
    } on ApiException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(error: e.message);
    } on NetworkException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(error: e.message);
    } catch (e) {
      const errorMessage = 'An unexpected error occurred during login';
      _stateNotifier.setUnauthenticated(errorMessage);
      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      _stateNotifier.setAuthenticated(user);
      return user;
    } on TokenException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      rethrow;
    } on ApiException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      rethrow;
    } on NetworkException catch (e) {
      rethrow;
    } catch (e) {
      _stateNotifier.setUnauthenticated('Failed to get user profile');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (e) {
      // Even if repository logout fails, we still want to clear local state
    } finally {
      _stateNotifier.setUnauthenticated();
    }
  }
}