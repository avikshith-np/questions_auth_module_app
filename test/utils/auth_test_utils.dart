import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:question_auth/question_auth.dart';

/// Test utilities and helper methods for authentication testing
class AuthTestUtils {
  /// Creates a valid SignUpRequest for testing
  static SignUpRequest createValidSignUpRequest({
    String email = 'test@example.com',
    String username = 'testuser',
    String password = 'password123',
    String? confirmPassword,
  }) {
    return SignUpRequest(
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword ?? password,
    );
  }

  /// Creates an invalid SignUpRequest for testing validation
  static SignUpRequest createInvalidSignUpRequest({
    String email = 'invalid-email',
    String username = '',
    String password = 'short',
    String confirmPassword = 'different',
  }) {
    return SignUpRequest(
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  /// Creates a valid LoginRequest for testing
  static LoginRequest createValidLoginRequest({
    String email = 'test@example.com',
    String password = 'password123',
  }) {
    return LoginRequest(
      email: email,
      password: password,
    );
  }

  /// Creates an invalid LoginRequest for testing validation
  static LoginRequest createInvalidLoginRequest({
    String email = 'invalid-email',
    String password = '',
  }) {
    return LoginRequest(
      email: email,
      password: password,
    );
  }

  /// Creates a test User instance
  static User createTestUser({
    String id = '1',
    String email = 'test@example.com',
    String username = 'testuser',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      email: email,
      username: username,
      createdAt: createdAt ?? DateTime.parse('2023-01-01T00:00:00Z'),
      updatedAt: updatedAt ?? DateTime.parse('2023-01-01T00:00:00Z'),
    );
  }

  /// Creates a successful AuthResponse for testing
  static AuthResponse createSuccessResponse({
    String token = 'test-token-123',
    User? user,
    String message = 'Operation successful',
  }) {
    return AuthResponse(
      success: true,
      token: token,
      user: user ?? createTestUser(),
      message: message,
    );
  }

  /// Creates a failed AuthResponse for testing
  static AuthResponse createFailureResponse({
    String message = 'Operation failed',
  }) {
    return AuthResponse(
      success: false,
      message: message,
    );
  }

  /// Creates a successful AuthResult for testing
  static AuthResult createSuccessResult({
    User? user,
  }) {
    return AuthResult(
      success: true,
      user: user ?? createTestUser(),
    );
  }

  /// Creates a failed AuthResult for testing
  static AuthResult createFailureResult({
    String error = 'Authentication failed',
    Map<String, List<String>>? fieldErrors,
  }) {
    return AuthResult(
      success: false,
      error: error,
      fieldErrors: fieldErrors,
    );
  }

  /// Creates a validation error AuthResult for testing
  static AuthResult createValidationErrorResult({
    Map<String, List<String>>? fieldErrors,
  }) {
    return AuthResult(
      success: false,
      error: 'Validation failed',
      fieldErrors: fieldErrors ?? {
        'email': ['Invalid email format'],
        'password': ['Password is required'],
      },
    );
  }

  /// Creates an authenticated AuthState for testing
  static AuthState createAuthenticatedState({
    User? user,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user ?? createTestUser(),
    );
  }

  /// Creates an unauthenticated AuthState for testing
  static AuthState createUnauthenticatedState({
    String? error,
  }) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      error: error,
    );
  }

  /// Creates an unknown AuthState for testing
  static AuthState createUnknownState() {
    return const AuthState(
      status: AuthStatus.unknown,
    );
  }

  /// Creates test API response data for successful signup
  static Map<String, dynamic> createSignUpApiResponse({
    String token = 'test-token-123',
    String userId = '1',
    String email = 'test@example.com',
    String username = 'testuser',
    String message = 'Registration successful',
  }) {
    return {
      'success': true,
      'token': token,
      'user': {
        'id': userId,
        'email': email,
        'username': username,
        'created_at': '2023-01-01T00:00:00Z',
        'updated_at': '2023-01-01T00:00:00Z',
      },
      'message': message,
    };
  }

