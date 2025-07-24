# Design Document

## Overview

The Flutter authentication package will provide a comprehensive, modular authentication solution that can be easily integrated into any Flutter application. The package follows Flutter package conventions and implements a clean architecture pattern with clear separation of concerns.

The package will expose a simple, intuitive API while handling complex authentication flows internally. It will manage token storage, HTTP communication, error handling, and provide reactive state management for authentication status.

## Architecture

The package follows a layered architecture with the following components:

```
┌─────────────────────────────────────┐
│           Public API Layer          │
│    (QuestionAuth, AuthService)      │
├─────────────────────────────────────┤
│         Business Logic Layer        │
│  (AuthRepository, TokenManager)     │
├─────────────────────────────────────┤
│          Data Access Layer          │
│   (ApiClient, SecureStorage)        │
├─────────────────────────────────────┤
│            Models Layer             │
│  (User, AuthResponse, ApiError)     │
└─────────────────────────────────────┘
```

### Key Architectural Decisions:

1. **Repository Pattern**: Abstracts data access and provides a clean interface for business logic
2. **Dependency Injection**: Allows for easy testing and customization
3. **Reactive Programming**: Uses Streams/ValueNotifiers for real-time authentication state updates
4. **Secure Storage**: Implements platform-specific secure storage for tokens
5. **Error Handling**: Comprehensive error handling with custom exception types

## Components and Interfaces

### 1. Public API Layer

#### QuestionAuth (Main Entry Point)
```dart
class QuestionAuth {
  static QuestionAuth? _instance;
  static QuestionAuth get instance => _instance ??= QuestionAuth._();
  
  // Configuration
  void configure({required String baseUrl, String? apiVersion});
  
  // Authentication methods
  Future<AuthResult> signUp(SignUpRequest request);
  Future<AuthResult> login(LoginRequest request);
  Future<User> getCurrentUser();
  Future<void> logout();
  
  // State management
  Stream<AuthState> get authStateStream;
  bool get isAuthenticated;
  User? get currentUser;
}
```

#### AuthService (Alternative Dependency Injection Approach)
```dart
abstract class AuthService {
  Future<AuthResult> signUp(SignUpRequest request);
  Future<AuthResult> login(LoginRequest request);
  Future<User> getCurrentUser();
  Future<void> logout();
  Stream<AuthState> get authStateStream;
  bool get isAuthenticated;
}

class AuthServiceImpl implements AuthService {
  // Implementation
}
```

### 2. Business Logic Layer

#### AuthRepository
```dart
abstract class AuthRepository {
  Future<AuthResponse> signUp(SignUpRequest request);
  Future<AuthResponse> login(LoginRequest request);
  Future<User> getCurrentUser();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;
  // Implementation
}
```

#### TokenManager
```dart
abstract class TokenManager {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<bool> hasValidToken();
}

class SecureTokenManager implements TokenManager {
  // Implementation using flutter_secure_storage
}
```

### 3. Data Access Layer

#### ApiClient
```dart
abstract class ApiClient {
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data);
  Future<Map<String, dynamic>> get(String endpoint);
  void setAuthToken(String token);
  void clearAuthToken();
}

class HttpApiClient implements ApiClient {
  final http.Client _client;
  final String _baseUrl;
  // Implementation
}
```

#### SecureStorage
```dart
abstract class SecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class FlutterSecureStorageImpl implements SecureStorage {
  // Implementation using flutter_secure_storage
}
```

### 4. State Management

#### AuthState
```dart
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  
  const AuthState({
    required this.status,
    this.user,
    this.error,
  });
}
```

#### AuthStateNotifier
```dart
class AuthStateNotifier extends ValueNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState(status: AuthStatus.unknown));
  
  void setAuthenticated(User user) {
    value = AuthState(status: AuthStatus.authenticated, user: user);
  }
  
  void setUnauthenticated([String? error]) {
    value = AuthState(status: AuthStatus.unauthenticated, error: error);
  }
}
```

## Data Models

### Core Models

#### User Model
```dart
class User {
  final String id;
  final String email;
  final String username;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const User({
    required this.id,
    required this.email,
    required this.username,
    this.createdAt,
    this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### Request Models
```dart
class SignUpRequest {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  
  const SignUpRequest({
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
  });
  
