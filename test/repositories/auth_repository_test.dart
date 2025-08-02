import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:question_auth/src/repositories/auth_repository.dart';
import 'package:question_auth/src/services/api_client.dart';
import 'package:question_auth/src/core/token_manager.dart';
import 'package:question_auth/src/models/auth_request.dart';
import 'package:question_auth/src/models/auth_response.dart';
import 'package:question_auth/src/models/user.dart';
import 'package:question_auth/src/core/exceptions.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([ApiClient, TokenManager])
void main() {
  group('AuthRepositoryImpl', () {
    late MockApiClient mockApiClient;
    late MockTokenManager mockTokenManager;
    late AuthRepositoryImpl authRepository;

    setUp(() {
      mockApiClient = MockApiClient();
      mockTokenManager = MockTokenManager();
      authRepository = AuthRepositoryImpl(
        apiClient: mockApiClient,
        tokenManager: mockTokenManager,
      );
    });

    group('signUp', () {
      test('should successfully register user with signup data', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        final signUpResponse = SignUpResponse(
          detail: 'Registration successful! Please check your email to verify your account.',
          data: SignUpData(
            email: 'test@example.com',
            verificationTokenExpiresIn: '10 minutes',
          ),
        );
        
        when(mockApiClient.register(any))
            .thenAnswer((_) async => signUpResponse);

        // Act
        final result = await authRepository.signUp(request);

        // Assert
        expect(result.success, isTrue);
        expect(result.signUpData, equals(signUpResponse));
        expect(result.signUpData?.detail, equals('Registration successful! Please check your email to verify your account.'));
        expect(result.signUpData?.data?.email, equals('test@example.com'));
        
        verify(mockApiClient.register(request)).called(1);
        verifyNever(mockTokenManager.saveToken(any));
        verifyNever(mockApiClient.setAuthToken(any));
      });

      test('should return failure result for invalid request', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'invalid-email',
          displayName: '',
          password: 'short',
          confirmPassword: 'different',
        );

        // Act
        final result = await authRepository.signUp(request);

        // Assert
        expect(result.success, isFalse);
        expect(result.hasFieldErrors, isTrue);
        expect(result.fieldErrors?['general'], isNotEmpty);
        
        verifyNever(mockApiClient.register(any));
        verifyNever(mockTokenManager.saveToken(any));
      });

      test('should return failure result for API error response', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        when(mockApiClient.register(any))
            .thenThrow(ApiException('Email already exists', 400, 'EMAIL_EXISTS'));

        // Act
        final result = await authRepository.signUp(request);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Email already exists'));
        
        verify(mockApiClient.register(request)).called(1);
        verifyNever(mockTokenManager.saveToken(any));
      });

      test('should return failure result for network error', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        when(mockApiClient.register(any))
            .thenThrow(NetworkException('Connection failed'));

        // Act
        final result = await authRepository.signUp(request);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Connection failed'));
      });

      test('should handle validation exception with field errors', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        final fieldErrors = <String, List<String>>{
          'email': ['user with this email already exists.']
        };
        
        when(mockApiClient.register(any))
            .thenThrow(ValidationException('Validation failed', fieldErrors));

        // Act
        final result = await authRepository.signUp(request);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Validation failed'));
        expect(result.fieldErrors, equals(fieldErrors));
        
        verify(mockApiClient.register(request)).called(1);
        verifyNever(mockTokenManager.saveToken(any));
      });
    });

    group('login', () {
      test('should successfully login user and store token with rich profile data', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isVerified: true,
          isNew: false,
        );
        
        final loginResponse = LoginResponse(
          token: 'auth-token-456',
          user: user,
          roles: ['Creator'],
          profileComplete: {'student': false, 'creator': true},
          onboardingComplete: true,
          incompleteRoles: [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );
        
        when(mockApiClient.login(any))
            .thenAnswer((_) async => loginResponse);
        when(mockTokenManager.saveToken('auth-token-456'))
            .thenAnswer((_) async {});
        when(mockTokenManager.saveUserProfile(any))
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.login(request);

        // Assert
        expect(result.success, isTrue);
        expect(result.token, equals('auth-token-456'));
        expect(result.user?.email, equals('test@example.com'));
        expect(result.loginData, equals(loginResponse));
        expect(result.userRoles, equals(['Creator']));
        expect(result.profileComplete, equals({'student': false, 'creator': true}));
        expect(result.onboardingComplete, isTrue);
        expect(result.appAccess, equals('full'));
        expect(result.redirectTo, equals('/dashboard'));
        
        verify(mockApiClient.login(request)).called(1);
        verify(mockTokenManager.saveToken('auth-token-456')).called(1);
        verify(mockApiClient.setAuthToken('auth-token-456')).called(1);
      });

      test('should return failure result for invalid credentials', () async {
        // Arrange
        final request = LoginRequest(
          email: 'invalid-email',
          password: '',
        );

        // Act
        final result = await authRepository.login(request);

        // Assert
        expect(result.success, isFalse);
        expect(result.hasFieldErrors, isTrue);
        expect(result.fieldErrors?['general'], isNotEmpty);
        
        verifyNever(mockApiClient.login(any));
        verifyNever(mockTokenManager.saveToken(any));
      });

      test('should return failure result for login failure', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'wrongpassword',
        );
        
        when(mockApiClient.login(any))
            .thenThrow(ApiException('Invalid credentials', 401, 'INVALID_CREDENTIALS'));

        // Act
        final result = await authRepository.login(request);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Invalid credentials'));
        
        verify(mockApiClient.login(request)).called(1);
        verifyNever(mockTokenManager.saveToken(any));
      });
    });

    group('getCurrentUser', () {
      test('should successfully get comprehensive user profile', () async {
        // Arrange
        const token = 'valid-token-123';
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          dateJoined: DateTime.parse('2023-01-01T00:00:00Z'),
        );
        
        final userProfileResponse = UserProfileResponse(
          user: user,
          isNew: false,
          mode: 'student',
          roles: ['student', 'creator'],
          availableRoles: ['creator'],
          removableRoles: [],
          profileComplete: {'student': true, 'creator': false},
          onboardingComplete: true,
          incompleteRoles: ['creator'],
          appAccess: 'full',
          viewType: 'student-complete-student-only',
          redirectTo: '/onboarding/profile',
        );
        
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => token);
        when(mockApiClient.getCurrentUser())
            .thenAnswer((_) async => userProfileResponse);
        when(mockTokenManager.saveUserProfile(any))
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result.user.email, equals('test@example.com'));
        expect(result.user.displayName, equals('Test User'));
        expect(result.isNew, isFalse);
        expect(result.mode, equals('student'));
        expect(result.roles, equals(['student', 'creator']));
        expect(result.availableRoles, equals(['creator']));
        expect(result.profileComplete, equals({'student': true, 'creator': false}));
        expect(result.onboardingComplete, isTrue);
        expect(result.appAccess, equals('full'));
        expect(result.viewType, equals('student-complete-student-only'));
        expect(result.redirectTo, equals('/onboarding/profile'));
        
        verify(mockTokenManager.getToken()).called(1);
        verify(mockApiClient.setAuthToken(token)).called(1);
        verify(mockApiClient.getCurrentUser()).called(1);
      });

      test('should throw TokenException when no token available', () async {
        // Arrange
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => authRepository.getCurrentUser(),
          throwsA(isA<TokenException>()
              .having((e) => e.message, 'message', contains('No authentication token'))),
        );
        
        verify(mockTokenManager.getToken()).called(1);
        verifyNever(mockApiClient.setAuthToken(any));
        verifyNever(mockApiClient.get(any));
      });

      test('should handle API error when getting user profile', () async {
        // Arrange
        const token = 'expired-token';
        
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => token);
        when(mockApiClient.getCurrentUser())
            .thenThrow(ApiException('Token expired', 401, 'TOKEN_EXPIRED'));

        // Act & Assert
        try {
          await authRepository.getCurrentUser();
          fail('Expected ApiException to be thrown');
        } catch (e) {
          expect(e, isA<ApiException>()
              .having((e) => e.message, 'message', contains('Token expired'))
              .having((e) => e.statusCode, 'statusCode', equals(401)));
        }
        
        verify(mockTokenManager.getToken()).called(1);
        verify(mockApiClient.setAuthToken(token)).called(1);
        verify(mockApiClient.getCurrentUser()).called(1);
      });
    });

    group('logout', () {
      test('should successfully logout and clear token', () async {
        // Arrange
        const token = 'valid-token-123';
        final logoutResponse = LogoutResponse(detail: 'Logged out successfully.');
        
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => token);
        when(mockApiClient.logout())
            .thenAnswer((_) async => logoutResponse);
        when(mockTokenManager.clearAll())
            .thenAnswer((_) async {});

        // Act
        await authRepository.logout();

        // Assert
        verify(mockTokenManager.getToken()).called(1);
        verify(mockApiClient.setAuthToken(token)).called(1);
        verify(mockApiClient.logout()).called(1);
        verify(mockTokenManager.clearAll()).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });

      test('should clear token even when no token exists', () async {
        // Arrange
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => null);
        when(mockTokenManager.clearAll())
            .thenAnswer((_) async {});

        // Act
        await authRepository.logout();

        // Assert
        verify(mockTokenManager.getToken()).called(1);
        verifyNever(mockApiClient.setAuthToken(any));
        verifyNever(mockApiClient.post(any, any));
        verify(mockTokenManager.clearAll()).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });

      test('should clear token even when server logout fails', () async {
        // Arrange
        const token = 'valid-token-123';
        
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => token);
        when(mockApiClient.logout())
            .thenThrow(NetworkException('Server unavailable'));
        when(mockTokenManager.clearAll())
            .thenAnswer((_) async {});

        // Act
        await authRepository.logout();

        // Assert
        verify(mockTokenManager.getToken()).called(1);
        verify(mockApiClient.setAuthToken(token)).called(1);
        verify(mockApiClient.logout()).called(1);
        verify(mockTokenManager.clearAll()).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });

      test('should handle token manager error during logout', () async {
        // Arrange
        when(mockTokenManager.getToken())
            .thenThrow(Exception('Storage error'));
        when(mockTokenManager.clearAll())
            .thenAnswer((_) async {});

        // Act & Assert
        try {
          await authRepository.logout();
          fail('Expected NetworkException to be thrown');
        } catch (e) {
          expect(e, isA<NetworkException>()
              .having((e) => e.message, 'message', contains('Unexpected error during logout')));
        }
        
        // Should still attempt to clear token
        verify(mockTokenManager.clearAll()).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });
    });

    group('error handling', () {
      test('should return failure result for unexpected errors', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        when(mockApiClient.register(any))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await authRepository.signUp(request);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, contains('Unexpected error during signup'));
      });

      test('should handle AuthExceptions properly', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        final fieldErrors = <String, List<String>>{
          'email': ['Invalid email format']
        };
        
        when(mockApiClient.login(any))
            .thenThrow(ValidationException('Test validation error', fieldErrors));

        // Act
        final result = await authRepository.login(request);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, equals('Test validation error'));
        expect(result.fieldErrors, equals(fieldErrors));
      });
    });
  });
}