  /// Creates test API response data for successful login
  static Map<String, dynamic> createLoginApiResponse({
    String token = 'test-token-456',
    String userId = '1',
    String email = 'test@example.com',
    String username = 'testuser',
    String message = 'Login successful',
  }) {
    return {
      'success': true,
      'token': token,
      'user': {
        'id': userId,
        'email': email,
        'username': username,
        'created_at': '2023-01-01T00:00:00Z',
        'updated_at': '2023-01-01T00:00:00Z',
      },
      'message': message,
    };
  }

  /// Creates test API response data for user profile
  static Map<String, dynamic> createUserProfileApiResponse({
    String userId = '1',
    String email = 'test@example.com',
    String username = 'testuser',
  }) {
    return {
      'id': userId,
      'email': email,
      'username': username,
      'created_at': '2023-01-01T00:00:00Z',
      'updated_at': '2023-01-01T00:00:00Z',
    };
  }

  /// Creates test API error response data
  static Map<String, dynamic> createErrorApiResponse({
    String message = 'An error occurred',
    int statusCode = 400,
    String? code,
    Map<String, List<String>>? fieldErrors,
  }) {
    final response = <String, dynamic>{
      'success': false,
      'message': message,
      'status_code': statusCode,
    };

    if (code != null) {
      response['code'] = code;
    }

    if (fieldErrors != null) {
      response['errors'] = fieldErrors;
    }

    return response;
  }

  /// Creates a test AuthConfig for testing
  static AuthConfig createTestConfig({
    String baseUrl = 'https://api.test.com',
    String apiVersion = 'v1',
    Duration timeout = const Duration(seconds: 30),
    bool enableLogging = false,
    Map<String, String> defaultHeaders = const {},
  }) {
    return AuthConfig(
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      timeout: timeout,
      enableLogging: enableLogging,
      defaultHeaders: defaultHeaders,
    );
  }

  /// Waits for a stream to emit a specific value or times out
  static Future<T> waitForStreamValue<T>(
    Stream<T> stream,
    bool Function(T) predicate, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<T>();
    late StreamSubscription<T> subscription;

    subscription = stream.listen((value) {
      if (predicate(value)) {
        subscription.cancel();
        completer.complete(value);
      }
    });

    // Set up timeout
    Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(
          Exception('Stream did not emit expected value within $timeout'),
        );
      }
    });

    return completer.future;
  }

  /// Pumps the widget tree and waits for async operations
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pumpAndSettle();
  }

  /// Verifies that an exception of a specific type was thrown
  static void verifyException<T extends Exception>(
    dynamic exception,
    String expectedMessage, {
    bool exactMatch = false,
  }) {
    expect(exception, isA<T>());
    if (exactMatch) {
      expect(exception.toString(), equals(expectedMessage));
    } else {
      expect(exception.toString(), contains(expectedMessage));
    }
  }

  /// Verifies that a ValidationException contains specific field errors
  static void verifyValidationException(
    ValidationException exception,
    Map<String, List<String>> expectedFieldErrors,
  ) {
    expect(exception, isA<ValidationException>());
    expect(exception.fieldErrors, equals(expectedFieldErrors));
  }

  /// Verifies that an ApiException has the expected status code and message
  static void verifyApiException(
    ApiException exception,
    int expectedStatusCode,
    String expectedMessage, {
    String? expectedCode,
  }) {
    expect(exception, isA<ApiException>());
    expect(exception.statusCode, equals(expectedStatusCode));
    expect(exception.message, contains(expectedMessage));
    if (expectedCode != null) {
      expect(exception.code, equals(expectedCode));
    }
  }

  /// Creates a mock stream controller for testing reactive behavior
  static StreamController<T> createMockStreamController<T>() {
    return StreamController<T>.broadcast();
  }

  /// Disposes of a stream controller safely
  static Future<void> disposeMockStreamController<T>(
    StreamController<T> controller,
  ) async {
    if (!controller.isClosed) {
      await controller.close();
    }
  }
}