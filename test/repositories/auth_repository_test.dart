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
      test('should successfully register user and store token', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        final apiResponse = {
          'success': true,
          'token': 'auth-token-123',
          'user': {
            'id': '1',
            'email': 'test@example.com',
            'username': 'testuser',
            'created_at': '2023-01-01T00:00:00Z',
          },
          'message': 'Registration successful',
        };
        
        when(mockApiClient.post('accounts/signup/', any))
            .thenAnswer((_) async => apiResponse);
        when(mockTokenManager.saveToken('auth-token-123'))
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.signUp(request);

        // Assert
        expect(result.success, isTrue);
        expect(result.token, equals('auth-token-123'));
        expect(result.user?.email, equals('test@example.com'));
        expect(result.message, equals('Registration successful'));
        
        verify(mockApiClient.post('accounts/signup/', request.toJson())).called(1);
        verify(mockTokenManager.saveToken('auth-token-123')).called(1);
        verify(mockApiClient.setAuthToken('auth-token-123')).called(1);
      });

      test('should throw ValidationException for invalid request', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'invalid-email',
          username: '',
          password: 'short',
          confirmPassword: 'different',
        );

        // Act & Assert
        expect(
          () => authRepository.signUp(request),
          throwsA(isA<ValidationException>()
              .having((e) => e.fieldErrors['general'], 'general errors', isNotEmpty)),
        );
        
        verifyNever(mockApiClient.post(any, any));
        verifyNever(mockTokenManager.saveToken(any));
      });

      test('should handle API error response', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        when(mockApiClient.post('accounts/signup/', any))
            .thenThrow(ApiException('Email already exists', 400, 'EMAIL_EXISTS'));

        // Act & Assert
        expect(
          () => authRepository.signUp(request),
          throwsA(isA<ApiException>()
              .having((e) => e.message, 'message', contains('Email already exists'))
              .having((e) => e.statusCode, 'statusCode', equals(400))),
        );
        
        verify(mockApiClient.post('accounts/signup/', request.toJson())).called(1);
        verifyNever(mockTokenManager.saveToken(any));
      });

      test('should handle network error', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        when(mockApiClient.post('accounts/signup/', any))
            .thenThrow(NetworkException('Connection failed'));

        // Act & Assert
        expect(
          () => authRepository.signUp(request),
          throwsA(isA<NetworkException>()
              .having((e) => e.message, 'message', contains('Connection failed'))),
        );
      });

      test('should handle successful response without token', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        final apiResponse = {
          'success': true,
          'message': 'Registration successful, please verify email',
        };
        
        when(mockApiClient.post('accounts/signup/', any))
            .thenAnswer((_) async => apiResponse);

        // Act
        final result = await authRepository.signUp(request);

        // Assert
        expect(result.success, isTrue);
        expect(result.token, isNull);
        expect(result.message, equals('Registration successful, please verify email'));
        
        verify(mockApiClient.post('accounts/signup/', request.toJson())).called(1);
        verifyNever(mockTokenManager.saveToken(any));
        verifyNever(mockApiClient.setAuthToken(any));
      });
    });

    group('login', () {
      test('should successfully login user and store token', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        final apiResponse = {
          'success': true,
          'token': 'auth-token-456',
          'user': {
            'id': '1',
            'email': 'test@example.com',
            'username': 'testuser',
            'created_at': '2023-01-01T00:00:00Z',
          },
          'message': 'Login successful',
        };
        
        when(mockApiClient.post('accounts/login/', any))
            .thenAnswer((_) async => apiResponse);
        when(mockTokenManager.saveToken('auth-token-456'))
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.login(request);

        // Assert
        expect(result.success, isTrue);
        expect(result.token, equals('auth-token-456'));
        expect(result.user?.email, equals('test@example.com'));
        expect(result.message, equals('Login successful'));
        
        verify(mockApiClient.post('accounts/login/', request.toJson())).called(1);
        verify(mockTokenManager.saveToken('auth-token-456')).called(1);
        verify(mockApiClient.setAuthToken('auth-token-456')).called(1);
      });

      test('should throw ValidationException for invalid credentials', () async {
        // Arrange
        final request = LoginRequest(
          email: 'invalid-email',
          password: '',
        );

        // Act & Assert
        expect(
          () => authRepository.login(request),
          throwsA(isA<ValidationException>()
              .having((e) => e.fieldErrors['general'], 'general errors', isNotEmpty)),
        );
        
        verifyNever(mockApiClient.post(any, any));
        verifyNever(mockTokenManager.saveToken(any));
      });

      test('should handle login failure', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'wrongpassword',
        );
        
        when(mockApiClient.post('accounts/login/', any))
            .thenThrow(ApiException('Invalid credentials', 401, 'INVALID_CREDENTIALS'));

        // Act & Assert
        expect(
          () => authRepository.login(request),
          throwsA(isA<ApiException>()
              .having((e) => e.message, 'message', contains('Invalid credentials'))
              .having((e) => e.statusCode, 'statusCode', equals(401))),
        );
        
        verify(mockApiClient.post('accounts/login/', request.toJson())).called(1);
        verifyNever(mockTokenManager.saveToken(any));
      });
    });

    group('getCurrentUser', () {
      test('should successfully get current user profile', () async {
        // Arrange
        const token = 'valid-token-123';
        final userResponse = {
          'id': '1',
          'email': 'test@example.com',
          'username': 'testuser',
          'created_at': '2023-01-01T00:00:00Z',
        };
        
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => token);
        when(mockApiClient.get('accounts/me/'))
            .thenAnswer((_) async => userResponse);

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result.id, equals('1'));
        expect(result.email, equals('test@example.com'));
        expect(result.username, equals('testuser'));
        
        verify(mockTokenManager.getToken()).called(1);
        verify(mockApiClient.setAuthToken(token)).called(1);
        verify(mockApiClient.get('accounts/me/')).called(1);
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
        when(mockApiClient.get('accounts/me/'))
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
        verify(mockApiClient.get('accounts/me/')).called(1);
      });
    });

    group('logout', () {
      test('should successfully logout and clear token', () async {
        // Arrange
        const token = 'valid-token-123';
        
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => token);
        when(mockApiClient.post('logout/', {}))
            .thenAnswer((_) async => {'success': true});
        when(mockTokenManager.clearToken())
            .thenAnswer((_) async {});

        // Act
        await authRepository.logout();

        // Assert
        verify(mockTokenManager.getToken()).called(1);
        verify(mockApiClient.setAuthToken(token)).called(1);
        verify(mockApiClient.post('logout/', {})).called(1);
        verify(mockTokenManager.clearToken()).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });

      test('should clear token even when no token exists', () async {
        // Arrange
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => null);
        when(mockTokenManager.clearToken())
            .thenAnswer((_) async {});

        // Act
        await authRepository.logout();

        // Assert
        verify(mockTokenManager.getToken()).called(1);
        verifyNever(mockApiClient.setAuthToken(any));
        verifyNever(mockApiClient.post(any, any));
        verify(mockTokenManager.clearToken()).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });

      test('should clear token even when server logout fails', () async {
        // Arrange
        const token = 'valid-token-123';
        
        when(mockTokenManager.getToken())
            .thenAnswer((_) async => token);
        when(mockApiClient.post('logout/', {}))
            .thenThrow(NetworkException('Server unavailable'));
        when(mockTokenManager.clearToken())
            .thenAnswer((_) async {});

        // Act
        await authRepository.logout();

        // Assert
        verify(mockTokenManager.getToken()).called(1);
        verify(mockApiClient.setAuthToken(token)).called(1);
        verify(mockApiClient.post('logout/', {})).called(1);
        verify(mockTokenManager.clearToken()).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });

      test('should handle token manager error during logout', () async {
        // Arrange
        when(mockTokenManager.getToken())
            .thenThrow(Exception('Storage error'));
        when(mockTokenManager.clearToken())
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
        verify(mockTokenManager.clearToken()).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });
    });

    group('error handling', () {
      test('should wrap unexpected errors in NetworkException', () async {
        // Arrange
        final request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        when(mockApiClient.post('accounts/signup/', any))
            .thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => authRepository.signUp(request),
          throwsA(isA<NetworkException>()
              .having((e) => e.message, 'message', contains('Unexpected error during signup'))),
        );
      });

      test('should rethrow AuthExceptions without wrapping', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        final originalException = ValidationException('Test validation error', {});
        when(mockApiClient.post('accounts/login/', any))
            .thenThrow(originalException);

        // Act & Assert
        expect(
          () => authRepository.login(request),
          throwsA(same(originalException)),
        );
      });
    });
  });
}