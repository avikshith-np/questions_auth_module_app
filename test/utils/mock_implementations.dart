import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:question_auth/question_auth.dart';
import 'package:question_auth/src/services/api_client.dart';
import 'auth_test_utils.dart';

/// Mock implementation of AuthService for testing
class MockAuthService extends Mock implements AuthService {
  final StreamController<AuthState> _authStateController = 
      StreamController<AuthState>.broadcast();
  
  AuthState _currentState = const AuthState(status: AuthStatus.unknown);
  
  @override
  Stream<AuthState> get authStateStream => _authStateController.stream;
  
  @override
  bool get isAuthenticated => _currentState.status == AuthStatus.authenticated;
  
  @override
  User? get currentUser => _currentState.user;
  
  @override
  AuthState get currentAuthState => _currentState;
  
  /// Helper method to simulate state changes in tests
  void simulateStateChange(AuthState newState) {
    _currentState = newState;
    _authStateController.add(newState);
  }
  
  /// Helper method to simulate authentication
  void simulateAuthentication(User user) {
    simulateStateChange(AuthState(
      status: AuthStatus.authenticated,
      user: user,
    ));
  }
  
  /// Helper method to simulate logout
  void simulateLogout() {
    simulateStateChange(const AuthState(
      status: AuthStatus.unauthenticated,
    ));
  }
  
  /// Dispose method for cleanup
  void dispose() {
    _authStateController.close();
  }
}

/// Mock implementation of AuthRepository for testing
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<AuthResponse> signUp(SignUpRequest request) async {
    // Default successful response - can be overridden with when() in tests
    return AuthTestUtils.createSuccessResponse();
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    // Default successful response - can be overridden with when() in tests
    return AuthTestUtils.createSuccessResponse();
  }

  @override
  Future<User> getCurrentUser() async {
    // Default user response - can be overridden with when() in tests
    return AuthTestUtils.createTestUser();
  }

  @override
  Future<void> logout() async {
    // Default empty implementation - can be overridden with when() in tests
  }
  
  @override
  Future<bool> hasStoredToken() async {
    // Default false - can be overridden with when() in tests
    return false;
  }
  
  @override
  Future<bool> isTokenExpired() async {
    // Default false - can be overridden with when() in tests
    return false;
  }
  
  @override
  Future<void> clearExpiredToken() async {
    // Default empty implementation - can be overridden with when() in tests
  }
}

/// Mock implementation of ApiClient for testing
class MockApiClient extends Mock implements ApiClient {
  @override
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    // Default empty response - should be overridden with when() in tests
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    // Default empty response - should be overridden with when() in tests
    return <String, dynamic>{};
  }

  @override
  void setAuthToken(String token) {
    // Mock implementation - behavior can be verified in tests
  }

  @override
  void clearAuthToken() {
    // Mock implementation - behavior can be verified in tests
  }
}

/// Mock implementation of TokenManager for testing
class MockTokenManager extends Mock implements TokenManager {
  String? _storedToken;
  
  @override
  Future<void> saveToken(String token) async {
    _storedToken = token;
  }

  @override
  Future<String?> getToken() async {
    return _storedToken;
  }

  @override
  Future<void> clearToken() async {
    _storedToken = null;
  }

  @override
  Future<bool> hasValidToken() async {
    return _storedToken != null && _storedToken!.isNotEmpty;
  }
  
  @override
  Future<bool> isTokenExpired() async {
    return _storedToken == null;
  }
  
  @override
  Future<DateTime?> getTokenExpiration() async {
    return null;
  }
  
  /// Helper method to check stored token in tests
  String? get storedToken => _storedToken;
  
  /// Helper method to simulate token in tests
  void simulateToken(String? token) {
    _storedToken = token;
  }
}

/// Mock implementation of FlutterSecureStorage for testing
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {
  final Map<String, String> _storage = {};
  
  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_storage);
  }
  
  /// Helper method to check stored values in tests
  Map<String, String> get storage => Map.from(_storage);
  
  /// Helper method to clear storage in tests
  void clearStorage() {
    _storage.clear();
  }
}

/// Mock implementation that always throws network errors
class NetworkErrorMockApiClient extends Mock implements ApiClient {
  @override
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    throw NetworkException('Network connection failed');
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    throw NetworkException('Network connection failed');
  }

  @override
  void setAuthToken(String token) {}

  @override
  void clearAuthToken() {}
}

/// Mock implementation that always throws API errors
class ApiErrorMockApiClient extends Mock implements ApiClient {
  final int statusCode;
  final String message;
  final String? code;
  
