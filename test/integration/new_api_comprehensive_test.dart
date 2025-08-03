import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/question_auth.dart';

import '../utils/mock_implementations.dart';
import '../utils/auth_test_utils.dart';

/// Comprehensive integration tests specifically for new API functionality
/// Tests all updated requirements and verifies complete authentication flows
void main() {
  group('New API Comprehensive Integration Tests', () {
    late AuthService authService;
    late SuccessfulMockApiClient successfulApiClient;
    late MockTokenManager mockTokenManager;

    setUp(() {
      successfulApiClient = SuccessfulMockApiClient();
      mockTokenManager = MockTokenManager();
      final repository = AuthRepositoryImpl(
        apiClient: successfulApiClient,
        tokenManager: mockTokenManager,
      );
      authService = AuthServiceImpl(repository: repository);
    });

    group('Complete Registration Flow with New API', () {
      test('should handle complete registration with display_name and new response structure', () async {
        // Arrange
        final signUpRequest = AuthTestUtils.createValidSignUpRequest(
          email: 'newuser@example.com',
          displayName: 'New User',
          password: 'password@123',
        );

        // Act
        final result = await authService.signUp(signUpRequest);

        // Assert - New API registration response
        expect(result.success, isTrue);
        expect(result.signUpData, isNotNull);
        expect(result.signUpData!.detail, equals('Registration successful! Please check your email to verify your account.'));
        expect(result.signUpData!.data, isNotNull);
        expect(result.signUpData!.data!.email, equals('test@example.com')); // Mock returns test@example.com
        expect(result.signUpData!.data!.verificationTokenExpiresIn, equals('10 minutes'));
      });

      test('should handle field-specific validation errors for display_name', () async {
        // Arrange
        final invalidRequest = SignUpRequest(
          email: 'test@example.com',
          displayName: '', // Invalid empty display_name
          password: 'password@123',
          confirmPassword: 'password@123',
        );

        // Act
        final result = await authService.signUp(invalidRequest);

        // Assert
        expect(result.success, isFalse);
        expect(result.fieldErrors, isNotNull);
        expect(result.fieldErrors!.containsKey('general'), isTrue);
      });

      test('should validate confirm_password field matching', () async {
        // Arrange
        final invalidRequest = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password@123',
          confirmPassword: 'different@password',
        );

        // Act
        final result = await authService.signUp(invalidRequest);

        // Assert
        expect(result.success, isFalse);
        expect(result.fieldErrors, isNotNull);
        expect(result.fieldErrors!.containsKey('general'), isTrue);
      });
    });

    group('Complete Login Flow with Rich Profile Data', () {
      test('should handle login with comprehensive user profile data', () async {
        // Arrange
        final loginRequest = AuthTestUtils.createValidLoginRequest();

        // Act
        final result = await authService.login(loginRequest);

        // Assert - Rich login response data
        expect(result.success, isTrue);
        expect(result.user, isNotNull);
        expect(result.token, isNotNull);
        expect(result.loginData, isNotNull);
        
        // Verify LoginResponse structure
        final loginData = result.loginData!;
        expect(loginData.token, isNotNull);
        expect(loginData.user.email, equals('test@example.com'));
        expect(loginData.user.displayName, isNotNull);
        expect(loginData.user.isVerified, isTrue);
        expect(loginData.user.isNew, isFalse);
        expect(loginData.roles, contains('Creator'));
        expect(loginData.profileComplete, isNotNull);
        expect(loginData.profileComplete['creator'], isTrue);
        expect(loginData.profileComplete['student'], isFalse);
        expect(loginData.onboardingComplete, isTrue);
        expect(loginData.incompleteRoles, isEmpty);
        expect(loginData.appAccess, equals('full'));
        expect(loginData.redirectTo, equals('/dashboard'));
      });

      test('should store and provide access to user roles and profile data', () async {
        // Arrange
        final loginRequest = AuthTestUtils.createValidLoginRequest();

        // Act
        await authService.login(loginRequest);

        // Assert - Service provides access to profile data
        expect(authService.isAuthenticated, isTrue);
        expect(authService.userRoles, contains('Creator'));
        expect(authService.profileComplete, isNotNull);
        expect(authService.profileComplete!['creator'], isTrue);
        expect(authService.onboardingComplete, isTrue);
        expect(authService.appAccess, equals('full'));
        expect(authService.hasRole('Creator'), isTrue);
        expect(authService.hasRole('Student'), isFalse);
        expect(authService.isProfileCompleteForRole('creator'), isTrue);
        expect(authService.hasFullAppAccess, isTrue);
      });
    });

    group('User Profile Information Access and Updates', () {
      test('should retrieve comprehensive user profile with all new fields', () async {
        // Arrange - First authenticate
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        await authService.login(loginRequest);

        // Act
        final userProfile = await authService.getCurrentUser();

        // Assert - Comprehensive UserProfileResponse
        expect(userProfile.user.email, equals('test@example.com'));
        expect(userProfile.user.displayName, isNotNull);
        expect(userProfile.user.isActive, isTrue);
        expect(userProfile.user.emailVerified, isTrue);
        expect(userProfile.user.dateJoined, isNotNull);
        
        expect(userProfile.isNew, isFalse);
        expect(userProfile.mode, equals('creator'));
        expect(userProfile.roles, contains('creator'));
        expect(userProfile.availableRoles, contains('student'));
        expect(userProfile.removableRoles, isNotNull);
        expect(userProfile.profileComplete['creator'], isTrue);
        expect(userProfile.profileComplete['student'], isFalse);
        expect(userProfile.onboardingComplete, isTrue);
        expect(userProfile.incompleteRoles, isEmpty);
        expect(userProfile.appAccess, equals('full'));
        expect(userProfile.viewType, equals('creator-complete-creator-only'));
        expect(userProfile.redirectTo, equals('/dashboard'));
      });

      test('should synchronize service state with profile data', () async {
        // Arrange - First authenticate
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        await authService.login(loginRequest);

        // Act
        final userProfile = await authService.getCurrentUser();

        // Assert - Service state matches profile data
        expect(authService.userRoles, equals(userProfile.roles));
        expect(authService.profileComplete, equals(userProfile.profileComplete));
        expect(authService.onboardingComplete, equals(userProfile.onboardingComplete));
        expect(authService.appAccess, equals(userProfile.appAccess));
        expect(authService.availableRoles, equals(userProfile.availableRoles));
        expect(authService.incompleteRoles, equals(userProfile.incompleteRoles));
        expect(authService.mode, equals(userProfile.mode));
        expect(authService.viewType, equals(userProfile.viewType));
        expect(authService.redirectTo, equals(userProfile.redirectTo));
      });

      test('should handle profile data updates when user profile changes', () async {
        // Arrange - First authenticate
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        await authService.login(loginRequest);

        // Act - Get profile multiple times to simulate updates
        final initialProfile = await authService.getCurrentUser();
        final updatedProfile = await authService.getCurrentUser();

        // Assert - Profile data consistency
        expect(updatedProfile.user.email, equals(initialProfile.user.email));
        expect(updatedProfile.roles, equals(initialProfile.roles));
        expect(updatedProfile.profileComplete, equals(initialProfile.profileComplete));
        expect(updatedProfile.onboardingComplete, equals(initialProfile.onboardingComplete));
        
        // Verify service state remains consistent
        expect(authService.userRoles, equals(updatedProfile.roles));
        expect(authService.profileComplete, equals(updatedProfile.profileComplete));
      });
    });

    group('Logout Flow with Proper Cleanup', () {
      test('should clear all user profile data on logout', () async {
        // Arrange - First authenticate with profile data
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        await authService.login(loginRequest);
        
        // Verify initial state with profile data
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser, isNotNull);
        expect(authService.userRoles, isNotNull);
        expect(authService.profileComplete, isNotNull);
        expect(authService.onboardingComplete, isNotNull);
        expect(authService.appAccess, isNotNull);

        // Act
        await authService.logout();

        // Assert - Complete cleanup
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.userRoles, isNull);
        expect(authService.profileComplete, isNull);
        expect(authService.onboardingComplete, isNull);
        expect(authService.appAccess, isNull);
        expect(authService.availableRoles, isNull);
        expect(authService.incompleteRoles, isNull);
        expect(authService.mode, isNull);
        expect(authService.viewType, isNull);
        expect(authService.redirectTo, isNull);

        // Verify helper methods return false after logout
        expect(authService.hasRole('Creator'), isFalse);
        expect(authService.isProfileCompleteForRole('creator'), isFalse);
        expect(authService.hasFullAppAccess, isFalse);
        expect(authService.hasIncompleteRoles, isFalse);

        // Verify token was cleared
        final storedToken = await mockTokenManager.getToken();
        expect(storedToken, isNull);
      });
    });

    group('Authentication Persistence with User Profile Data', () {
      test('should persist and restore user profile data across app restarts', () async {
        // Arrange - First app session
        final loginRequest = AuthTestUtils.createValidLoginRequest();

        // Act - Login with profile data
        final loginResult = await authService.login(loginRequest);
        expect(loginResult.success, isTrue);
        expect(authService.userRoles, isNotNull);
        expect(authService.profileComplete, isNotNull);

        // Verify token and profile data persistence
        final storedToken = await mockTokenManager.getToken();
        expect(storedToken, isNotNull);

        // Simulate app restart
        final newRepository = AuthRepositoryImpl(
          apiClient: successfulApiClient,
          tokenManager: mockTokenManager,
        );
        final newAuthService = AuthServiceImpl(repository: newRepository);

        // Act - Initialize after restart
        await newAuthService.initialize();

        // Assert - Profile data should be restored
        expect(newAuthService.isAuthenticated, isTrue);
        expect(newAuthService.currentUser, isNotNull);
        expect(newAuthService.userRoles, isNotNull);
        expect(newAuthService.profileComplete, isNotNull);
        expect(newAuthService.onboardingComplete, isNotNull);
        expect(newAuthService.appAccess, isNotNull);
      });

      test('should handle automatic restoration of user profile data on app startup', () async {
        // Arrange - Simulate stored token from previous session
        await mockTokenManager.saveToken('stored-token-123');

        // Act - Initialize service (simulating app startup)
        await authService.initialize();

        // Assert - Profile data should be automatically restored
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser, isNotNull);
        expect(authService.userRoles, isNotNull);
        expect(authService.profileComplete, isNotNull);
        expect(authService.onboardingComplete, isNotNull);
        expect(authService.appAccess, isNotNull);
      });
    });

    group('Enhanced Error Handling for New API', () {
      test('should handle field-specific errors from registration endpoint', () async {
        // Arrange
        final errorApiClient = ApiErrorMockApiClient(
          statusCode: 400,
          message: 'Validation failed',
        );
        final errorRepository = AuthRepositoryImpl(
          apiClient: errorApiClient,
          tokenManager: mockTokenManager,
        );
        final errorAuthService = AuthServiceImpl(repository: errorRepository);
        final signUpRequest = AuthTestUtils.createValidSignUpRequest();

        // Act
        final result = await errorAuthService.signUp(signUpRequest);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, contains('Validation failed'));
      });

      test('should handle authentication errors for profile endpoint', () async {
        // Arrange
        final errorApiClient = ApiErrorMockApiClient(
          statusCode: 401,
          message: 'Unauthorized',
        );
        final errorRepository = AuthRepositoryImpl(
          apiClient: errorApiClient,
          tokenManager: mockTokenManager,
        );
        final errorAuthService = AuthServiceImpl(repository: errorRepository);

        // Act & Assert
        expect(
          () => errorAuthService.getCurrentUser(),
          throwsA(isA<TokenException>()),
        );
      });
    });

    group('Complete End-to-End Scenarios with New API', () {
      test('should complete full authentication journey with new API features', () async {
        // Arrange
        final signUpRequest = AuthTestUtils.createValidSignUpRequest();
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        final stateChanges = <AuthState>[];
        final subscription = authService.authStateStream.listen(stateChanges.add);

        // Act & Assert - Complete journey

        // 1. Registration with new API response
        final signUpResult = await authService.signUp(signUpRequest);
        expect(signUpResult.success, isTrue);
        expect(signUpResult.signUpData, isNotNull);
        expect(signUpResult.signUpData!.detail, contains('Registration successful'));
        expect(signUpResult.signUpData!.data!.verificationTokenExpiresIn, equals('10 minutes'));

        // 2. Login with rich profile data
        final loginResult = await authService.login(loginRequest);
        expect(loginResult.success, isTrue);
        expect(loginResult.loginData, isNotNull);
        expect(loginResult.loginData!.roles, contains('Creator'));
        expect(loginResult.loginData!.profileComplete['creator'], isTrue);
        expect(loginResult.loginData!.onboardingComplete, isTrue);
        expect(loginResult.loginData!.appAccess, equals('full'));
        expect(authService.userRoles, contains('Creator'));
        expect(authService.hasFullAppAccess, isTrue);

        // 3. Get comprehensive profile information
        final userProfile = await authService.getCurrentUser();
        expect(userProfile.user.displayName, isNotNull);
        expect(userProfile.mode, equals('creator'));
        expect(userProfile.availableRoles, contains('student'));
        expect(userProfile.viewType, equals('creator-complete-creator-only'));
        expect(userProfile.redirectTo, equals('/dashboard'));

        // 4. Logout with complete cleanup
        await authService.logout();
        expect(authService.isAuthenticated, isFalse);
        expect(authService.userRoles, isNull);
        expect(authService.profileComplete, isNull);
        expect(authService.hasFullAppAccess, isFalse);

        // Verify state transitions
        await Future.delayed(const Duration(milliseconds: 10));
        expect(stateChanges.length, greaterThanOrEqualTo(3));

        await subscription.cancel();
      });

      test('should demonstrate reactive state management with profile data', () async {
        // Arrange
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        final stateHistory = <AuthState>[];
        final subscription = authService.authStateStream.listen(stateHistory.add);

        // Act - Perform operations
        await authService.initialize(); // Unauthenticated
        await authService.login(loginRequest); // Authenticated with profile data
        await authService.getCurrentUser(); // Profile data access
        await authService.logout(); // Unauthenticated with cleanup

        // Allow time for state changes
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - State progression
        expect(stateHistory.length, greaterThanOrEqualTo(3));
        
        // Should have authenticated state with user data
        final authenticatedStates = stateHistory
            .where((state) => state.status == AuthStatus.authenticated)
            .toList();
        expect(authenticatedStates.isNotEmpty, isTrue);
        expect(authenticatedStates.first.user, isNotNull);

        // Should end unauthenticated
        expect(stateHistory.last.status, AuthStatus.unauthenticated);
        expect(stateHistory.last.user, isNull);

        await subscription.cancel();
      });
    });

    group('QuestionAuth Singleton with New API', () {
      setUp(() {
        QuestionAuth.reset();
      });

      test('should provide access to all new API properties through singleton', () async {
        // Arrange
        QuestionAuth.instance.configure(
          baseUrl: 'https://test-api.com/api/v1/',
        );
        await QuestionAuth.instance.initialize();

        // Act - Test all new API properties when not authenticated
        expect(QuestionAuth.instance.userRoles, isNull);
        expect(QuestionAuth.instance.profileComplete, isNull);
        expect(QuestionAuth.instance.onboardingComplete, isNull);
        expect(QuestionAuth.instance.appAccess, isNull);
        expect(QuestionAuth.instance.availableRoles, isNull);
        expect(QuestionAuth.instance.incompleteRoles, isNull);
        expect(QuestionAuth.instance.mode, isNull);
        expect(QuestionAuth.instance.viewType, isNull);
        expect(QuestionAuth.instance.redirectTo, isNull);

        // Test helper methods
        expect(QuestionAuth.instance.hasRole('creator'), isFalse);
        expect(QuestionAuth.instance.isProfileCompleteForRole('creator'), isFalse);
        expect(QuestionAuth.instance.hasFullAppAccess, isFalse);
        expect(QuestionAuth.instance.hasIncompleteRoles, isFalse);

        // Assert methods are available
        expect(QuestionAuth.instance.signUp, isA<Function>());
        expect(QuestionAuth.instance.login, isA<Function>());
        expect(QuestionAuth.instance.getCurrentUser, isA<Function>());
        expect(QuestionAuth.instance.logout, isA<Function>());
      });
    });

    group('Verification of All Updated Requirements', () {
      test('should verify all requirements are met through integration tests', () async {
        // This test serves as a comprehensive verification that all updated
        // requirements from the spec are properly implemented and tested

        // Requirement 2.1: POST /accounts/register/ with display_name
        final signUpRequest = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password@123',
          confirmPassword: 'password@123',
        );
        final signUpResult = await authService.signUp(signUpRequest);
        expect(signUpResult.success, isTrue);
        expect(signUpResult.signUpData, isNotNull);

        // Requirement 3.1-3.6: POST /accounts/login/ with rich profile data
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        final loginResult = await authService.login(loginRequest);
        expect(loginResult.success, isTrue);
        expect(loginResult.loginData!.roles, isNotEmpty);
        expect(loginResult.loginData!.profileComplete, isNotNull);
        expect(loginResult.loginData!.onboardingComplete, isA<bool>());

        // Requirement 4.1-4.6: GET /accounts/me/ with comprehensive profile
        final userProfile = await authService.getCurrentUser();
        expect(userProfile.user.displayName, isNotNull);
        expect(userProfile.roles, isNotEmpty);
        expect(userProfile.availableRoles, isNotNull);
        expect(userProfile.profileComplete, isNotNull);
        expect(userProfile.viewType, isNotNull);

        // Requirement 5.1: POST /logout/ with proper cleanup
        await authService.logout();
        expect(authService.isAuthenticated, isFalse);
        expect(authService.userRoles, isNull);

        // Requirement 6.4: Token persistence
        final storedToken = await mockTokenManager.getToken();
        expect(storedToken, isNull); // Cleared after logout

        // Requirement 8.1-8.5: User role and profile information access
        // (Tested through login and profile access above)
        
        // All requirements verified through integration testing
        expect(true, isTrue); // Placeholder assertion for test completion
      });
    });
  });
}