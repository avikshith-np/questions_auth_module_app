import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/question_auth.dart';

/// Test utilities and helper methods for authentication testing
class AuthTestUtils {
  /// Creates a valid SignUpRequest for testing
  static SignUpRequest createValidSignUpRequest({
    String email = 'test@example.com',
    String displayName = 'Test User',
    String password = 'password123',
    String? confirmPassword,
  }) {
    return SignUpRequest(
      email: email,
      displayName: displayName,
      password: password,
      confirmPassword: confirmPassword ?? password,
    );
  }

  /// Creates an invalid SignUpRequest for testing validation
  static SignUpRequest createInvalidSignUpRequest({
    String email = 'invalid-email',
    String displayName = '',
    String password = 'short',
    String confirmPassword = 'different',
  }) {
    return SignUpRequest(
      email: email,
      displayName: displayName,
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
    String email = 'test@example.com',
    String displayName = 'Test User',
    bool isActive = true,
    bool emailVerified = true,
    bool isVerified = true,
    bool isNew = false,
    DateTime? dateJoined,
  }) {
    return User(
      email: email,
      displayName: displayName,
      isActive: isActive,
      emailVerified: emailVerified,
      isVerified: isVerified,
      isNew: isNew,
      dateJoined: dateJoined ?? DateTime.parse('2023-01-01T00:00:00Z'),
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
    String? token,
    LoginResponse? loginData,
    SignUpResponse? signUpData,
  }) {
    return AuthResult(
      success: true,
      user: user ?? createTestUser(),
      token: token,
      loginData: loginData,
      signUpData: signUpData,
    );
  }

  /// Creates a successful AuthResult with login data for testing
  static AuthResult createLoginSuccessResult({
    User? user,
    String token = 'test-token-123',
    LoginResponse? loginData,
  }) {
    final testUser = user ?? createTestUser();
    final testLoginData = loginData ?? createTestLoginResponse(
      token: token,
      user: testUser,
    );
    
    return AuthResult(
      success: true,
      user: testUser,
      token: token,
      loginData: testLoginData,
    );
  }

  /// Creates a successful AuthResult with signup data for testing
  static AuthResult createSignUpSuccessResult({
    SignUpResponse? signUpData,
  }) {
    return AuthResult(
      success: true,
      signUpData: signUpData ?? createTestSignUpResponse(),
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
    String detail = 'Registration successful! Please check your email to verify your account.',
    String email = 'test@example.com',
    String verificationTokenExpiresIn = '10 minutes',
  }) {
    return {
      'detail': detail,
      'data': {
        'email': email,
        'verification_token_expires_in': verificationTokenExpiresIn,
      },
    };
  }

  /// Creates test API response data for successful login
  static Map<String, dynamic> createLoginApiResponse({
    String token = 'test-token-456',
    String email = 'test@example.com',
    String displayName = 'Test User',
    bool isVerified = true,
    bool isNew = false,
    List<String> roles = const ['Creator'],
    Map<String, bool> profileComplete = const {'creator': true, 'student': false},
    bool onboardingComplete = true,
    List<String> incompleteRoles = const [],
    String appAccess = 'full',
    String redirectTo = '/dashboard',
  }) {
    return {
      'token': token,
      'user': {
        'email': email,
        'display_name': displayName,
        'is_verified': isVerified,
        'is_new': isNew,
      },
      'roles': roles,
      'profile_complete': profileComplete,
      'onboarding_complete': onboardingComplete,
      'incomplete_roles': incompleteRoles,
      'app_access': appAccess,
      'redirect_to': redirectTo,
    };
  }

  /// Creates test API response data for user profile
  static Map<String, dynamic> createUserProfileApiResponse({
    String email = 'test@example.com',
    String displayName = 'Test User',
    bool isActive = true,
    bool emailVerified = true,
    String dateJoined = '2023-01-01T00:00:00Z',
    bool isNew = false,
    String mode = 'creator',
    List<String> roles = const ['creator'],
    List<String> availableRoles = const ['student'],
    List<String> removableRoles = const [],
    Map<String, bool> profileComplete = const {'creator': true, 'student': false},
    bool onboardingComplete = true,
    List<String> incompleteRoles = const [],
    String appAccess = 'full',
    String viewType = 'creator-complete-creator-only',
    String redirectTo = '/dashboard',
  }) {
    return {
      'user': {
        'email': email,
        'display_name': displayName,
        'is_active': isActive,
        'email_verified': emailVerified,
        'date_joined': dateJoined,
      },
      'is_new': isNew,
      'mode': mode,
      'roles': roles,
      'available_roles': availableRoles,
      'removable_roles': removableRoles,
      'profile_complete': profileComplete,
      'onboarding_complete': onboardingComplete,
      'incomplete_roles': incompleteRoles,
      'app_access': appAccess,
      'viewType': viewType,
      'redirect_to': redirectTo,
    };
  }

  /// Creates test API response data for logout
  static Map<String, dynamic> createLogoutApiResponse({
    String detail = 'Logged out successfully.',
  }) {
    return {
      'detail': detail,
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

  /// Creates a test SignUpResponse for testing
  static SignUpResponse createTestSignUpResponse({
    String detail = 'Registration successful! Please check your email to verify your account.',
    String email = 'test@example.com',
    String verificationTokenExpiresIn = '10 minutes',
  }) {
    return SignUpResponse(
      detail: detail,
      data: SignUpData(
        email: email,
        verificationTokenExpiresIn: verificationTokenExpiresIn,
      ),
    );
  }

  /// Creates a test LoginResponse for testing
  static LoginResponse createTestLoginResponse({
    String token = 'test-token-123',
    User? user,
    List<String> roles = const ['Creator'],
    Map<String, bool> profileComplete = const {'creator': true, 'student': false},
    bool onboardingComplete = true,
    List<String> incompleteRoles = const [],
    String appAccess = 'full',
    String redirectTo = '/dashboard',
  }) {
    return LoginResponse(
      token: token,
      user: user ?? createTestUser(),
      roles: roles,
      profileComplete: profileComplete,
      onboardingComplete: onboardingComplete,
      incompleteRoles: incompleteRoles,
      appAccess: appAccess,
      redirectTo: redirectTo,
    );
  }

  /// Creates a test UserProfileResponse for testing
  static UserProfileResponse createTestUserProfileResponse({
    User? user,
    bool isNew = false,
    String mode = 'creator',
    List<String> roles = const ['creator'],
    List<String> availableRoles = const ['student'],
    List<String> removableRoles = const [],
    Map<String, bool> profileComplete = const {'creator': true, 'student': false},
    bool onboardingComplete = true,
    List<String> incompleteRoles = const [],
    String appAccess = 'full',
    String viewType = 'creator-complete-creator-only',
    String redirectTo = '/dashboard',
  }) {
    return UserProfileResponse(
      user: user ?? createTestUser(),
      isNew: isNew,
      mode: mode,
      roles: roles,
      availableRoles: availableRoles,
      removableRoles: removableRoles,
      profileComplete: profileComplete,
      onboardingComplete: onboardingComplete,
      incompleteRoles: incompleteRoles,
      appAccess: appAccess,
      viewType: viewType,
      redirectTo: redirectTo,
    );
  }

  /// Creates a test LogoutResponse for testing
  static LogoutResponse createTestLogoutResponse({
    String detail = 'Logged out successfully.',
  }) {
    return LogoutResponse(detail: detail);
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