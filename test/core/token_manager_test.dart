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
        const token = 'valid_token_789';
        when(
          mockStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => token);

        // Act
        final result = await tokenManager.hasValidToken();

        // Assert
        expect(result, isTrue);
        verify(mockStorage.read(key: 'auth_token')).called(1);
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
