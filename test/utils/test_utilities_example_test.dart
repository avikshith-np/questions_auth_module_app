import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:question_auth/question_auth.dart';
import 'auth_test_utils.dart';
import 'mock_implementations.dart';

/// Example tests demonstrating the usage of updated test utilities
/// for new API models and functionality
void main() {
  group('Test Utilities Examples - New API Models', () {
    group('SignUpResponse Test Utilities', () {
      test('should create test SignUpResponse with default values', () {
        final signUpResponse = AuthTestUtils.createTestSignUpResponse();
        
        expect(signUpResponse.detail, 'Registration successful! Please check your email to verify your account.');
        expect(signUpResponse.data?.email, 'test@example.com');
        expect(signUpResponse.data?.verificationTokenExpiresIn, '10 minutes');
      });

      test('should create test SignUpResponse with custom values', () {
        final signUpResponse = AuthTestUtils.createTestSignUpResponse(
          detail: 'Custom registration message',
          email: 'custom@example.com',
          verificationTokenExpiresIn: '15 minutes',
        );
        
        expect(signUpResponse.detail, 'Custom registration message');
        expect(signUpResponse.data?.email, 'custom@example.com');
        expect(signUpResponse.data?.verificationTokenExpiresIn, '15 minutes');
      });

      test('should create SignUpResponse from API response data', () {
        final apiResponse = AuthTestUtils.createSignUpApiResponse(
          detail: 'API registration successful',
          email: 'api@example.com',
        );
        
        final signUpResponse = SignUpResponse.fromJson(apiResponse);
        
        expect(signUpResponse.detail, 'API registration successful');
        expect(signUpResponse.data?.email, 'api@example.com');
      });
    });

    group('LoginResponse Test Utilities', () {
      test('should create test LoginResponse with default values', () {
        final loginResponse = AuthTestUtils.createTestLoginResponse();
        
        expect(loginResponse.token, 'test-token-123');
        expect(loginResponse.user.email, 'test@example.com');
        expect(loginResponse.roles, ['Creator']);
        expect(loginResponse.profileComplete, {'creator': true, 'student': false});
        expect(loginResponse.onboardingComplete, true);
        expect(loginResponse.appAccess, 'full');
        expect(loginResponse.redirectTo, '/dashboard');
      });

      test('should create test LoginResponse with custom values', () {
        final customUser = AuthTestUtils.createTestUser(
          email: 'custom@example.com',
          displayName: 'Custom User',
        );
        
        final loginResponse = AuthTestUtils.createTestLoginResponse(
          token: 'custom-token-456',
          user: customUser,
          roles: ['Student', 'Creator'],
          profileComplete: {'student': true, 'creator': true},
          onboardingComplete: false,
          appAccess: 'limited',
          redirectTo: '/onboarding',
        );
        
        expect(loginResponse.token, 'custom-token-456');
        expect(loginResponse.user.email, 'custom@example.com');
        expect(loginResponse.roles, ['Student', 'Creator']);
        expect(loginResponse.profileComplete, {'student': true, 'creator': true});
        expect(loginResponse.onboardingComplete, false);
        expect(loginResponse.appAccess, 'limited');
        expect(loginResponse.redirectTo, '/onboarding');
      });

      test('should create LoginResponse from API response data', () {
        final apiResponse = AuthTestUtils.createLoginApiResponse(
          token: 'api-token-789',
          email: 'api@example.com',
          displayName: 'API User',
          roles: ['Student'],
        );
        
        final loginResponse = LoginResponse.fromJson(apiResponse);
        
        expect(loginResponse.token, 'api-token-789');
        expect(loginResponse.user.email, 'api@example.com');
        expect(loginResponse.user.displayName, 'API User');
        expect(loginResponse.roles, ['Student']);
      });
    });

    group('UserProfileResponse Test Utilities', () {
      test('should create test UserProfileResponse with default values', () {
        final userProfile = AuthTestUtils.createTestUserProfileResponse();
        
        expect(userProfile.user.email, 'test@example.com');
        expect(userProfile.isNew, false);
        expect(userProfile.mode, 'creator');
        expect(userProfile.roles, ['creator']);
        expect(userProfile.availableRoles, ['student']);
        expect(userProfile.profileComplete, {'creator': true, 'student': false});
        expect(userProfile.onboardingComplete, true);
        expect(userProfile.appAccess, 'full');
        expect(userProfile.viewType, 'creator-complete-creator-only');
        expect(userProfile.redirectTo, '/dashboard');
      });

      test('should create test UserProfileResponse with custom values', () {
        final customUser = AuthTestUtils.createTestUser(
          email: 'profile@example.com',
          displayName: 'Profile User',
        );
        
        final userProfile = AuthTestUtils.createTestUserProfileResponse(
          user: customUser,
          isNew: true,
          mode: 'student',
          roles: ['student'],
          availableRoles: ['creator'],
          profileComplete: {'student': false, 'creator': false},
          onboardingComplete: false,
          appAccess: 'none',
          viewType: 'student-incomplete',
          redirectTo: '/profile-setup',
        );
        
        expect(userProfile.user.email, 'profile@example.com');
        expect(userProfile.isNew, true);
        expect(userProfile.mode, 'student');
        expect(userProfile.roles, ['student']);
        expect(userProfile.availableRoles, ['creator']);
        expect(userProfile.profileComplete, {'student': false, 'creator': false});
        expect(userProfile.onboardingComplete, false);
        expect(userProfile.appAccess, 'none');
        expect(userProfile.viewType, 'student-incomplete');
        expect(userProfile.redirectTo, '/profile-setup');
      });

      test('should create UserProfileResponse from API response data', () {
        final apiResponse = AuthTestUtils.createUserProfileApiResponse(
          email: 'profile-api@example.com',
          displayName: 'Profile API User',
          mode: 'student',
          roles: ['student'],
        );
        
        final userProfile = UserProfileResponse.fromJson(apiResponse);
        
        expect(userProfile.user.email, 'profile-api@example.com');
        expect(userProfile.user.displayName, 'Profile API User');
        expect(userProfile.mode, 'student');
        expect(userProfile.roles, ['student']);
      });
    });

    group('AuthResult Test Utilities', () {
      test('should create successful AuthResult with login data', () {
        final authResult = AuthTestUtils.createLoginSuccessResult(
          token: 'success-token-123',
        );
        
        expect(authResult.success, true);
        expect(authResult.token, 'success-token-123');
        expect(authResult.user, isNotNull);
        expect(authResult.loginData, isNotNull);
        expect(authResult.hasRichUserData, true);
        expect(authResult.userRoles, ['Creator']);
        expect(authResult.profileComplete, {'creator': true, 'student': false});
        expect(authResult.onboardingComplete, true);
        expect(authResult.appAccess, 'full');
        expect(authResult.redirectTo, '/dashboard');
      });

      test('should create successful AuthResult with signup data', () {
        final authResult = AuthTestUtils.createSignUpSuccessResult();
        
        expect(authResult.success, true);
        expect(authResult.signUpData, isNotNull);
        expect(authResult.hasSignUpData, true);
        expect(authResult.signUpData?.detail, contains('Registration successful'));
      });

      test('should create failed AuthResult with field errors', () {
        final fieldErrors = {
          'email': ['Invalid email format'],
          'password': ['Password too short'],
        };
        
        final authResult = AuthTestUtils.createFailureResult(
          error: 'Validation failed',
          fieldErrors: fieldErrors,
        );
        
        expect(authResult.success, false);
        expect(authResult.error, 'Validation failed');
        expect(authResult.hasFieldErrors, true);
        expect(authResult.fieldErrors, fieldErrors);
        expect(authResult.getFieldErrors('email'), ['Invalid email format']);
        expect(authResult.getFirstFieldError('password'), 'Password too short');
      });
    });
  });

  group('Mock Implementations Examples - New API Models', () {
    group('MockAuthService with New API Data', () {
      late MockAuthService mockAuthService;

      setUp(() {
        mockAuthService = MockAuthService();
      });

      tearDown(() {
        mockAuthService.dispose();
      });

      test('should simulate authentication with login data', () {
        final user = AuthTestUtils.createTestUser();
        final loginData = AuthTestUtils.createTestLoginResponse(
          user: user,
          roles: ['Student', 'Creator'],
          profileComplete: {'student': true, 'creator': false},
        );
        
        mockAuthService.simulateAuthentication(user, loginData: loginData);
        
        expect(mockAuthService.isAuthenticated, true);
        expect(mockAuthService.currentUser, user);
        expect(mockAuthService.userRoles, ['Student', 'Creator']);
        expect(mockAuthService.profileComplete, {'student': true, 'creator': false});
      });

      test('should provide access to user profile data', () {
        final user = AuthTestUtils.createTestUser();
        final loginData = AuthTestUtils.createTestLoginResponse(
          user: user,
          onboardingComplete: false,
          appAccess: 'limited',
        );
        
        mockAuthService.simulateAuthentication(user, loginData: loginData);
        
        expect(mockAuthService.onboardingComplete, false);
        expect(mockAuthService.appAccess, 'limited');
      });
    });

    group('MockAuthRepository with New API Models', () {
      late MockAuthRepository mockRepository;

      setUp(() {
        mockRepository = MockAuthRepository();
      });

      test('should return AuthResult for signup', () async {
        final request = AuthTestUtils.createValidSignUpRequest();
        
        final result = await mockRepository.signUp(request);
        
        expect(result, isA<AuthResult>());
        expect(result.success, true);
        expect(result.hasSignUpData, true);
      });

      test('should return AuthResult for login', () async {
        final request = AuthTestUtils.createValidLoginRequest();
        
        final result = await mockRepository.login(request);
        
        expect(result, isA<AuthResult>());
        expect(result.success, true);
        expect(result.hasRichUserData, true);
        expect(result.userRoles, isNotNull);
      });

      test('should return UserProfileResponse for getCurrentUser', () async {
        final userProfile = await mockRepository.getCurrentUser();
        
        expect(userProfile, isA<UserProfileResponse>());
        expect(userProfile.user, isNotNull);
        expect(userProfile.roles, isNotNull);
        expect(userProfile.profileComplete, isNotNull);
      });

      test('should demonstrate custom result creation', () async {
        final customSignUpResponse = AuthTestUtils.createTestSignUpResponse(
          detail: 'Custom signup success',
        );
        final customResult = AuthTestUtils.createSignUpSuccessResult(
          signUpData: customSignUpResponse,
        );
        
        expect(customResult.success, true);
        expect(customResult.signUpData?.detail, 'Custom signup success');
        expect(customResult.hasSignUpData, true);
      });
    });

    group('MockApiClient with New Endpoint Methods', () {
      late MockApiClient mockApiClient;

      setUp(() {
        mockApiClient = MockApiClient();
      });

      test('should return SignUpResponse for register endpoint', () async {
        final request = AuthTestUtils.createValidSignUpRequest();
        
        final response = await mockApiClient.register(request);
        
        expect(response, isA<SignUpResponse>());
        expect(response.detail, isNotNull);
        expect(response.data, isNotNull);
      });

      test('should return LoginResponse for login endpoint', () async {
        final request = AuthTestUtils.createValidLoginRequest();
        
        final response = await mockApiClient.login(request);
        
        expect(response, isA<LoginResponse>());
        expect(response.token, isNotNull);
        expect(response.user, isNotNull);
        expect(response.roles, isNotNull);
        expect(response.profileComplete, isNotNull);
      });

      test('should return UserProfileResponse for getCurrentUser endpoint', () async {
        final response = await mockApiClient.getCurrentUser();
        
        expect(response, isA<UserProfileResponse>());
        expect(response.user, isNotNull);
        expect(response.roles, isNotNull);
        expect(response.profileComplete, isNotNull);
      });

      test('should return LogoutResponse for logout endpoint', () async {
        final response = await mockApiClient.logout();
        
        expect(response, isA<LogoutResponse>());
        expect(response.detail, isNotNull);
      });

      test('should demonstrate custom response creation', () async {
        final customLoginResponse = AuthTestUtils.createTestLoginResponse(
          token: 'custom-mock-token',
          roles: ['Admin'],
        );
        
        expect(customLoginResponse.token, 'custom-mock-token');
        expect(customLoginResponse.roles, ['Admin']);
        expect(customLoginResponse.user, isNotNull);
        expect(customLoginResponse.profileComplete, isNotNull);
      });
    });

    group('Specialized Mock Implementations', () {
      test('should use SuccessfulMockApiClient for consistent success responses', () async {
        final mockApiClient = SuccessfulMockApiClient();
        
        final signUpRequest = AuthTestUtils.createValidSignUpRequest();
        final loginRequest = AuthTestUtils.createValidLoginRequest();
        
        final signUpResponse = await mockApiClient.register(signUpRequest);
        final loginResponse = await mockApiClient.login(loginRequest);
        final userProfile = await mockApiClient.getCurrentUser();
        final logoutResponse = await mockApiClient.logout();
        
        expect(signUpResponse, isA<SignUpResponse>());
        expect(loginResponse, isA<LoginResponse>());
        expect(userProfile, isA<UserProfileResponse>());
        expect(logoutResponse, isA<LogoutResponse>());
      });

      test('should use NetworkErrorMockApiClient for network error scenarios', () async {
        final mockApiClient = NetworkErrorMockApiClient();
        
        final signUpRequest = AuthTestUtils.createValidSignUpRequest();
        
        expect(
          () => mockApiClient.register(signUpRequest),
          throwsA(isA<NetworkException>()),
        );
        expect(
          () => mockApiClient.getCurrentUser(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should use ValidationErrorMockRepository for validation error scenarios', () async {
        final mockRepository = ValidationErrorMockRepository();
        
        final signUpRequest = AuthTestUtils.createValidSignUpRequest();
        
        expect(
          () => mockRepository.signUp(signUpRequest),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => mockRepository.getCurrentUser(),
          throwsA(isA<ValidationException>()),
        );
      });
    });
  });

  group('Factory Methods Examples', () {
    test('should create authenticated mock auth service', () {
      final user = AuthTestUtils.createTestUser(email: 'factory@example.com');
      final mockAuthService = MockFactory.createAuthenticatedMockAuthService(user: user);
      
      expect(mockAuthService.isAuthenticated, true);
      expect(mockAuthService.currentUser?.email, 'factory@example.com');
      
      mockAuthService.dispose();
    });

    test('should create unauthenticated mock auth service', () {
      const errorMessage = 'Authentication failed';
      final mockAuthService = MockFactory.createUnauthenticatedMockAuthService(
        error: errorMessage,
      );
      
      expect(mockAuthService.isAuthenticated, false);
      expect(mockAuthService.currentAuthState.error, errorMessage);
      
      mockAuthService.dispose();
    });

    test('should create mock token manager with token', () {
      const testToken = 'factory-token-123';
      final mockTokenManager = MockFactory.createTokenMockTokenManager(token: testToken);
      
      expect(mockTokenManager.storedToken, testToken);
    });

    test('should create empty mock token manager', () {
      final mockTokenManager = MockFactory.createEmptyMockTokenManager();
      
      expect(mockTokenManager.storedToken, isNull);
    });
  });

  group('Error Handling Examples', () {
    test('should verify ValidationException with field errors', () {
      final fieldErrors = {
        'email': ['Invalid email format'],
        'password': ['Password too short'],
      };
      
      final exception = ValidationException('Validation failed', fieldErrors);
      
      AuthTestUtils.verifyValidationException(exception, fieldErrors);
    });

    test('should verify ApiException with status code', () {
      const statusCode = 401;
      const message = 'Unauthorized access';
      const code = 'AUTH_FAILED';
      
      final exception = ApiException(message, statusCode, code);
      
      AuthTestUtils.verifyApiException(exception, statusCode, message, expectedCode: code);
    });

    test('should verify general exception type and message', () {
      final exception = NetworkException('Network connection failed');
      
      AuthTestUtils.verifyException<NetworkException>(
        exception,
        'Network connection failed',
        exactMatch: false,
      );
    });
  });
}