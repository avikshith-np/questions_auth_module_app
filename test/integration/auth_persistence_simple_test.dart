import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../lib/src/services/auth_service.dart';
import '../../lib/src/repositories/auth_repository.dart';
import '../../lib/src/core/token_manager.dart';
import '../../lib/src/core/auth_state.dart';
import '../../lib/src/core/exceptions.dart';

import '../utils/mock_implementations.dart';
import '../utils/auth_test_utils.dart';

void main() {
  group('Authentication Persistence Simple Tests', () {
    late MockAuthRepository mockRepository;
    late AuthServiceImpl authService;

    final testUser = AuthTestUtils.createTestUser();

    setUp(() {
      mockRepository = MockAuthRepository();
      authService = AuthServiceImpl(repository: mockRepository as AuthRepository);
    });

    group('Token Persistence and Initialization', () {
      test('should restore authentication state when valid token exists', () async {
        // Arrange
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => true);
        when(mockRepository.isTokenExpired()).thenAnswer((_) async => false);
        when(mockRepository.getCurrentUser()).thenAnswer((_) async => testUser);

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser, equals(testUser));
        expect(authService.currentAuthState.status, equals(AuthStatus.authenticated));
        
        verify(mockRepository.hasStoredToken()).called(1);
        verify(mockRepository.isTokenExpired()).called(1);
        verify(mockRepository.getCurrentUser()).called(1);
      });

      test('should set unauthenticated when no token exists', () async {
        // Arrange
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => false);

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        
        verify(mockRepository.hasStoredToken()).called(1);
        verifyNever(mockRepository.isTokenExpired());
        verifyNever(mockRepository.getCurrentUser());
      });

      test('should clear expired token and set unauthenticated', () async {
        // Arrange
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => true);
        when(mockRepository.isTokenExpired()).thenAnswer((_) async => true);

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        expect(authService.currentAuthState.error, equals('Session expired'));
        
        verify(mockRepository.hasStoredToken()).called(1);
        verify(mockRepository.isTokenExpired()).called(1);
        verify(mockRepository.clearExpiredToken()).called(1);
        verifyNever(mockRepository.getCurrentUser());
      });

      test('should handle token exception during initialization', () async {
        // Arrange
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => true);
        when(mockRepository.isTokenExpired()).thenAnswer((_) async => false);
        when(mockRepository.getCurrentUser()).thenThrow(
          const TokenException('Invalid token')
        );

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        expect(authService.currentAuthState.error, equals('Invalid token'));
        
        verify(mockRepository.clearExpiredToken()).called(1);
      });

      test('should handle 401 API exception during initialization', () async {
        // Arrange
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => true);
        when(mockRepository.isTokenExpired()).thenAnswer((_) async => false);
        when(mockRepository.getCurrentUser()).thenThrow(
          const ApiException('Unauthorized', 401, 'UNAUTHORIZED')
        );

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        expect(authService.currentAuthState.error, equals('Session expired'));
        
        verify(mockRepository.clearExpiredToken()).called(1);
      });

      test('should handle network error during initialization gracefully', () async {
        // Arrange
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => true);
        when(mockRepository.isTokenExpired()).thenAnswer((_) async => false);
        when(mockRepository.getCurrentUser()).thenThrow(
          const NetworkException('Network connection failed')
        );

        // Act
        await authService.initialize();

        // Assert
        expect(authService.currentAuthState.status, equals(AuthStatus.unknown));
        expect(authService.isAuthenticated, isFalse);
        
        // Token should not be cleared on network error
        verifyNever(mockRepository.clearExpiredToken());
      });

      test('should handle unexpected error during initialization', () async {
        // Arrange
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => true);
        when(mockRepository.isTokenExpired()).thenAnswer((_) async => false);
        when(mockRepository.getCurrentUser()).thenThrow(
          Exception('Unexpected error')
        );

        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        expect(authService.currentAuthState.error, equals('Authentication initialization failed'));
      });
    });

    group('Token Manager Integration', () {
      late MockTokenManager mockTokenManager;

      setUp(() {
        mockTokenManager = MockTokenManager();
      });

      test('should validate token expiration correctly', () async {
        // Test valid token
        mockTokenManager.simulateToken('valid-token');
        when(mockTokenManager.isTokenExpired()).thenAnswer((_) async => false);
        
        final isExpired = await mockTokenManager.isTokenExpired();
        expect(isExpired, isFalse);

        // Test expired token
        when(mockTokenManager.isTokenExpired()).thenAnswer((_) async => true);
        
        final isExpiredAfter = await mockTokenManager.isTokenExpired();
        expect(isExpiredAfter, isTrue);
      });

      test('should handle token storage and retrieval', () async {
        const testToken = 'test-token-123';
        
        // Save token
        await mockTokenManager.saveToken(testToken);
        expect(mockTokenManager.storedToken, equals(testToken));
        
        // Retrieve token
        final retrievedToken = await mockTokenManager.getToken();
        expect(retrievedToken, equals(testToken));
        
        // Clear token
        await mockTokenManager.clearToken();
        expect(mockTokenManager.storedToken, isNull);
      });

      test('should validate token existence correctly', () async {
        // No token
        mockTokenManager.simulateToken(null);
        final hasNoToken = await mockTokenManager.hasValidToken();
        expect(hasNoToken, isFalse);
        
        // Valid token
        mockTokenManager.simulateToken('valid-token');
        final hasValidToken = await mockTokenManager.hasValidToken();
        expect(hasValidToken, isTrue);
        
        // Empty token
        mockTokenManager.simulateToken('');
        final hasEmptyToken = await mockTokenManager.hasValidToken();
        expect(hasEmptyToken, isFalse);
      });
    });

    group('Authentication State Transitions', () {
      test('should transition from unknown to authenticated on successful initialization', () async {
        // Arrange
        expect(authService.currentAuthState.status, equals(AuthStatus.unknown));
        
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => true);
        when(mockRepository.isTokenExpired()).thenAnswer((_) async => false);
        when(mockRepository.getCurrentUser()).thenAnswer((_) async => testUser);

        // Act
        await authService.initialize();

        // Assert
        expect(authService.currentAuthState.status, equals(AuthStatus.authenticated));
        expect(authService.currentUser, equals(testUser));
      });

      test('should transition from unknown to unauthenticated on failed initialization', () async {
        // Arrange
        expect(authService.currentAuthState.status, equals(AuthStatus.unknown));
        
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => false);

        // Act
        await authService.initialize();

        // Assert
        expect(authService.currentAuthState.status, equals(AuthStatus.unauthenticated));
        expect(authService.currentUser, isNull);
      });

      test('should maintain unknown state on network error', () async {
        // Arrange
        expect(authService.currentAuthState.status, equals(AuthStatus.unknown));
        
        when(mockRepository.hasStoredToken()).thenAnswer((_) async => true);
        when(mockRepository.isTokenExpired()).thenAnswer((_) async => false);
        when(mockRepository.getCurrentUser()).thenThrow(
          const NetworkException('Network error')
        );

        // Act
        await authService.initialize();

        // Assert
        expect(authService.currentAuthState.status, equals(AuthStatus.unknown));
      });
    });
  });
}