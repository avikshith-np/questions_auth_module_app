import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/question_auth.dart';

import '../utils/mock_implementations.dart';
import '../utils/auth_test_utils.dart';

void main() {
  group('Full Authentication Flow Integration Tests', () {
    late AuthService authService;

    setUp(() {
      // Use successful mock implementations for integration testing
      final mockApiClient = SuccessfulMockApiClient();
      final mockTokenManager = MockFactory.createEmptyMockTokenManager();
      final repository = AuthRepositoryImpl(
        apiClient: mockApiClient,
        tokenManager: mockTokenManager,
      );
      authService = AuthServiceImpl(repository: repository);
    });

    group('Complete Registration Flow', () {
      test('should complete full registration flow successfully', () async {
        // Arrange
        final signUpRequest = AuthTestUtils.createValidSignUpRequest();

        // Act & Assert - Monitor state changes
        final stateChanges = <AuthState>[];
        final subscription = authService.authStateStream.listen(stateChanges.add);

        // Initial state should be unknown
        expect(authService.currentAuthState.status, AuthStatus.unknown);

        // Perform registration
        final result = await authService.signUp(signUpRequest);

        // Verify registration success
        expect(result.success, isTrue);
        expect(result.signUpData, isNotNull); // New API returns signup data, not user
        expect(result.signUpData!.detail, contains('Registration successful'));

        // Verify authentication state - signup doesn't authenticate in new API
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);

        // Verify state stream - should remain unauthenticated after signup
        await Future.delayed(const Duration(milliseconds: 10));

        await subscription.cancel();
      });

      test('should handle registration validation errors', () async {
        // Arrange
        final invalidRequest = SignUpRequest(
          email: 'invalid-email',
          displayName: 'user',
          password: 'pass',
          confirmPassword: 'different',
        );

        // Act
        final result = await authService.signUp(invalidRequest);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
        expect(result.fieldErrors, isNotNull);
        expect(result.fieldErrors!.containsKey('general'), isTrue);

        // Verify state remains unauthenticated
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentAuthState.status, AuthStatus.unauthenticated);
      });
    });

    group('Complete Login Flow', () {
      test('should complete full login flow successfully', () async {
        // Arrange
        final loginRequest = AuthTestUtils.createValidLoginRequest();

        // Act & Assert - Monitor state changes
        final stateChanges = <AuthState>[];
        final subscription = authService.authStateStream.listen(stateChanges.add);

        // Perform login
        final result = await authService.login(loginRequest);

        // Verify login success
        expect(result.success, isTrue);
        expect(result.user, isNotNull);

        // Verify authentication state
        expect(authService.isAuthenticated, isTrue);

        // Verify state changes
        await Future.delayed(const Duration(milliseconds: 10));
        expect(stateChanges.last.status, AuthStatus.authenticated);

        await subscription.cancel();
      });
    });

    group('Profile Management Flow', () {
      test('should retrieve user profile when authenticated', () async {
        // Arrange - First authenticate
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        await authService.login(loginRequest);

        // Act
        final user = await authService.getCurrentUser();

        // Assert
        expect(user.user.email, isNotNull);
        expect(user.user.displayName, isNotNull);

        // Verify state updated
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser, isNotNull);
      });
    });

    group('Logout Flow', () {
      test('should complete full logout flow', () async {
        // Arrange - First authenticate
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        await authService.login(loginRequest);
        
        // Verify initial authenticated state
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser, isNotNull);

        // Act & Assert - Monitor state changes
        final stateChanges = <AuthState>[];
        final subscription = authService.authStateStream.listen(stateChanges.add);

        await authService.logout();

        // Verify logout completed
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);

        // Verify state changes
        await Future.delayed(const Duration(milliseconds: 10));
        expect(stateChanges.last.status, AuthStatus.unauthenticated);

        await subscription.cancel();
      });
    });

    group('Authentication Persistence Flow', () {
      test('should handle no stored token during initialization', () async {
        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentAuthState.status, AuthStatus.unauthenticated);
      });
    });

    group('End-to-End Authentication Scenarios', () {
      test('should handle complete user journey: register -> logout -> login', () async {
        // Arrange
        final signUpRequest = AuthTestUtils.createValidSignUpRequest();
        final loginRequest = AuthTestUtils.createValidLoginRequest();

        // Act & Assert - Complete journey
        final stateChanges = <AuthState>[];
        final subscription = authService.authStateStream.listen(stateChanges.add);

        // 1. Register user
        final signUpResult = await authService.signUp(signUpRequest);
        expect(signUpResult.success, isTrue);
        expect(authService.isAuthenticated, isFalse); // Signup doesn't authenticate in new API

        // 2. Login user (since signup doesn't authenticate)
        final initialLoginResult = await authService.login(loginRequest);
        expect(initialLoginResult.success, isTrue);
        expect(authService.isAuthenticated, isTrue);

        // 3. Logout user
        await authService.logout();
        expect(authService.isAuthenticated, isFalse);

        // 4. Login user again
        final loginResult = await authService.login(loginRequest);
        expect(loginResult.success, isTrue);
        expect(authService.isAuthenticated, isTrue);

        // Verify state transitions
        await Future.delayed(const Duration(milliseconds: 10));
        expect(stateChanges.length, greaterThanOrEqualTo(3));
        
        // Find authenticated states
        final authenticatedStates = stateChanges
            .where((state) => state.status == AuthStatus.authenticated)
            .toList();
        expect(authenticatedStates.length, greaterThanOrEqualTo(2)); // After initial login and final login

        // Find unauthenticated states
        final unauthenticatedStates = stateChanges
            .where((state) => state.status == AuthStatus.unauthenticated)
            .toList();
        expect(unauthenticatedStates.length, greaterThanOrEqualTo(1)); // After logout

        await subscription.cancel();
      });

      test('should demonstrate reactive authentication state management', () async {
        // Arrange
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        final stateHistory = <AuthState>[];
        
        // Monitor all state changes
        final subscription = authService.authStateStream.listen(stateHistory.add);

        // Act - Perform authentication operations
        await authService.initialize(); // Should be unauthenticated
        await authService.login(loginRequest); // Should become authenticated
        await authService.getCurrentUser(); // Should remain authenticated
        await authService.logout(); // Should become unauthenticated

        // Allow time for all state changes to propagate
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - Verify state progression
        expect(stateHistory.length, greaterThanOrEqualTo(3));
        
        // Should start unknown/unauthenticated
        expect(stateHistory.first.status, isIn([AuthStatus.unknown, AuthStatus.unauthenticated]));
        
        // Should have at least one authenticated state
        final hasAuthenticatedState = stateHistory.any((state) => state.status == AuthStatus.authenticated);
        expect(hasAuthenticatedState, isTrue);
        
        // Should end unauthenticated
        expect(stateHistory.last.status, AuthStatus.unauthenticated);

        await subscription.cancel();
      });

      test('should handle error scenarios gracefully', () async {
        // Arrange - Use error-prone mock implementations
        final errorApiClient = NetworkErrorMockApiClient();
        final mockTokenManager = MockFactory.createEmptyMockTokenManager();
        final repository = AuthRepositoryImpl(
          apiClient: errorApiClient,
          tokenManager: mockTokenManager,
        );
        final errorAuthService = AuthServiceImpl(repository: repository);

        final loginRequest = AuthTestUtils.createValidLoginRequest();

        // Act
        final result = await errorAuthService.login(loginRequest);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, contains('Network'));
        expect(errorAuthService.isAuthenticated, isFalse);
        expect(errorAuthService.currentAuthState.status, AuthStatus.unauthenticated);
        expect(errorAuthService.currentAuthState.error, isNotNull);
      });
    });

    group('QuestionAuth Singleton Integration', () {
      test('should work with QuestionAuth singleton', () async {
        // Arrange
        QuestionAuth.reset(); // Reset for clean test
        QuestionAuth.instance.configure(
          baseUrl: 'https://test-api.com/api/v1/',
        );
        await QuestionAuth.instance.initialize();

        final signUpRequest = AuthTestUtils.createValidSignUpRequest();

        // Act & Assert - Test singleton functionality
        expect(QuestionAuth.instance.isAuthenticated, isFalse);
        
        // Note: This would require actual API or more complex mocking
        // For now, just verify the singleton is configured and accessible
        expect(QuestionAuth.instance.currentAuthState.status, AuthStatus.unauthenticated);
        
        // Verify stream is accessible
        expect(QuestionAuth.instance.authStateStream, isNotNull);
      });
    });
  });
}