  ApiErrorMockApiClient({
    this.statusCode = 400,
    this.message = 'API Error',
    this.code,
  });

  @override
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    throw ApiException(message, statusCode, code);
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    throw ApiException(message, statusCode, code);
  }

  @override
  void setAuthToken(String token) {}

  @override
  void clearAuthToken() {}
}

/// Mock implementation that always throws token errors
class TokenErrorMockTokenManager extends Mock implements TokenManager {
  @override
  Future<void> saveToken(String token) async {
    throw TokenException('Failed to save token');
  }

  @override
  Future<String?> getToken() async {
    throw TokenException('Failed to retrieve token');
  }

  @override
  Future<void> clearToken() async {
    throw TokenException('Failed to clear token');
  }

  @override
  Future<bool> hasValidToken() async {
    throw TokenException('Failed to check token validity');
  }
}

/// Mock repository that always throws validation errors
class ValidationErrorMockRepository extends Mock implements AuthRepository {
  @override
  Future<AuthResponse> signUp(SignUpRequest request) async {
    throw ValidationException('Validation failed', {
      'email': ['Invalid email format'],
      'password': ['Password too short'],
    });
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    throw ValidationException('Validation failed', {
      'email': ['Invalid email format'],
    });
  }

  @override
  Future<User> getCurrentUser() async {
    throw ValidationException('Validation failed', {
      'token': ['Invalid token'],
    });
  }

  @override
  Future<void> logout() async {
    throw ValidationException('Validation failed', {
      'token': ['Invalid token'],
    });
  }
}

/// Mock API client that always returns successful responses
class SuccessfulMockApiClient extends Mock implements ApiClient {
  @override
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    switch (endpoint) {
      case 'accounts/signup/':
        return AuthTestUtils.createSignUpApiResponse();
      case 'accounts/login/':
        return AuthTestUtils.createLoginApiResponse();
      case 'logout/':
        return {'success': true};
      default:
        return {'success': true};
    }
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    switch (endpoint) {
      case 'accounts/me/':
        return AuthTestUtils.createUserProfileApiResponse();
      default:
        return {};
    }
  }

  @override
  void setAuthToken(String token) {}

  @override
  void clearAuthToken() {}
}

/// Mock implementation for testing offline scenarios
class OfflineMockApiClient extends Mock implements ApiClient {
  @override
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    throw NetworkException('No internet connection');
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    throw NetworkException('No internet connection');
  }

  @override
  void setAuthToken(String token) {}

  @override
  void clearAuthToken() {}
}

/// Mock implementation for testing timeout scenarios
class TimeoutMockApiClient extends Mock implements ApiClient {
  @override
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    throw NetworkException('Request timeout');
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    throw NetworkException('Request timeout');
  }

  @override
  void setAuthToken(String token) {}

  @override
  void clearAuthToken() {}
}

/// Factory class for creating different types of mock implementations
class MockFactory {
  /// Creates a standard mock auth service
  static MockAuthService createMockAuthService() {
    return MockAuthService();
  }
  
  /// Creates a mock auth service that's already authenticated
  static MockAuthService createAuthenticatedMockAuthService({
    User? user,
  }) {
    final mock = MockAuthService();
    mock.simulateAuthentication(user ?? AuthTestUtils.createTestUser());
    return mock;
  }
  
  /// Creates a mock auth service that's unauthenticated
  static MockAuthService createUnauthenticatedMockAuthService({
    String? error,
  }) {
    final mock = MockAuthService();
    mock.simulateStateChange(AuthState(
      status: AuthStatus.unauthenticated,
      error: error,
    ));
    return mock;
  }
  
  /// Creates a mock repository with successful responses
  static MockAuthRepository createSuccessfulMockRepository() {
    final mock = MockAuthRepository();
    
    // Note: These are default implementations that can be overridden in tests
    // The mock will use the default implementations from MockAuthRepository
    
    return mock;
  }
  
  /// Creates a mock repository that throws validation errors
  static ValidationErrorMockRepository createValidationErrorMockRepository() {
    return ValidationErrorMockRepository();
  }
  
  /// Creates a mock API client with successful responses
  static SuccessfulMockApiClient createSuccessfulMockApiClient() {
    return SuccessfulMockApiClient();
  }
  
  /// Creates a mock token manager with a stored token
  static MockTokenManager createTokenMockTokenManager({
    String token = 'test-token-123',
  }) {
    final mock = MockTokenManager();
    mock.simulateToken(token);
    return mock;
  }
  
  /// Creates a mock token manager with no stored token
  static MockTokenManager createEmptyMockTokenManager() {
    final mock = MockTokenManager();
    mock.simulateToken(null);
    return mock;
  }
}

