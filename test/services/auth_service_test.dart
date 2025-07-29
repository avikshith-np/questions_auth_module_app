import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/services/auth_service.dart';
import '../../lib/src/repositories/auth_repository.dart';
import '../../lib/src/core/auth_state.dart';
import '../../lib/src/models/auth_request.dart';
import '../../lib/src/models/auth_response.dart';
import '../../lib/src/models/user.dart';
import '../../lib/src/core/exceptions.dart';

// Simple mock repository for testing
class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResponse> signUp(SignUpRequest request) async {
    return AuthResponse(
      success: true,
      user: User(id: '1', email: request.email, username: request.username),
      token: 'test_token',
    );
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    return AuthResponse(
      success: true,
      user: User(id: '1', email: request.email, username: 'testuser'),
      token: 'test_token',
    );
  }

  @override
  Future<User> getCurrentUser() async {
    return User(id: '1', email: 'test@example.com', username: 'testuser');
  }

  @override
  Future<void> logout() async {
    // Mock logout
  }
  
  @override
  Future<bool> hasStoredToken() async {
    return true;
  }
  
  @override
  Future<bool> isTokenExpired() async {
    return false;
  }
  
  @override
  Future<void> clearExpiredToken() async {
    // Mock clear expired token
  }
}

void main() {
  group('AuthService Integration Tests', () {
    late AuthService authService;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      authService = AuthServiceImpl(repository: mockRepository);
    });

    test('should create AuthServiceImpl instance', () {
      expect(authService, isA<AuthServiceImpl>());
      expect(authService.isAuthenticated, false);
    });

    test('should handle successful signup', () async {
      final request = SignUpRequest(
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
        confirmPassword: 'password123',
      );

      final result = await authService.signUp(request);

      expect(result.success, true);
      expect(result.user?.email, 'test@example.com');
      expect(authService.isAuthenticated, true);
    });

    test('should handle successful login', () async {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final result = await authService.login(request);

      expect(result.success, true);
      expect(result.user?.email, 'test@example.com');
      expect(authService.isAuthenticated, true);
    });

    test('should handle logout', () async {
      // First login
      final loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );
      await authService.login(loginRequest);
      expect(authService.isAuthenticated, true);

      // Then logout
      await authService.logout();
      expect(authService.isAuthenticated, false);
      expect(authService.currentUser, null);
    });

    test('should initialize with existing user', () async {
      await authService.initialize();
      expect(authService.isAuthenticated, true);
      expect(authService.currentUser?.email, 'test@example.com');
    });
  });
}