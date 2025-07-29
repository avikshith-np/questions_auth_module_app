import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../lib/src/services/question_auth.dart';
import '../../lib/src/services/auth_service.dart';
import '../../lib/src/repositories/auth_repository.dart';
import '../../lib/src/services/api_client.dart';
import '../../lib/src/core/token_manager.dart';
import '../../lib/src/core/auth_state.dart';
import '../../lib/src/models/user.dart';
import '../../lib/src/models/auth_request.dart';
import '../../lib/src/models/auth_result.dart';
import '../../lib/src/core/exceptions.dart';

import '../utils/mock_implementations.dart';

void main() {
  group('Authentication Persistence Integration Tests', () {
    late MockFlutterSecureStorage mockStorage;
    late MockApiClient mockApiClient;
    late SecureTokenManager tokenManager;
    late AuthRepositoryImpl repository;
    late AuthServiceImpl authService;
    late QuestionAuth questionAuth;

    const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTl9.Lp-38GKDuZK6wM0U9ArLFakHBcCUG_MNaomVCbfM4aM';
    const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.invalid';
    
    final testUser = User(
      id: '123',
      email: 'test@example.com',
      username: 'testuser',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      mockApiClient = MockApiClient();
      tokenManager = SecureTokenManager(storage: mockStorage);
      repository = AuthRepositoryImpl(
        apiClient: mockApiClient as ApiClient,
        tokenManager: tokenManager,
      );
      authService = AuthServiceImpl(repository: repository);
      
      // Reset QuestionAuth singleton
      QuestionAuth.reset();
      questionAuth = QuestionAuth.instance;
      questionAuth.configure(baseUrl: 'https://test.api.com');
    });

    group('Token Persistence', () {
      test('should restore authentication state on app startup with valid token', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => testToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().toIso8601String()}","expiresAt":"${DateTime.fromMillisecondsSinceEpoch(9999999999 * 1000).toIso8601String()}"}');
        when(mockApiClient.get('accounts/me/')).thenAnswer((_) async => testUser.toJson());

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser, equals(testUser));
        expect(authService.currentAuthState.status, equals(AuthStatus.authenticated));
        
        verify(mockStorage.read(key: 'auth_token')).called(1);
        verify(mockApiClient.setAuthToken(testToken)).called(1);
        verify(mockApiClient.get('accounts/me/')).called(1);
      });

      test('should handle expired token on app startup', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => expiredToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().subtract(Duration(days: 2)).toIso8601String()}","expiresAt":"${DateTime.now().subtract(Duration(hours: 1)).toIso8601String()}"}');

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        expect(authService.currentAuthState.error, equals('Session expired'));
        
        verify(mockStorage.delete(key: 'auth_token')).called(1);
        verify(mockStorage.delete(key: 'auth_token_metadata')).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
        verifyNever(mockApiClient.get('accounts/me/'));
      });

      test('should handle no stored token on app startup', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        
        verify(mockStorage.read(key: 'auth_token')).called(1);
        verifyNever(mockApiClient.get('accounts/me/'));
      });

      test('should handle API 401 error during token validation', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => testToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().toIso8601String()}","expiresAt":"${DateTime.fromMillisecondsSinceEpoch(9999999999 * 1000).toIso8601String()}"}');
        when(mockApiClient.get('accounts/me/')).thenThrow(
          const ApiException('Unauthorized', 401, 'UNAUTHORIZED')
        );

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        expect(authService.currentAuthState.error, equals('Session expired'));
        
        verify(mockStorage.delete(key: 'auth_token')).called(1);
        verify(mockStorage.delete(key: 'auth_token_metadata')).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });

      test('should handle network error during initialization gracefully', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => testToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().toIso8601String()}","expiresAt":"${DateTime.fromMillisecondsSinceEpoch(9999999999 * 1000).toIso8601String()}"}');
        when(mockApiClient.get('accounts/me/')).thenThrow(
          const NetworkException('Network connection failed')
        );

        // Act
        await authService.initialize();

        // Assert
        expect(authService.currentAuthState.status, equals(AuthStatus.unknown));
        expect(authService.isAuthenticated, isFalse);
        
        // Token should not be cleared on network error
        verifyNever(mockStorage.delete(key: 'auth_token'));
        verifyNever(mockApiClient.clearAuthToken());
      });
    });

    group('Token Expiration Handling', () {
      test('should detect JWT token expiration correctly', () async {
        // Arrange - token with past expiration
        const pastExpiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.invalid';
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => pastExpiredToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => null);

        // Act
        final isExpired = await tokenManager.isTokenExpired();

        // Assert
        expect(isExpired, isTrue);
      });

      test('should detect valid JWT token correctly', () async {
        // Arrange - token with future expiration
        const futureValidToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTl9.Lp-38GKDuZK6wM0U9ArLFakHBcCUG_MNaomVCbfM4aM';
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => futureValidToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => null);

        // Act
        final isExpired = await tokenManager.isTokenExpired();

        // Assert
        expect(isExpired, isFalse);
      });

      test('should handle malformed token gracefully', () async {
        // Arrange
        const malformedToken = 'invalid.token.format';
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => malformedToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().subtract(Duration(days: 2)).toIso8601String()}"}');

        // Act
        final isExpired = await tokenManager.isTokenExpired();

        // Assert
        expect(isExpired, isTrue); // Should consider malformed token as expired
      });

      test('should use fallback expiration for tokens without exp claim', () async {
        // Arrange - token without exp claim, saved more than 1 day ago
        const tokenWithoutExp = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => tokenWithoutExp);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().subtract(Duration(days: 2)).toIso8601String()}"}');

        // Act
        final isExpired = await tokenManager.isTokenExpired();

        // Assert
        expect(isExpired, isTrue); // Should be expired due to fallback logic
      });
    });

    group('Session Restoration Flow', () {
      test('should complete full authentication flow with persistence', () async {
        // Arrange
        final loginRequest = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        when(mockApiClient.post('accounts/login/', loginRequest.toJson())).thenAnswer((_) async => <String, dynamic>{
          'success': true,
          'token': testToken,
          'user': testUser.toJson(),
        });

        // Act - Login
        final loginResult = await authService.login(loginRequest);

        // Assert login success
        expect(loginResult.success, isTrue);
        expect(loginResult.user, equals(testUser));
        expect(authService.isAuthenticated, isTrue);
        
        verify(mockStorage.write(key: 'auth_token', value: testToken)).called(1);
        verify(mockStorage.write(key: 'auth_token_metadata', value: any)).called(1);

        // Simulate app restart - create new service instance
        final newAuthService = AuthServiceImpl(repository: repository);
        
        // Arrange for initialization
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => testToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().toIso8601String()}","expiresAt":"${DateTime.fromMillisecondsSinceEpoch(9999999999 * 1000).toIso8601String()}"}');
        when(mockApiClient.get('accounts/me/')).thenAnswer((_) async => testUser.toJson());

        // Act - Initialize after restart
        await newAuthService.initialize();

        // Assert session restored
        expect(newAuthService.isAuthenticated, isTrue);
        expect(newAuthService.currentUser, equals(testUser));
        expect(newAuthService.currentAuthState.status, equals(AuthStatus.authenticated));
      });

      test('should handle logout and clear all persistence', () async {
        // Arrange - start with authenticated state
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => testToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().toIso8601String()}","expiresAt":"${DateTime.fromMillisecondsSinceEpoch(9999999999 * 1000).toIso8601String()}"}');
        when(mockApiClient.get('accounts/me/')).thenAnswer((_) async => testUser.toJson());
        when(mockApiClient.post('logout/', <String, dynamic>{})).thenAnswer((_) async => <String, dynamic>{});

        await authService.initialize();
        expect(authService.isAuthenticated, isTrue);

        // Act - Logout
        await authService.logout();

        // Assert logout clears everything
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        
        verify(mockStorage.delete(key: 'auth_token')).called(1);
        verify(mockStorage.delete(key: 'auth_token_metadata')).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);

        // Simulate app restart after logout
        final newAuthService = AuthServiceImpl(repository: repository);
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

        // Act - Initialize after logout
        await newAuthService.initialize();

        // Assert no session restored
        expect(newAuthService.isAuthenticated, isFalse);
        expect(newAuthService.currentUser, isNull);
        expect(newAuthService.currentAuthState.status, equals(AuthStatus.unauthenticated));
      });
    });

    group('QuestionAuth Integration', () {
      test('should initialize QuestionAuth and restore session', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => testToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().toIso8601String()}","expiresAt":"${DateTime.fromMillisecondsSinceEpoch(9999999999 * 1000).toIso8601String()}"}');
        when(mockApiClient.get('accounts/me/')).thenAnswer((_) async => testUser.toJson());

        // Act
        await questionAuth.initialize();

        // Assert
        expect(questionAuth.isAuthenticated, isTrue);
        expect(questionAuth.currentUser, equals(testUser));
        expect(questionAuth.currentAuthState.status, equals(AuthStatus.authenticated));
      });

      test('should handle initialization failure gracefully', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => testToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => 
          '{"savedAt":"${DateTime.now().toIso8601String()}","expiresAt":"${DateTime.fromMillisecondsSinceEpoch(9999999999 * 1000).toIso8601String()}"}');
        when(mockApiClient.get('accounts/me/')).thenThrow(
          const ApiException('Server error', 500)
        );

        // Act
        await questionAuth.initialize();

        // Assert
        expect(questionAuth.isAuthenticated, isFalse);
        expect(questionAuth.currentUser, isNull);
        expect(questionAuth.currentAuthState.status, equals(AuthStatus.unauthenticated));
      });
    });
  });
}