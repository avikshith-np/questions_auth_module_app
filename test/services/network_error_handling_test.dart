import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:question_auth/src/services/api_client.dart';
import 'package:question_auth/src/core/exceptions.dart';

import 'network_error_handling_test.mocks.dart';

@GenerateMocks([http.Client, Connectivity])
void main() {
  group('HttpApiClient Network Error Handling', () {
    late MockClient mockClient;
    late MockConnectivity mockConnectivity;
    late HttpApiClient apiClient;
    const baseUrl = 'https://api.example.com';

    setUp(() {
      mockClient = MockClient();
      mockConnectivity = MockConnectivity();
      apiClient = HttpApiClient(
        baseUrl: baseUrl,
        client: mockClient,
        timeout: const Duration(seconds: 2),
        maxRetries: 2,
        retryDelay: const Duration(milliseconds: 100),
        connectivity: mockConnectivity,
      );
    });

    tearDown(() {
      apiClient.dispose();
    });

    group('Connectivity checking', () {
      test('should check connectivity before making request', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await apiClient.post('test', {});

        // Assert
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('should throw ConnectivityException when offline', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<ConnectivityException>()
              .having((e) => e.message, 'message', 
                      contains('No internet connection available'))),
        );
        
        // Verify that HTTP request was not made
        verifyNever(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')));
      });

      test('should continue with request if connectivity check fails', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenThrow(Exception('Connectivity check failed'));
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('{}', 200));

        // Act
        final result = await apiClient.post('test', {});

        // Assert
        expect(result, equals({}));
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });
    });

    group('Retry mechanisms', () {
      test('should retry on SocketException with connection refused', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        
        var callCount = 0;
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          callCount++;
          if (callCount <= 2) {
            throw const SocketException('Connection refused');
          }
          return http.Response('{"success": true}', 200);
        });

        // Act
        final result = await apiClient.post('test', {});

        // Assert
        expect(result, equals({'success': true}));
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(3);
        verify(mockConnectivity.checkConnectivity()).called(3); // Initial + 2 retries
      });

      test('should retry on TimeoutException', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        
        var callCount = 0;
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async {
          callCount++;
          if (callCount <= 1) {
            throw const TimeoutException('Request timeout');
          }
          return http.Response('{"data": "success"}', 200);
        });

        // Act
        final result = await apiClient.get('test');

        // Assert
        expect(result, equals({'data': 'success'}));
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(2);
      });

      test('should retry on server errors (5xx)', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        
        var callCount = 0;
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          callCount++;
          if (callCount <= 1) {
            return http.Response('Internal Server Error', 500);
          }
          return http.Response('{"success": true}', 200);
        });

        // Act
        final result = await apiClient.post('test', {});

        // Assert
        expect(result, equals({'success': true}));
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(2);
      });

      test('should not retry on client errors (4xx)', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Bad Request', 400));

        // Act & Assert
        try {
          await apiClient.post('test', {});
          fail('Expected ApiException to be thrown');
        } catch (e) {
          expect(e, isA<ApiException>());
          expect((e as ApiException).statusCode, equals(400));
        }
        
        // Verify that only one HTTP call was made (no retries)
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });

      test('should not retry on FormatException', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const FormatException('Invalid format'));

        // Act & Assert
        try {
          await apiClient.post('test', {});
          fail('Expected NetworkException to be thrown');
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(e.toString(), contains('Invalid response format'));
        }
        
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });

      test('should not retry on AuthException', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Unauthorized', 401));

        // Act & Assert
        try {
          await apiClient.post('test', {});
          fail('Expected ApiException to be thrown');
        } catch (e) {
          expect(e, isA<ApiException>());
          expect((e as ApiException).statusCode, equals(401));
        }
        
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });

      test('should use exponential backoff for retries', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        
        final stopwatch = Stopwatch()..start();
        var callCount = 0;
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          callCount++;
          if (callCount <= 2) {
            throw const SocketException('Connection refused');
          }
          return http.Response('{"success": true}', 200);
        });

        // Act
        await apiClient.post('test', {});
        stopwatch.stop();

        // Assert - Should have delays of 100ms and 200ms (exponential backoff)
        // Total minimum delay should be around 300ms
        expect(stopwatch.elapsedMilliseconds, greaterThan(250));
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(3);
      });

      test('should fail after max retries exceeded', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const SocketException('Connection refused'));

        // Act & Assert
        try {
          await apiClient.post('test', {});
          fail('Expected NetworkException to be thrown');
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(e.toString(), contains('Network connection failed'));
        }
        
        // Should try initial + 2 retries = 3 total attempts
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(3);
      });
    });

    group('Socket exception handling', () {
      test('should retry on retryable socket exceptions', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        
        final retryableExceptions = [
          'Connection refused',
          'Connection timed out',
          'Network is unreachable',
          'Host is unreachable',
          'Connection reset by peer',
          'Broken pipe',
        ];

        for (final exceptionMessage in retryableExceptions) {
          var callCount = 0;
          when(mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer((_) async {
            callCount++;
            if (callCount <= 1) {
              throw SocketException(exceptionMessage);
            }
            return http.Response('{"success": true}', 200);
          });

          // Act
          final result = await apiClient.post('test', {});

          // Assert
          expect(result, equals({'success': true}));
          verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(2);
          
          // Reset for next test
          reset(mockClient);
          reset(mockConnectivity);
          when(mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => ConnectivityResult.wifi);
        }
      });

      test('should not retry on non-retryable socket exceptions', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const SocketException('Permission denied'));

        // Act & Assert
        try {
          await apiClient.post('test', {});
          fail('Expected NetworkException to be thrown');
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect(e.toString(), contains('Network connection failed'));
        }
        
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });
    });

    group('Timeout handling', () {
      test('should throw TimeoutException on request timeout', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 5));
          return http.Response('{}', 200);
        });

        // Act & Assert
        try {
          await apiClient.post('test', {});
          fail('Expected TimeoutException to be thrown');
        } catch (e) {
          expect(e, isA<TimeoutException>());
          expect(e.toString(), contains('Request timed out after 2 seconds'));
        }
      });

      test('should handle 504 Gateway Timeout as TimeoutException', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Gateway Timeout', 504));

        // Act & Assert
        try {
          await apiClient.get('test');
          fail('Expected TimeoutException to be thrown');
        } catch (e) {
          expect(e, isA<TimeoutException>());
          expect(e.toString(), contains('Server response timeout'));
        }
      });
    });

    group('Complex retry scenarios', () {
      test('should handle mixed error types during retries', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        
        var callCount = 0;
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          callCount++;
          switch (callCount) {
            case 1:
              throw const SocketException('Connection refused');
            case 2:
              return http.Response('Internal Server Error', 500);
            case 3:
              return http.Response('{"success": true}', 200);
            default:
              throw Exception('Unexpected call');
          }
        });

        // Act
        final result = await apiClient.post('test', {});

        // Assert
        expect(result, equals({'success': true}));
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(3);
      });

      test('should re-check connectivity on socket exception retry', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        
        var callCount = 0;
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          callCount++;
          if (callCount <= 1) {
            throw const SocketException('Connection refused');
          }
          return http.Response('{"success": true}', 200);
        });

        // Act
        await apiClient.post('test', {});

        // Assert
        // Should check connectivity: initial + 1 retry = 2 times
        verify(mockConnectivity.checkConnectivity()).called(2);
      });

      test('should handle connectivity loss during retry', () async {
        // Arrange
        var connectivityCallCount = 0;
        when(mockConnectivity.checkConnectivity()).thenAnswer((_) async {
          connectivityCallCount++;
          if (connectivityCallCount == 1) {
            return ConnectivityResult.wifi;
          } else {
            return ConnectivityResult.none; // Lost connectivity on retry
          }
        });
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const SocketException('Connection refused'));

        // Act & Assert
        try {
          await apiClient.post('test', {});
          fail('Expected ConnectivityException to be thrown');
        } catch (e) {
          expect(e, isA<ConnectivityException>());
        }
        
        // Should check connectivity twice: initial + retry
        verify(mockConnectivity.checkConnectivity()).called(2);
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });
    });

    group('Error message handling', () {
      test('should provide user-friendly timeout messages', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          // Simulate a timeout by throwing a TimeoutException that will be caught and reformatted
          throw async.TimeoutException('Future not completed', const Duration(seconds: 2));
        });

        // Act & Assert
        try {
          await apiClient.post('test', {});
          fail('Expected TimeoutException to be thrown');
        } catch (e) {
          expect(e, isA<TimeoutException>());
          expect(e.toString(), contains('Request timed out after 2 seconds'));
        }
      });

      test('should provide user-friendly connectivity messages', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<ConnectivityException>()
              .having((e) => e.message, 'message', contains('No internet connection available'))),
        );
      });

      test('should preserve original error messages for network exceptions', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const SocketException('Custom socket error message'));

        // Act & Assert
        expect(
          () => apiClient.post('test', {}),
          throwsA(isA<NetworkException>()
              .having((e) => e.message, 'message', contains('Custom socket error message'))),
        );
      });
    });

    group('Configuration options', () {
      test('should respect custom retry configuration', () async {
        // Arrange
        final customClient = HttpApiClient(
          baseUrl: baseUrl,
          client: mockClient,
          maxRetries: 1,
          retryDelay: const Duration(milliseconds: 50),
          connectivity: mockConnectivity,
        );

        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const SocketException('Connection refused'));

        // Act & Assert
        try {
          await customClient.post('test', {});
          fail('Expected NetworkException to be thrown');
        } catch (e) {
          expect(e, isA<NetworkException>());
        }
        
        // Should try initial + 1 retry = 2 total attempts
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(2);
        
        customClient.dispose();
      });

      test('should work with zero retries', () async {
        // Arrange
        final noRetryClient = HttpApiClient(
          baseUrl: baseUrl,
          client: mockClient,
          maxRetries: 0,
          connectivity: mockConnectivity,
        );

        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const SocketException('Connection refused'));

        // Act & Assert
        try {
          await noRetryClient.post('test', {});
          fail('Expected NetworkException to be thrown');
        } catch (e) {
          expect(e, isA<NetworkException>());
        }
        
        // Should try only once
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
        
        noRetryClient.dispose();
      });
    });
  });
}