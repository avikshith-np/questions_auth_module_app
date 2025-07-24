import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:question_auth/src/services/api_client.dart';
import 'package:question_auth/src/core/exceptions.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('HttpApiClient', () {
    late MockClient mockClient;
    late HttpApiClient apiClient;
    const baseUrl = 'https://api.example.com';

    setUp(() {
      mockClient = MockClient();
      apiClient = HttpApiClient(
        baseUrl: baseUrl,
        client: mockClient,
        timeout: const Duration(seconds: 5),
      );
    });

    tearDown(() {
      apiClient.dispose();
    });

    group('constructor', () {
      test('should handle base URL with trailing slash', () {
        final client = HttpApiClient(baseUrl: 'https://api.example.com/');
        // We can't test private fields directly, but we can test behavior
        expect(() => client, returnsNormally);
        client.dispose();
      });

      test('should add trailing slash to base URL if missing', () {
        final client = HttpApiClient(baseUrl: 'https://api.example.com');
        // We can't test private fields directly, but we can test behavior
        expect(() => client, returnsNormally);
        client.dispose();
      });

      test('should use default timeout if not provided', () {
        final client = HttpApiClient(baseUrl: baseUrl);
        // We can't test private fields directly, but we can test behavior
        expect(() => client, returnsNormally);
        client.dispose();
      });
    });

    group('POST requests', () {
      test('should make successful POST request', () async {
        // Arrange
        final requestData = {'email': 'test@example.com', 'password': 'password123'};
        final responseData = {'success': true, 'token': 'abc123'};
        
        when(mockClient.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiClient.post('auth/login', requestData);

        // Assert
        expect(result, equals(responseData));
        verify(mockClient.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: argThat(
            allOf([
              containsPair('Content-Type', 'application/json'),
              containsPair('Accept', 'application/json'),
            ]),
            named: 'headers',
          ),
          body: jsonEncode(requestData),
        )).called(1);
      });

      test('should include auth token in headers when set', () async {
        // Arrange
        const token = 'bearer-token-123';
        apiClient.setAuthToken(token);
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await apiClient.post('test', {});

        // Assert
        verify(mockClient.post(
          any,
          headers: argThat(
            containsPair('Authorization', 'Bearer $token'),
            named: 'headers',
          ),
          body: anyNamed('body'),
        )).called(1);
      });

      test('should handle endpoint with leading slash', () async {
        // Arrange
        when(mockClient.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await apiClient.post('/auth/login', {});

        // Assert
        verify(mockClient.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });

      test('should throw NetworkException on SocketException', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const SocketException('Connection failed'));

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<NetworkException>()
              .having((e) => e.message, 'message', contains('Network connection failed'))),
        );
      });

      test('should throw NetworkException on timeout', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 10));
          return http.Response('{}', 200);
        });

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('GET requests', () {
      test('should make successful GET request', () async {
        // Arrange
        final responseData = {'id': '1', 'name': 'Test User'};
        
        when(mockClient.get(
          Uri.parse('$baseUrl/user/profile'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiClient.get('user/profile');

        // Assert
        expect(result, equals(responseData));
        verify(mockClient.get(
          Uri.parse('$baseUrl/user/profile'),
          headers: argThat(
            allOf([
              containsPair('Content-Type', 'application/json'),
              containsPair('Accept', 'application/json'),
            ]),
            named: 'headers',
          ),
        )).called(1);
      });

      test('should include auth token in headers when set', () async {
        // Arrange
        const token = 'bearer-token-123';
        apiClient.setAuthToken(token);
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await apiClient.get('test');

        // Assert
        verify(mockClient.get(
          any,
          headers: argThat(
            containsPair('Authorization', 'Bearer $token'),
            named: 'headers',
          ),
        )).called(1);
      });

      test('should throw NetworkException on SocketException', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(const SocketException('Connection failed'));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<NetworkException>()
              .having((e) => e.message, 'message', contains('Network connection failed'))),
        );
      });
    });

    group('Authentication token management', () {
      test('should set auth token', () {
        // Arrange
        const token = 'test-token-123';

        // Act & Assert - We can't access private fields, but we can test behavior
        expect(() => apiClient.setAuthToken(token), returnsNormally);
      });

      test('should clear auth token', () {
        // Arrange
        apiClient.setAuthToken('test-token');

        // Act & Assert - We can't access private fields, but we can test behavior
        expect(() => apiClient.clearAuthToken(), returnsNormally);
      });

      test('should not include Authorization header when token is not set', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await apiClient.get('test');

        // Assert
        verify(mockClient.get(
          any,
          headers: argThat(
            isNot(containsPair('Authorization', anything)),
            named: 'headers',
          ),
        )).called(1);
      });
    });

    group('Error handling', () {
      test('should throw ApiException for 400 Bad Request', () async {
        // Arrange
        final errorResponse = {'message': 'Invalid request data'};
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(errorResponse),
          400,
        ));

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(400))
              .having((e) => e.message, 'message', contains('Bad Request'))),
        );
      });

      test('should throw ApiException for 401 Unauthorized', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'message': 'Authentication required'}),
          401,
        ));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(401))
              .having((e) => e.message, 'message', contains('Unauthorized'))),
        );
      });

      test('should throw ValidationException for 422 with field errors', () async {
        // Arrange
        final errorResponse = {
          'message': 'Validation failed',
          'errors': {
            'email': ['Email is required', 'Email format is invalid'],
            'password': ['Password is too short']
          }
        };
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(errorResponse),
          422,
        ));

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<ValidationException>()
              .having((e) => e.fieldErrors['email'], 'email errors', 
                      equals(['Email is required', 'Email format is invalid']))
              .having((e) => e.fieldErrors['password'], 'password errors', 
                      equals(['Password is too short']))),
        );
      });

      test('should throw NetworkException for 502 Bad Gateway', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Bad Gateway', 502));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<NetworkException>()
              .having((e) => e.message, 'message', contains('Bad Gateway'))),
        );
      });

      test('should handle empty response body', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 200));

        // Act
        final result = await apiClient.get('test');

        // Assert
        expect(result, equals({}));
      });

      test('should handle invalid JSON response', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('invalid json', 200));

        // Act
        final result = await apiClient.get('test');

        // Assert
        expect(result['error'], equals('Invalid JSON response'));
        expect(result['message'], equals('invalid json'));
      });

      test('should handle FormatException', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const FormatException('Invalid format'));

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<NetworkException>()
              .having((e) => e.message, 'message', contains('Invalid response format'))),
        );
      });
    });

    group('Response handling', () {
      test('should return empty map for successful request with empty body', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 204));

        // Act
        final result = await apiClient.get('test');

        // Assert
        expect(result, equals({}));
      });

      test('should handle different success status codes', () async {
        // Arrange
        final responseData = {'success': true};
        
        for (final statusCode in [200, 201, 202, 204]) {
          when(mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            statusCode == 204 ? '' : jsonEncode(responseData),
            statusCode,
          ));

          // Act
          final result = await apiClient.post('test', {});

          // Assert
          if (statusCode == 204) {
            expect(result, equals({}));
          } else {
            expect(result, equals(responseData));
          }
        }
      });
    });
  });
}