  Map<String, dynamic> toJson();
  
  // Validation
  List<String> validate();
}

class LoginRequest {
  final String email;
  final String password;
  
  const LoginRequest({
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson();
  List<String> validate();
}
```

#### Response Models
```dart
class AuthResponse {
  final String? token;
  final User? user;
  final bool success;
  final String? message;
  
  const AuthResponse({
    this.token,
    this.user,
    required this.success,
    this.message,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json);
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
  
  const AuthResult({
    required this.success,
    this.user,
    this.error,
    this.fieldErrors,
  });
}
```

## Error Handling

### Custom Exception Types
```dart
abstract class AuthException implements Exception {
  final String message;
  final String? code;
  
  const AuthException(this.message, [this.code]);
}

class NetworkException extends AuthException {
  const NetworkException(String message) : super(message, 'NETWORK_ERROR');
}

class ValidationException extends AuthException {
  final Map<String, List<String>> fieldErrors;
  
  const ValidationException(String message, this.fieldErrors) 
      : super(message, 'VALIDATION_ERROR');
}

class ApiException extends AuthException {
  final int statusCode;
  
  const ApiException(String message, this.statusCode, [String? code]) 
      : super(message, code);
}

class TokenException extends AuthException {
  const TokenException(String message) : super(message, 'TOKEN_ERROR');
}
```

### Error Handling Strategy
1. **Network Errors**: Wrapped in NetworkException with retry mechanisms
2. **API Errors**: Parsed from server responses and wrapped in ApiException
3. **Validation Errors**: Client-side validation with structured field errors
4. **Token Errors**: Automatic token refresh or re-authentication prompts

## Testing Strategy

### Unit Testing
- **Models**: Test serialization/deserialization and validation
- **Repository**: Test business logic with mocked dependencies
- **TokenManager**: Test secure storage operations
- **ApiClient**: Test HTTP communication with mock responses

### Integration Testing
- **Authentication Flow**: End-to-end authentication scenarios
- **Token Management**: Token persistence and retrieval
- **Error Scenarios**: Network failures and API errors

### Test Utilities
```dart
class MockAuthService extends Mock implements AuthService {}
class MockApiClient extends Mock implements ApiClient {}
class MockTokenManager extends Mock implements TokenManager {}

class AuthTestUtils {
  static SignUpRequest createValidSignUpRequest();
  static LoginRequest createValidLoginRequest();
  static User createTestUser();
  static AuthResponse createSuccessResponse();
}
```

### Widget Testing Support
```dart
class AuthTestWidget extends StatelessWidget {
  final Widget child;
  final AuthService? mockAuthService;
  
  const AuthTestWidget({
    Key? key,
    required this.child,
    this.mockAuthService,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>.value(
      value: mockAuthService ?? MockAuthService(),
      child: child,
    );
  }
}
```

## Dependencies

### Required Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

### Optional Dependencies (for enhanced features)
```yaml
  # For advanced state management
  provider: ^6.0.0
  
  # For connectivity checking
  connectivity_plus: ^5.0.0
  
  # For logging
  logger: ^2.0.0
```

## Configuration

### Package Configuration
```dart
class AuthConfig {
  final String baseUrl;
  final String apiVersion;
  final Duration timeout;
  final bool enableLogging;
  final Map<String, String> defaultHeaders;
  
  const AuthConfig({
    required this.baseUrl,
    this.apiVersion = 'v1',
    this.timeout = const Duration(seconds: 30),
    this.enableLogging = false,
    this.defaultHeaders = const {},
  });
}
```

### Usage Example
```dart
void main() {
  QuestionAuth.instance.configure(
    baseUrl: 'https://dev.questions.org.in/api/v1/',
  );
  
  runApp(MyApp());
}
```

## Security Considerations

1. **Token Storage**: Uses flutter_secure_storage for encrypted token storage
2. **HTTPS Only**: Enforces HTTPS for all API communications
3. **Token Validation**: Validates token format and expiration
4. **Secure Headers**: Implements proper Authorization headers
5. **Input Validation**: Client-side validation to prevent malicious input
6. **Error Messages**: Sanitized error messages to prevent information leakage