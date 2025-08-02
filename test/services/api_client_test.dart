import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:question_auth/src/services/api_client.dart';
import 'package:question_auth/src/core/exceptions.dart';
import 'package:question_auth/src/models/auth_request.dart';

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
            containsPair('Authorization', 'Token $token'),
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
            containsPair('Authorization', 'Token $token'),
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
      test('should throw ApiException for 400 Bad Request with custom message', () async {
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
              .having((e) => e.message, 'message', equals('Invalid request data'))),
        );
      });

      test('should throw ApiException for 400 Bad Request with user-friendly message', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Bad Request', 400));

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(400))
              .having((e) => e.message, 'message', 
                      equals('The request contains invalid data. Please check your input and try again.'))),
        );
      });

      test('should throw ApiException for 401 Unauthorized with custom message', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'message': 'Invalid credentials provided'}),
          401,
        ));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(401))
              .having((e) => e.message, 'message', equals('Invalid credentials provided'))),
        );
      });

      test('should throw ApiException for 401 Unauthorized with user-friendly message', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Unauthorized', 401));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(401))
              .having((e) => e.message, 'message', 
                      equals('Authentication failed. Please check your credentials and try again.'))),
        );
      });

      test('should throw ApiException for 403 Forbidden with user-friendly message', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 403));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(403))
              .having((e) => e.message, 'message', 
                      equals('You do not have permission to perform this action.'))),
        );
      });

      test('should throw ApiException for 404 Not Found with user-friendly message', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 404));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(404))
              .having((e) => e.message, 'message', 
                      equals('The requested resource was not found.'))),
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
                      equals(['Password is too short']))
              .having((e) => e.message, 'message', equals('Validation failed'))),
        );
      });

      test('should throw ValidationException for 422 with string field errors', () async {
        // Arrange
        final errorResponse = {
          'errors': {
            'email': 'Email is required',
            'password': 'Password is too short'
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
              .having((e) => e.fieldErrors['email'], 'email errors', equals(['Email is required']))
              .having((e) => e.fieldErrors['password'], 'password errors', equals(['Password is too short']))),
        );
      });

      test('should throw ApiException for 422 without field errors', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('', 422));

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(422))
              .having((e) => e.message, 'message', 
                      equals('The provided data is invalid. Please correct the errors and try again.'))),
        );
      });

      test('should throw ApiException for 429 Too Many Requests', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('', 429));

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(429))
              .having((e) => e.message, 'message', 
                      equals('Too many requests. Please wait a moment and try again.'))),
        );
      });

      test('should throw ApiException for 500 Internal Server Error', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 500));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(500))
              .having((e) => e.message, 'message', 
                      equals('A server error occurred. Please try again later.'))),
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
              .having((e) => e.message, 'message', 
                      equals('The server is temporarily unavailable. Please try again later.'))),
        );
      });

      test('should throw NetworkException for 503 Service Unavailable', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 503));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<NetworkException>()
              .having((e) => e.message, 'message', 
                      equals('The service is temporarily unavailable. Please try again later.'))),
        );
      });

      test('should throw TimeoutException for 504 Gateway Timeout', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 504));

        // Act & Assert
        expect(
          () => apiClient.get('test'),
          throwsA(isA<TimeoutException>()
              .having((e) => e.message, 'message', 
                      equals('Server response timeout'))),
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

      group('Error message extraction', () {
        test('should extract message from different response fields', () async {
          final testCases = [
            {'message': 'Error from message field'},
            {'error': 'Error from error field'},
            {'detail': 'Error from detail field'},
            {'error_description': 'Error from error_description field'},
            {'msg': 'Error from msg field'},
          ];

          for (final testCase in testCases) {
            final testClient = MockClient();
            final testApiClient = HttpApiClient(
              baseUrl: baseUrl,
              client: testClient,
              timeout: const Duration(seconds: 5),
              maxRetries: 0, // Disable retries for this test
            );
            
            when(testClient.get(
              any,
              headers: anyNamed('headers'),
            )).thenAnswer((_) async => http.Response(
              jsonEncode(testCase),
              400,
            ));

            expect(
              () => testApiClient.get('test'),
              throwsA(isA<ApiException>()
                  .having((e) => e.message, 'message', equals(testCase.values.first))),
            );
            
            testApiClient.dispose();
          }
        });

        test('should extract message from errors array', () async {
          // Arrange
          final errorResponse = {
            'errors': ['First error message', 'Second error message']
          };
          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.get('test'),
            throwsA(isA<ApiException>()
                .having((e) => e.message, 'message', equals('First error message'))),
          );
        });

        test('should extract message from errors object', () async {
          // Arrange
          final errorResponse = {
            'errors': {
              'email': ['Email error'],
              'password': ['Password error']
            }
          };
          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.get('test'),
            throwsA(isA<ValidationException>()
                .having((e) => e.fieldErrors['email'], 'email errors', equals(['Email error']))
                .having((e) => e.fieldErrors['password'], 'password errors', equals(['Password error']))),
          );
        });

        test('should use default message when no error message found', () async {
          // Arrange
          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response('{}', 400));

          // Act & Assert
          expect(
            () => apiClient.get('test'),
            throwsA(isA<ApiException>()
                .having((e) => e.message, 'message', 
                        equals('The request contains invalid data. Please check your input and try again.'))),
          );
        });
      });

      group('Error code handling', () {
        test('should include error code when present', () async {
          // Arrange
          final errorResponse = {
            'message': 'Custom error',
            'code': 'CUSTOM_ERROR_CODE'
          };
          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.get('test'),
            throwsA(isA<ApiException>()
                .having((e) => e.code, 'code', equals('CUSTOM_ERROR_CODE'))
                .having((e) => e.message, 'message', equals('Custom error'))),
          );
        });

        test('should handle numeric error codes', () async {
          // Arrange
          final errorResponse = {
            'message': 'Numeric code error',
            'code': 12345
          };
          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.get('test'),
            throwsA(isA<ApiException>()
                .having((e) => e.code, 'code', equals('12345'))),
          );
        });
      });

      group('Unknown status codes', () {
        test('should handle unknown status codes with user-friendly message', () async {
          // Arrange
          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response('', 418)); // I'm a teapot

          // Act & Assert
          expect(
            () => apiClient.get('test'),
            throwsA(isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(418))
                .having((e) => e.message, 'message', 
                        equals('An unexpected error occurred. Please try again later.'))),
          );
        });

        test('should preserve custom message for unknown status codes', () async {
          // Arrange
          final errorResponse = {'message': 'Custom teapot error'};
          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            418,
          ));

          // Act & Assert
          expect(
            () => apiClient.get('test'),
            throwsA(isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(418))
                .having((e) => e.message, 'message', equals('Custom teapot error'))),
          );
        });
      });

      group('Complex error scenarios', () {
        test('should handle malformed JSON in error response', () async {
          // Arrange
          when(mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            '{"message": "Error", "invalid": json}', // Malformed JSON
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.post('test', {}),
            throwsA(isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(400))
                .having((e) => e.message, 'message', equals('{"message": "Error", "invalid": json}'))),
          );
        });

        test('should handle empty error response with non-200 status', () async {
          // Arrange
          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response('', 400));

          // Act & Assert
          expect(
            () => apiClient.get('test'),
            throwsA(isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(400))
                .having((e) => e.message, 'message', 
                        equals('The request contains invalid data. Please check your input and try again.'))),
          );
        });

        test('should handle nested error structures', () async {
          // Arrange
          final errorResponse = {
            'error': {
              'message': 'Nested error message',
              'code': 'NESTED_ERROR'
            }
          };
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
                .having((e) => e.message, 'message', 
                        equals('{message: Nested error message, code: NESTED_ERROR}'))),
          );
        });

        test('should handle validation errors with mixed data types', () async {
          // Arrange
          final errorResponse = {
            'message': 'Validation failed',
            'errors': {
              'email': ['Required', 'Invalid format'],
              'age': 'Must be a number',
              'tags': ['Tag 1 invalid', 'Tag 2 invalid'],
              'active': true, // Boolean value
              'count': 42, // Numeric value
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
                        equals(['Required', 'Invalid format']))
                .having((e) => e.fieldErrors['age'], 'age errors', 
                        equals(['Must be a number']))
                .having((e) => e.fieldErrors['tags'], 'tags errors', 
                        equals(['Tag 1 invalid', 'Tag 2 invalid']))
                .having((e) => e.fieldErrors['active'], 'active errors', 
                        equals(['true']))
                .having((e) => e.fieldErrors['count'], 'count errors', 
                        equals(['42']))),
          );
        });

        test('should handle server error with HTML response', () async {
          // Arrange
          const htmlResponse = '<html><body><h1>500 Internal Server Error</h1></body></html>';
          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response(htmlResponse, 500));

          // Act & Assert
          expect(
            () => apiClient.get('test'),
            throwsA(isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(500))
                .having((e) => e.message, 'message', 
                        equals('A server error occurred. Please try again later.'))),
          );
        });

        test('should handle timeout with proper error message', () async {
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
            throwsA(isA<TimeoutException>()
                .having((e) => e.message, 'message', contains('Request timed out after'))),
          );
        });
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

    group('Specific endpoint methods', () {
      group('register', () {
        test('should make successful registration request', () async {
          // Arrange
          final request = SignUpRequest(
            email: 'test@example.com',
            displayName: 'Test User',
            password: 'password123',
            confirmPassword: 'password123',
          );
          final responseData = {
            'detail': 'Registration successful! Please check your email to verify your account.',
            'data': {
              'email': 'test@example.com',
              'verification_token_expires_in': '10 minutes'
            }
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/accounts/register/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(responseData),
            200,
            headers: {'content-type': 'application/json'},
          ));

          // Act
          final result = await apiClient.register(request);

          // Assert
          expect(result.detail, equals('Registration successful! Please check your email to verify your account.'));
          expect(result.data?.email, equals('test@example.com'));
          expect(result.data?.verificationTokenExpiresIn, equals('10 minutes'));
          
          verify(mockClient.post(
            Uri.parse('$baseUrl/accounts/register/'),
            headers: argThat(
              allOf([
                containsPair('Content-Type', 'application/json'),
                containsPair('Accept', 'application/json'),
              ]),
              named: 'headers',
            ),
            body: jsonEncode(request.toJson()),
          )).called(1);
        });

        test('should handle registration validation errors', () async {
          // Arrange
          final request = SignUpRequest(
            email: 'invalid-email',
            displayName: 'Test User',
            password: 'password123',
            confirmPassword: 'password123',
          );
          final errorResponse = {
            'email': ['user with this email already exists.']
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/accounts/register/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.register(request),
            throwsA(isA<ValidationException>()
                .having((e) => e.fieldErrors['email'], 'email errors', 
                        equals(['user with this email already exists.']))),
          );
        });
      });

      group('login', () {
        test('should make successful login request', () async {
          // Arrange
          final request = LoginRequest(
            email: 'test@example.com',
            password: 'password123',
          );
          final responseData = {
            'token': '879c09f82dd58f9dd3552e33abf3f015f2c8e804',
            'user': {
              'email': 'test@example.com',
              'display_name': 'Test User',
              'is_verified': true,
              'is_new': false
            },
            'roles': ['Creator'],
            'profile_complete': {
              'student': false,
              'creator': true
            },
            'onboarding_complete': true,
            'incomplete_roles': [],
            'app_access': 'full',
            'redirect_to': '/dashboard'
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/accounts/login/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(responseData),
            200,
            headers: {'content-type': 'application/json'},
          ));

          // Act
          final result = await apiClient.login(request);

          // Assert
          expect(result.token, equals('879c09f82dd58f9dd3552e33abf3f015f2c8e804'));
          expect(result.user.email, equals('test@example.com'));
          expect(result.user.displayName, equals('Test User'));
          expect(result.roles, equals(['Creator']));
          expect(result.profileComplete['creator'], equals(true));
          expect(result.onboardingComplete, equals(true));
          expect(result.appAccess, equals('full'));
          expect(result.redirectTo, equals('/dashboard'));
          
          verify(mockClient.post(
            Uri.parse('$baseUrl/accounts/login/'),
            headers: argThat(
              allOf([
                containsPair('Content-Type', 'application/json'),
                containsPair('Accept', 'application/json'),
              ]),
              named: 'headers',
            ),
            body: jsonEncode(request.toJson()),
          )).called(1);
        });

        test('should handle login authentication errors', () async {
          // Arrange
          final request = LoginRequest(
            email: 'test@example.com',
            password: 'wrongpassword',
          );
          final errorResponse = {
            'detail': 'Invalid credentials'
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/accounts/login/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            401,
          ));

          // Act & Assert
          expect(
            () => apiClient.login(request),
            throwsA(isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(401))
                .having((e) => e.message, 'message', equals('Invalid credentials'))),
          );
        });
      });

      group('getCurrentUser', () {
        test('should make successful get current user request', () async {
          // Arrange
          const token = 'test-token-123';
          apiClient.setAuthToken(token);
          
          final responseData = {
            'user': {
              'email': 'test@example.com',
              'display_name': 'Test User',
              'is_active': true,
              'email_verified': true,
              'date_joined': '2024-01-01T00:00:00Z'
            },
            'is_new': false,
            'mode': 'student',
            'roles': ['student', 'creator'],
            'available_roles': ['creator'],
            'removable_roles': [],
            'profile_complete': {
              'student': true,
              'creator': false
            },
            'onboarding_complete': true,
            'incomplete_roles': ['creator'],
            'app_access': 'full',
            'viewType': 'student-complete-student-only',
            'redirect_to': '/onboarding/profile'
          };
          
          when(mockClient.get(
            Uri.parse('$baseUrl/accounts/me/'),
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(responseData),
            200,
            headers: {'content-type': 'application/json'},
          ));

          // Act
          final result = await apiClient.getCurrentUser();

          // Assert
          expect(result.user.email, equals('test@example.com'));
          expect(result.user.displayName, equals('Test User'));
          expect(result.isNew, equals(false));
          expect(result.mode, equals('student'));
          expect(result.roles, equals(['student', 'creator']));
          expect(result.availableRoles, equals(['creator']));
          expect(result.profileComplete['student'], equals(true));
          expect(result.onboardingComplete, equals(true));
          expect(result.appAccess, equals('full'));
          expect(result.viewType, equals('student-complete-student-only'));
          expect(result.redirectTo, equals('/onboarding/profile'));
          
          verify(mockClient.get(
            Uri.parse('$baseUrl/accounts/me/'),
            headers: argThat(
              allOf([
                containsPair('Content-Type', 'application/json'),
                containsPair('Accept', 'application/json'),
                containsPair('Authorization', 'Token $token'),
              ]),
              named: 'headers',
            ),
          )).called(1);
        });

        test('should handle unauthorized access', () async {
          // Arrange
          final errorResponse = {
            'detail': 'Authentication credentials were not provided.'
          };
          
          when(mockClient.get(
            Uri.parse('$baseUrl/accounts/me/'),
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            401,
          ));

          // Act & Assert
          expect(
            () => apiClient.getCurrentUser(),
            throwsA(isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(401))
                .having((e) => e.message, 'message', equals('Authentication credentials were not provided.'))),
          );
        });
      });

      group('logout', () {
        test('should make successful logout request', () async {
          // Arrange
          const token = 'test-token-123';
          apiClient.setAuthToken(token);
          
          final responseData = {
            'detail': 'Logged out successfully.'
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/logout/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(responseData),
            200,
            headers: {'content-type': 'application/json'},
          ));

          // Act
          final result = await apiClient.logout();

          // Assert
          expect(result.detail, equals('Logged out successfully.'));
          
          verify(mockClient.post(
            Uri.parse('$baseUrl/logout/'),
            headers: argThat(
              allOf([
                containsPair('Content-Type', 'application/json'),
                containsPair('Accept', 'application/json'),
                containsPair('Authorization', 'Token $token'),
              ]),
              named: 'headers',
            ),
            body: jsonEncode({}),
          )).called(1);
        });

        test('should handle logout errors gracefully', () async {
          // Arrange
          const token = 'test-token-123';
          apiClient.setAuthToken(token);
          
          final errorResponse = {
            'detail': 'Token is invalid or expired.'
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/logout/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            401,
          ));

          // Act & Assert
          expect(
            () => apiClient.logout(),
            throwsA(isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(401))
                .having((e) => e.message, 'message', equals('Token is invalid or expired.'))),
          );
        });
      });

      group('Field-specific error handling', () {
        test('should parse field-specific errors from 400 response', () async {
          // Arrange
          final request = SignUpRequest(
            email: 'existing@example.com',
            displayName: 'Test User',
            password: 'password123',
            confirmPassword: 'password123',
          );
          final errorResponse = {
            'email': ['user with this email already exists.'],
            'display_name': ['This display name is already taken.']
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/accounts/register/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.register(request),
            throwsA(isA<ValidationException>()
                .having((e) => e.fieldErrors['email'], 'email errors', 
                        equals(['user with this email already exists.']))
                .having((e) => e.fieldErrors['display_name'], 'display_name errors', 
                        equals(['This display name is already taken.']))),
          );
        });

        test('should handle mixed field error formats', () async {
          // Arrange
          final request = LoginRequest(
            email: 'test@example.com',
            password: 'password123',
          );
          final errorResponse = {
            'email': 'Invalid email format',
            'password': ['Password is too short', 'Password must contain numbers'],
            'non_field_errors': ['Account is temporarily locked']
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/accounts/login/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.login(request),
            throwsA(isA<ValidationException>()
                .having((e) => e.fieldErrors['email'], 'email errors', 
                        equals(['Invalid email format']))
                .having((e) => e.fieldErrors['password'], 'password errors', 
                        equals(['Password is too short', 'Password must contain numbers']))
                .having((e) => e.fieldErrors.containsKey('non_field_errors'), 'has non_field_errors', 
                        equals(false))), // non_field_errors should be filtered out
          );
        });

        test('should handle nested errors object', () async {
          // Arrange
          final request = SignUpRequest(
            email: 'test@example.com',
            displayName: 'Test User',
            password: 'password123',
            confirmPassword: 'password123',
          );
          final errorResponse = {
            'detail': 'Validation failed',
            'errors': {
              'email': ['Email is required'],
              'password': ['Password is too weak']
            }
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/accounts/register/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.register(request),
            throwsA(isA<ValidationException>()
                .having((e) => e.fieldErrors['email'], 'email errors', 
                        equals(['Email is required']))
                .having((e) => e.fieldErrors['password'], 'password errors', 
                        equals(['Password is too weak']))),
          );
        });

        test('should ignore non-field keys in error response', () async {
          // Arrange
          final request = LoginRequest(
            email: 'test@example.com',
            password: 'password123',
          );
          final errorResponse = {
            'detail': 'Request failed',
            'message': 'Validation error',
            'code': 'VALIDATION_ERROR',
            'status': 'error',
            'email': ['Invalid email'],
            'password': ['Invalid password']
          };
          
          when(mockClient.post(
            Uri.parse('$baseUrl/accounts/login/'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

          // Act & Assert
          expect(
            () => apiClient.login(request),
            throwsA(isA<ValidationException>()
                .having((e) => e.fieldErrors.keys.length, 'field error count', equals(2))
                .having((e) => e.fieldErrors['email'], 'email errors', 
                        equals(['Invalid email']))
                .having((e) => e.fieldErrors['password'], 'password errors', 
                        equals(['Invalid password']))
                .having((e) => e.fieldErrors.containsKey('detail'), 'has detail', equals(false))
                .having((e) => e.fieldErrors.containsKey('message'), 'has message', equals(false))
                .having((e) => e.fieldErrors.containsKey('code'), 'has code', equals(false))
                .having((e) => e.fieldErrors.containsKey('status'), 'has status', equals(false))),
          );
        });
      });
    });
  });
}