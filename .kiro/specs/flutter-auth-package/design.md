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
  Future<UserProfileResponse> getCurrentUser();
  Future<void> logout();
  
  // State management
  Stream<AuthState> get authStateStream;
  bool get isAuthenticated;
  User? get currentUser;
  
  // Additional user profile information
  List<String>? get userRoles;
  Map<String, bool>? get profileComplete;
  bool? get onboardingComplete;
  String? get appAccess;
}
```

#### AuthService (Alternative Dependency Injection Approach)
```dart
abstract class AuthService {
  Future<AuthResult> signUp(SignUpRequest request);
  Future<AuthResult> login(LoginRequest request);
  Future<UserProfileResponse> getCurrentUser();
  Future<void> logout();
  Stream<AuthState> get authStateStream;
  bool get isAuthenticated;
  
  // Additional user profile information
  List<String>? get userRoles;
  Map<String, bool>? get profileComplete;
  bool? get onboardingComplete;
  String? get appAccess;
}

class AuthServiceImpl implements AuthService {
  final AuthRepository _repository;
  final AuthStateNotifier _stateNotifier;
  
  AuthServiceImpl(this._repository, this._stateNotifier);
  
  @override
  Future<AuthResult> signUp(SignUpRequest request) async {
    final result = await _repository.signUp(request);
    if (!result.success) {
      _stateNotifier.setUnauthenticated(result.error);
    }
    return result;
  }
  
  @override
  Future<AuthResult> login(LoginRequest request) async {
    final result = await _repository.login(request);
    if (result.success && result.user != null) {
      _stateNotifier.setAuthenticated(result.user!);
    } else {
      _stateNotifier.setUnauthenticated(result.error);
    }
    return result;
  }
  
  // Additional implementation...
}
```

### 2. Business Logic Layer

#### AuthRepository
```dart
abstract class AuthRepository {
  Future<AuthResult> signUp(SignUpRequest request);
  Future<AuthResult> login(LoginRequest request);
  Future<UserProfileResponse> getCurrentUser();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;
  
  AuthRepositoryImpl(this._apiClient, this._tokenManager);
  
  @override
  Future<AuthResult> signUp(SignUpRequest request) async {
    try {
      final response = await _apiClient.register(request);
      return AuthResult(
        success: true,
        signUpData: response,
      );
    } catch (e) {
      // Handle errors and return AuthResult with error details
      return AuthResult(success: false, error: e.toString());
    }
  }
  
  @override
  Future<AuthResult> login(LoginRequest request) async {
    try {
      final response = await _apiClient.login(request);
      await _tokenManager.saveToken(response.token);
      _apiClient.setAuthToken(response.token);
      
      return AuthResult(
        success: true,
        user: response.user,
        token: response.token,
        loginData: response,
      );
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }
  
  @override
  Future<UserProfileResponse> getCurrentUser() async {
    return await _apiClient.getCurrentUser();
  }
  
  @override
  Future<void> logout() async {
    await _apiClient.logout();
    await _tokenManager.clearToken();
    _apiClient.clearAuthToken();
  }
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
  
  // Specific endpoint methods
  Future<SignUpResponse> register(SignUpRequest request);
  Future<LoginResponse> login(LoginRequest request);
  Future<UserProfileResponse> getCurrentUser();
  Future<LogoutResponse> logout();
}

class HttpApiClient implements ApiClient {
  final http.Client _client;
  final String _baseUrl;
  String? _authToken;
  
  HttpApiClient(this._client, this._baseUrl);
  
  @override
  Future<SignUpResponse> register(SignUpRequest request) async {
    final response = await post('/accounts/register/', request.toJson());
    return SignUpResponse.fromJson(response);
  }
  
  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await post('/accounts/login/', request.toJson());
    return LoginResponse.fromJson(response);
  }
  
  @override
  Future<UserProfileResponse> getCurrentUser() async {
    final response = await get('/accounts/me/');
    return UserProfileResponse.fromJson(response);
  }
  
  @override
  Future<LogoutResponse> logout() async {
    final response = await post('/logout/', {});
    return LogoutResponse.fromJson(response);
  }
  
