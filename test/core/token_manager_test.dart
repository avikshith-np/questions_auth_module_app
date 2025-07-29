import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:question_auth/src/core/token_manager.dart';

import 'token_manager_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  group('SecureTokenManager', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureTokenManager tokenManager;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      tokenManager = SecureTokenManager(storage: mockStorage);
    });

    group('saveToken', () {
      test('should save token successfully', () async {
        // Arrange
        const token = 'test_token_123';
        when(
          mockStorage.write(key: 'auth_token', value: token),
        ).thenAnswer((_) async {});

        // Act
        await tokenManager.saveToken(token);

        // Assert
        verify(mockStorage.write(key: 'auth_token', value: token)).called(1);
      });

      test('should throw ArgumentError when token is empty', () async {
        // Act & Assert
        expect(() => tokenManager.saveToken(''), throwsA(isA<ArgumentError>()));

        verifyNever(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        );
      });

      test('should throw Exception when storage write fails', () async {
        // Arrange
        const token = 'test_token_123';
        when(
          mockStorage.write(key: 'auth_token', value: token),
        ).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => tokenManager.saveToken(token),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to save token'),
            ),
          ),
        );
      });
    });

    group('getToken', () {
      test('should return token when it exists', () async {
        // Arrange
        const expectedToken = 'stored_token_456';
        when(
          mockStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => expectedToken);

        // Act
        final result = await tokenManager.getToken();

        // Assert
        expect(result, equals(expectedToken));
        verify(mockStorage.read(key: 'auth_token')).called(1);
      });

      test('should return null when no token exists', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

        // Act
        final result = await tokenManager.getToken();

        // Assert
        expect(result, isNull);
        verify(mockStorage.read(key: 'auth_token')).called(1);
      });

      test('should throw Exception when storage read fails', () async {
        // Arrange
        when(
          mockStorage.read(key: 'auth_token'),
        ).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => tokenManager.getToken(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to retrieve token'),
            ),
          ),
        );
      });
    });

    group('clearToken', () {
      test('should clear token successfully', () async {
        // Arrange
        when(mockStorage.delete(key: 'auth_token')).thenAnswer((_) async {});

        // Act
        await tokenManager.clearToken();

        // Assert
        verify(mockStorage.delete(key: 'auth_token')).called(1);
      });

      test('should throw Exception when storage delete fails', () async {
        // Arrange
        when(
          mockStorage.delete(key: 'auth_token'),
        ).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => tokenManager.clearToken(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to clear token'),
            ),
          ),
        );
      });
    });

    group('hasValidToken', () {
      test('should return true when valid token exists', () async {
        // Arrange
        const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTl9.Lp-38GKDuZK6wM0U9ArLFakHBcCUG_MNaomVCbfM4aM';
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => token);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => null);

        // Act
        final result = await tokenManager.hasValidToken();

        // Assert
        expect(result, isTrue);
        verify(mockStorage.read(key: 'auth_token')).called(greaterThanOrEqualTo(1));
      });

      test('should return false when token is null', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

        // Act
        final result = await tokenManager.hasValidToken();

        // Assert
        expect(result, isFalse);
        verify(mockStorage.read(key: 'auth_token')).called(1);
      });

      test('should return false when token is empty', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => '');

        // Act
        final result = await tokenManager.hasValidToken();

        // Assert
        expect(result, isFalse);
        verify(mockStorage.read(key: 'auth_token')).called(1);
      });

      test('should return false when storage read fails', () async {
        // Arrange
        when(
          mockStorage.read(key: 'auth_token'),
        ).thenThrow(Exception('Storage error'));

        // Act
        final result = await tokenManager.hasValidToken();

        // Assert
        expect(result, isFalse);
        verify(mockStorage.read(key: 'auth_token')).called(1);
      });
    });

    group('isTokenExpired', () {
      test('should return true when token is null', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

        // Act
        final result = await tokenManager.isTokenExpired();

        // Assert
        expect(result, isTrue);
      });

      test('should return true when token is empty', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => '');

        // Act
        final result = await tokenManager.isTokenExpired();

        // Assert
        expect(result, isTrue);
      });

      test('should return false for valid JWT token with future expiration', () async {
        // Arrange - JWT token with exp claim set to far future
        const validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTl9.Lp-38GKDuZK6wM0U9ArLFakHBcCUG_MNaomVCbfM4aM';
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => validToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => null);

        // Act
        final result = await tokenManager.isTokenExpired();

        // Assert
        expect(result, isFalse);
      });

      test('should return true for expired JWT token', () async {
        // Arrange - JWT token with exp claim set to past
        const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.invalid';
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => expiredToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => null);

        // Act
        final result = await tokenManager.isTokenExpired();

        // Assert
        expect(result, isTrue);
      });

      test('should use fallback expiration for token without exp claim', () async {
        // Arrange - JWT token without exp claim, saved more than 1 day ago
        const tokenWithoutExp = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
        final oldDate = DateTime.now().subtract(const Duration(days: 2));
        final metadata = '{"savedAt":"${oldDate.toIso8601String()}"}';
        
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => tokenWithoutExp);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => metadata);

        // Act
        final result = await tokenManager.isTokenExpired();

        // Assert
        expect(result, isTrue);
      });

      test('should handle malformed token gracefully', () async {
        // Arrange
        const malformedToken = 'invalid.token.format';
        final recentDate = DateTime.now().subtract(const Duration(minutes: 30));
        final metadata = '{"savedAt":"${recentDate.toIso8601String()}"}';
        
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => malformedToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => metadata);

        // Act
        final result = await tokenManager.isTokenExpired();

        // Assert
        expect(result, isFalse); // Should be false since it was saved recently and fallback logic applies
      });

      test('should return true on storage error for security', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenThrow(Exception('Storage error'));

        // Act
        final result = await tokenManager.isTokenExpired();

        // Assert
        expect(result, isTrue);
      });
    });

    group('getTokenExpiration', () {
      test('should return null when token is null', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => null);

        // Act
        final result = await tokenManager.getTokenExpiration();

        // Assert
        expect(result, isNull);
      });

      test('should extract expiration from JWT token', () async {
        // Arrange - JWT token with exp claim
        const tokenWithExp = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTl9.Lp-38GKDuZK6wM0U9ArLFakHBcCUG_MNaomVCbfM4aM';
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => tokenWithExp);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => null);

        // Act
        final result = await tokenManager.getTokenExpiration();

        // Assert
        expect(result, isNotNull);
        expect(result!.isAfter(DateTime.now()), isTrue);
      });

      test('should return expiration from metadata when available', () async {
        // Arrange
        const token = 'some.token.here';
        final futureDate = DateTime.now().add(const Duration(hours: 1));
        final metadata = '{"savedAt":"${DateTime.now().toIso8601String()}","expiresAt":"${futureDate.toIso8601String()}"}';
        
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => token);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => metadata);

        // Act
        final result = await tokenManager.getTokenExpiration();

        // Assert
        expect(result, isNotNull);
        expect(result!.difference(futureDate).inSeconds.abs(), lessThan(2));
      });

      test('should return null for malformed token', () async {
        // Arrange
        const malformedToken = 'invalid.token';
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => malformedToken);
        when(mockStorage.read(key: 'auth_token_metadata')).thenAnswer((_) async => null);

        // Act
        final result = await tokenManager.getTokenExpiration();

        // Assert
        expect(result, isNull);
      });
    });

    group('constructor', () {
      test('should use default FlutterSecureStorage when none provided', () {
        // Act
        final manager = SecureTokenManager();

        // Assert
        expect(manager, isA<SecureTokenManager>());
      });

      test('should use provided storage instance', () {
        // Arrange
        final customStorage = MockFlutterSecureStorage();

        // Act
        final manager = SecureTokenManager(storage: customStorage);

        // Assert
        expect(manager, isA<SecureTokenManager>());
      });
    });
  });
}