/// Test widget wrapper for authentication testing
/// 
/// This widget provides a testing environment with mock authentication services
/// and proper Material app context for widget tests.
class AuthTestWidget extends StatelessWidget {
  final Widget child;
  final MockAuthService? mockAuthService;
  final bool configureQuestionAuth;
  final AuthConfig? authConfig;
  
  const AuthTestWidget({
    Key? key,
    required this.child,
    this.mockAuthService,
    this.configureQuestionAuth = true,
    this.authConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configure QuestionAuth if requested
    if (configureQuestionAuth) {
      final config = authConfig ?? AuthTestUtils.createTestConfig();
      QuestionAuth.instance.configure(
        baseUrl: config.baseUrl,
        apiVersion: config.apiVersion,
        timeout: config.timeout,
        enableLogging: config.enableLogging,
        defaultHeaders: config.defaultHeaders,
      );
    }
    
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}

/// Test widget wrapper with authentication state provider
/// 
/// This widget provides authentication state through a stream for testing
/// reactive UI components that depend on authentication state.
class AuthStateTestWidget extends StatelessWidget {
  final Widget child;
  final Stream<AuthState>? authStateStream;
  final AuthState? initialState;
  
  const AuthStateTestWidget({
    Key? key,
    required this.child,
    this.authStateStream,
    this.initialState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: StreamBuilder<AuthState>(
          stream: authStateStream,
          initialData: initialState ?? AuthTestUtils.createUnknownState(),
          builder: (context, snapshot) {
            return child;
          },
        ),
      ),
    );
  }
}

/// Test helper for creating widget test environments
class WidgetTestHelper {
  /// Creates a basic test environment for authentication widgets
  static Widget createTestEnvironment({
    required Widget child,
    MockAuthService? mockAuthService,
    bool configureQuestionAuth = true,
    AuthConfig? authConfig,
  }) {
    return AuthTestWidget(
      mockAuthService: mockAuthService,
      configureQuestionAuth: configureQuestionAuth,
      authConfig: authConfig,
      child: child,
    );
  }
  
  /// Creates a test environment with authentication state stream
  static Widget createAuthStateTestEnvironment({
    required Widget child,
    Stream<AuthState>? authStateStream,
    AuthState? initialState,
  }) {
    return AuthStateTestWidget(
      authStateStream: authStateStream,
      initialState: initialState,
      child: child,
    );
  }
  
  /// Pumps a widget with authentication test environment
  static Future<void> pumpAuthWidget(
    WidgetTester tester,
    Widget child, {
    MockAuthService? mockAuthService,
    bool configureQuestionAuth = true,
    AuthConfig? authConfig,
  }) async {
    await tester.pumpWidget(
      createTestEnvironment(
        child: child,
        mockAuthService: mockAuthService,
        configureQuestionAuth: configureQuestionAuth,
        authConfig: authConfig,
      ),
    );
  }
  
  /// Pumps a widget with authentication state test environment
  static Future<void> pumpAuthStateWidget(
    WidgetTester tester,
    Widget child, {
    Stream<AuthState>? authStateStream,
    AuthState? initialState,
  }) async {
    await tester.pumpWidget(
      createAuthStateTestEnvironment(
        child: child,
        authStateStream: authStateStream,
        initialState: initialState,
      ),
    );
  }
  
  /// Finds authentication-related widgets by type
  static Finder findAuthWidget<T extends Widget>() {
    return find.byType(T);
  }
  
  /// Finds widgets by authentication-related keys
  static Finder findByAuthKey(String key) {
    return find.byKey(Key(key));
  }
  
  /// Verifies that authentication state is displayed correctly
  static void verifyAuthState(
    WidgetTester tester,
    AuthStatus expectedStatus, {
    String? expectedError,
    User? expectedUser,
  }) {
    // This would be implemented based on specific UI components
    // For now, it's a placeholder for authentication state verification
    expect(find.byType(Widget), findsWidgets);
  }
  
  /// Simulates user authentication in widget tests
  static Future<void> simulateAuthentication(
    WidgetTester tester,
    MockAuthService mockAuthService, {
    User? user,
  }) async {
    mockAuthService.simulateAuthentication(
      user ?? AuthTestUtils.createTestUser(),
    );
    await tester.pump();
  }
  
  /// Simulates user logout in widget tests
  static Future<void> simulateLogout(
    WidgetTester tester,
    MockAuthService mockAuthService,
  ) async {
    mockAuthService.simulateLogout();
    await tester.pump();
  }
}