  // Implementation details...
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

## API Endpoints

### Authentication Endpoints

#### POST /accounts/register/
**Purpose**: Register a new user account

**Request Payload**:
```json
{
  "email": "example@gmail.com",
  "password": "password@123",
  "display_name": "Akash",
  "confirm_password": "password@123"
}
```

**Success Response (200)**:
```json
{
  "detail": "Registration successful! Please check your email to verify your account.",
  "data": {
    "email": "example@gmail.com",
    "verification_token_expires_in": "10 minutes"
  }
}
```

**Error Response (400)**:
```json
{
  "email": ["user with this email already exists."]
}
```

#### POST /accounts/login/
**Purpose**: Authenticate user and return access token

**Request Payload**:
```json
{
  "email": "user@example.com",
  "password": "password@123"
}
```

**Success Response (200)**:
```json
{
  "token": "879c09f82dd58f9dd3552e33abf3f015f2c8e804",
  "user": {
    "email": "user@example.com",
    "display_name": "user1",
    "is_verified": true,
    "is_new": false
  },
  "roles": ["Creator"],
  "profile_complete": {
    "student": false,
    "creator": true
  },
  "onboarding_complete": true,
  "incomplete_roles": [],
  "app_access": "full",
  "redirect_to": "/dashboard"
}
```

#### GET /accounts/me/
**Purpose**: Get current authenticated user profile information

**Headers Required**:
```
Authorization: Token 879c09f82dd58f9dd3552e33abf3f015f2c8e804
```

**Success Response (200)**:
```json
{
  "user": {
    "email": "user@example.com",
    "display_name": "User Display Name",
    "is_active": true,
    "email_verified": true,
    "date_joined": "2024-01-01T00:00:00Z"
  },
  "is_new": false,
  "mode": "student",
  "roles": ["student", "creator"],
  "available_roles": ["creator"],
  "removable_roles": [],
  "profile_complete": {
    "student": true,
    "creator": false
  },
  "onboarding_complete": true,
  "incomplete_roles": ["creator"],
  "app_access": "full",
  "viewType": "student-complete-student-only",
  "redirect_to": "/onboarding/profile"
}
```

#### POST /logout/
**Purpose**: Logout current user and invalidate token

**Headers Required**:
```
Authorization: Token 879c09f82dd58f9dd3552e33abf3f015f2c8e804
```

**Success Response (200)**:
```json
{
  "detail": "Logged out successfully."
}
```

## Data Models

### Core Models

#### User Model
```dart
class User {
  final String email;
  final String displayName;
  final bool isActive;
  final bool emailVerified;
  final bool isVerified;
  final bool isNew;
  final DateTime? dateJoined;
  
  const User({
    required this.email,
    required this.displayName,
    this.isActive = true,
    this.emailVerified = false,
    this.isVerified = false,
    this.isNew = false,
    this.dateJoined,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      emailVerified: json['email_verified'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      dateJoined: json['date_joined'] != null 
          ? DateTime.parse(json['date_joined'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'display_name': displayName,
    'is_active': isActive,
    'email_verified': emailVerified,
    'is_verified': isVerified,
    'is_new': isNew,
    if (dateJoined != null) 'date_joined': dateJoined!.toIso8601String(),
  };
}
```

#### Request Models
```dart
class SignUpRequest {
  final String email;
  final String password;
  final String displayName;
  final String confirmPassword;
  
  const SignUpRequest({
    required this.email,
    required this.password,
    required this.displayName,
    required this.confirmPassword,
  });
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'display_name': displayName,
    'confirm_password': confirmPassword,
  };
  
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
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
  
  List<String> validate();
}
```

#### Response Models
```dart
class SignUpResponse {
  final String detail;
  final SignUpData? data;
  
  const SignUpResponse({
    required this.detail,
    this.data,
  });
  
  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      detail: json['detail'] as String,
      data: json['data'] != null 
          ? SignUpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SignUpData {
  final String email;
  final String verificationTokenExpiresIn;
  
  const SignUpData({
    required this.email,
    required this.verificationTokenExpiresIn,
  });
  
  factory SignUpData.fromJson(Map<String, dynamic> json) {
    return SignUpData(
      email: json['email'] as String,
      verificationTokenExpiresIn: json['verification_token_expires_in'] as String,
    );
  }
}

class LoginResponse {
  final String token;
  final User user;
  final List<String> roles;
  final Map<String, bool> profileComplete;
  final bool onboardingComplete;
  final List<String> incompleteRoles;
  final String appAccess;
  final String redirectTo;
  
  const LoginResponse({
    required this.token,
    required this.user,
    required this.roles,
    required this.profileComplete,
    required this.onboardingComplete,
    required this.incompleteRoles,
    required this.appAccess,
    required this.redirectTo,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      roles: List<String>.from(json['roles'] as List),
      profileComplete: Map<String, bool>.from(json['profile_complete'] as Map),
      onboardingComplete: json['onboarding_complete'] as bool,
      incompleteRoles: List<String>.from(json['incomplete_roles'] as List),
      appAccess: json['app_access'] as String,
      redirectTo: json['redirect_to'] as String,
    );
  }
}

class UserProfileResponse {
  final User user;
  final bool isNew;
  final String mode;
  final List<String> roles;
  final List<String> availableRoles;
  final List<String> removableRoles;
  final Map<String, bool> profileComplete;
  final bool onboardingComplete;
  final List<String> incompleteRoles;
  final String appAccess;
  final String viewType;
  final String redirectTo;
  
  const UserProfileResponse({
    required this.user,
    required this.isNew,
    required this.mode,
    required this.roles,
    required this.availableRoles,
    required this.removableRoles,
    required this.profileComplete,
    required this.onboardingComplete,
    required this.incompleteRoles,
    required this.appAccess,
    required this.viewType,
    required this.redirectTo,
  });
  
  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      isNew: json['is_new'] as bool,
      mode: json['mode'] as String,
      roles: List<String>.from(json['roles'] as List),
      availableRoles: List<String>.from(json['available_roles'] as List),
      removableRoles: List<String>.from(json['removable_roles'] as List),
      profileComplete: Map<String, bool>.from(json['profile_complete'] as Map),
      onboardingComplete: json['onboarding_complete'] as bool,
      incompleteRoles: List<String>.from(json['incomplete_roles'] as List),
      appAccess: json['app_access'] as String,
      viewType: json['viewType'] as String,
      redirectTo: json['redirect_to'] as String,
    );
  }
}

class LogoutResponse {
  final String detail;
  
  const LogoutResponse({required this.detail});
  
  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(detail: json['detail'] as String);
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
  final LoginResponse? loginData;
  final SignUpResponse? signUpData;
  
  const AuthResult({
    required this.success,
    this.user,
    this.token,
    this.error,
    this.fieldErrors,
    this.loginData,
    this.signUpData,
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
    baseUrl: 'https://dev.questions.org.in/api/',
  );
  
  runApp(MyApp());
}

// Registration example
final signUpRequest = SignUpRequest(
  email: 'user@example.com',
  password: 'password@123',
  displayName: 'John Doe',
  confirmPassword: 'password@123',
);

final signUpResult = await QuestionAuth.instance.signUp(signUpRequest);
if (signUpResult.success) {
  print('Registration successful: ${signUpResult.signUpData?.detail}');
} else {
  print('Registration failed: ${signUpResult.error}');
}

// Login example
final loginRequest = LoginRequest(
  email: 'user@example.com',
  password: 'password@123',
);

final loginResult = await QuestionAuth.instance.login(loginRequest);
if (loginResult.success) {
  print('Login successful');
  print('User roles: ${loginResult.loginData?.roles}');
  print('Redirect to: ${loginResult.loginData?.redirectTo}');
} else {
  print('Login failed: ${loginResult.error}');
}

// Get current user profile
try {
  final userProfile = await QuestionAuth.instance.getCurrentUser();
  print('User mode: ${userProfile.mode}');
  print('Available roles: ${userProfile.availableRoles}');
  print('Profile complete: ${userProfile.profileComplete}');
} catch (e) {
  print('Failed to get user profile: $e');
}
```

## Security Considerations

1. **Token Storage**: Uses flutter_secure_storage for encrypted token storage
2. **HTTPS Only**: Enforces HTTPS for all API communications
3. **Token Validation**: Validates token format and expiration
4. **Secure Headers**: Implements proper Authorization headers
5. **Input Validation**: Client-side validation to prevent malicious input
6. **Error Messages**: Sanitized error messages to prevent information leakage