# QuestionAuth

A comprehensive Flutter authentication package that provides a modular authentication solution for Flutter applications. This package handles user registration, login, profile management, and logout functionality through a REST API, making it easy to integrate secure authentication into your Flutter projects.

## Features

- ✅ **User Registration**: Complete signup flow with client-side validation
- ✅ **User Authentication**: Secure login with automatic token management
- ✅ **Profile Management**: Retrieve and manage user profiles
- ✅ **Secure Token Storage**: Automatic token storage using `flutter_secure_storage`
- ✅ **Reactive State Management**: Real-time authentication state updates via streams
- ✅ **Comprehensive Error Handling**: Structured error responses with field-level validation
- ✅ **Network Resilience**: Built-in timeout handling and retry mechanisms
- ✅ **Testing Support**: Complete mock implementations and test utilities
- ✅ **Persistence**: Automatic authentication state restoration on app restart
- ✅ **Type Safety**: Full Dart type safety with comprehensive documentation

## Installation

### 1. Add to pubspec.yaml

Add `question_auth` to your Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  question_auth:
    path: ../question_auth  # For local development
    # git:
    #   url: https://github.com/your-org/question_auth.git
    #   ref: main
  flutter:
    sdk: flutter
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Platform Setup

#### Android
No additional setup required.

#### iOS
No additional setup required.

## Quick Start

### 1. Configure the Package

In your app's `main.dart`, configure QuestionAuth with your API endpoint:

```dart
import 'package:flutter/material.dart';
import 'package:question_auth/question_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure QuestionAuth with your API endpoint
  QuestionAuth.instance.configure(
    baseUrl: 'https://your-api.com/api/v1/',
  );
  
  // Initialize authentication state
  await QuestionAuth.instance.initialize();
  
  runApp(MyApp());
}
```

### 2. Set Up Authentication State Management

Create an `AuthWrapper` to handle authentication state changes:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: QuestionAuth.instance.authStateStream,
      builder: (context, snapshot) {
        final authState = snapshot.data ?? const AuthState.unknown();
        
        switch (authState.status) {
          case AuthStatus.authenticated:
            return HomeScreen(user: authState.user!);
          case AuthStatus.unauthenticated:
            return LoginScreen();
          case AuthStatus.unknown:
          default:
            return const SplashScreen();
        }
      },
    );
  }
}
```

## Usage Examples

### User Registration

```dart
import 'package:question_auth/question_auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, List<String>>? _fieldErrors;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _fieldErrors = null;
    });

    try {
      final result = await QuestionAuth.instance.signUp(
        SignUpRequest(
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );

      if (result.success) {
        // Registration successful - user is automatically logged in
        print('Welcome, ${result.user?.username}!');
        // Navigation will be handled by AuthWrapper listening to authStateStream
      } else {
        setState(() {
          _errorMessage = result.error;
          _fieldErrors = result.fieldErrors;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _fieldErrors?['email']?.first,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: _fieldErrors?['username']?.first,
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _fieldErrors?['password']?.first,
              ),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: _fieldErrors?['confirmPassword']?.first,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### User Login

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await QuestionAuth.instance.login(
        LoginRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (result.success) {
        print('Welcome back, ${result.user?.username}!');
        // Navigation handled by AuthWrapper
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Login failed';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Profile Management

```dart
class ProfileScreen extends StatefulWidget {
  final User user;
  
  const ProfileScreen({Key? key, required this.user}) : super(key: key);
  
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await QuestionAuth.instance.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.message}';
      });
    } on NetworkException catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await QuestionAuth.instance.logout();
    // Navigation handled by AuthWrapper
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.red.shade100,
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Username: ${_currentUser?.username ?? 'N/A'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ${_currentUser?.email ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  if (_currentUser?.createdAt != null)
                    Text(
                      'Member since: ${_currentUser!.createdAt!.toLocal().toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
    );
  }
}
```

### Authentication State Monitoring

```dart
class AuthStateMonitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: QuestionAuth.instance.authStateStream,
      builder: (context, snapshot) {
        final authState = snapshot.data ?? const AuthState.unknown();
        
        return Container(
          padding: const EdgeInsets.all(8.0),
          color: _getStatusColor(authState.status),
          child: Row(
            children: [
              Icon(_getStatusIcon(authState.status)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Status: ${authState.status.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (authState.user != null)
                      Text('User: ${authState.user!.username}'),
                    if (authState.error != null)
                      Text(
                        'Error: ${authState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        return Colors.green.shade100;
      case AuthStatus.unauthenticated:
        return Colors.red.shade100;
      case AuthStatus.unknown:
        return Colors.grey.shade100;
    }
  }

  IconData _getStatusIcon(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        return Icons.check_circle;
      case AuthStatus.unauthenticated:
        return Icons.error;
      case AuthStatus.unknown:
        return Icons.help;
    }
  }
}
```

## Advanced Configuration

### Custom Configuration Options

```dart
QuestionAuth.instance.configure(
  baseUrl: 'https://your-api.com/api/v1/',
  apiVersion: 'v2',                    // Default: 'v1'
  timeout: const Duration(seconds: 45), // Default: 30 seconds
  enableLogging: true,                 // Default: false
  defaultHeaders: {
    'X-Client-Version': '1.0.0',
    'Accept': 'application/json',
    'X-Platform': 'flutter',
  },
);
```

### Dependency Injection (Advanced Usage)

For advanced use cases, you can use the service interfaces directly:

```dart
import 'package:question_auth/question_auth.dart';

class MyAuthService {
  final AuthService _authService;
  
  MyAuthService(this._authService);
  
  Future<bool> quickLogin(String email, String password) async {
    final result = await _authService.login(
      LoginRequest(email: email, password: password),
    );
    return result.success;
  }
}

// Usage with dependency injection
final tokenManager = SecureTokenManager();
final apiClient = HttpApiClient(baseUrl: 'https://api.example.com');
final repository = AuthRepositoryImpl(
  apiClient: apiClient,
  tokenManager: tokenManager,
);
final authService = AuthServiceImpl(repository: repository);

final myAuthService = MyAuthService(authService);
```

## Error Handling

The package provides comprehensive error handling with specific exception types:

```dart
try {
  final result = await QuestionAuth.instance.login(loginRequest);
  if (result.success) {
    // Handle success
    print('Login successful: ${result.user?.username}');
  } else {
    // Handle authentication failure
    print('Login failed: ${result.error}');
    
    // Handle field-specific errors
    result.fieldErrors?.forEach((field, errors) {
      print('$field: ${errors.join(', ')}');
    });
  }
} on ValidationException catch (e) {
  // Client-side validation errors
  print('Validation error: ${e.message}');
  e.fieldErrors.forEach((field, errors) {
    print('$field: ${errors.join(', ')}');
  });
} on ApiException catch (e) {
  // Server-side API errors
  print('API error (${e.statusCode}): ${e.message}');
} on NetworkException catch (e) {
  // Network connectivity issues
  print('Network error: ${e.message}');
} on TokenException catch (e) {
  // Token-related errors
  print('Token error: ${e.message}');
} catch (e) {
  // Unexpected errors
  print('Unexpected error: $e');
}
```

### Exception Types

- **`ValidationException`**: Client-side validation errors with field details
- **`ApiException`**: Server-side errors with HTTP status codes
- **`NetworkException`**: Network connectivity issues
- **`TokenException`**: Token-related errors (expired, invalid, etc.)
- **`AuthException`**: Base authentication exception

## Testing

The package includes comprehensive testing utilities for easy testing in your app:

### Basic Testing Setup

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:question_auth/question_auth.dart';

void main() {
  group('Authentication Tests', () {
    setUp(() {
      QuestionAuth.reset(); // Reset singleton for testing
    });

    test('should handle login success', () async {
      // Configure QuestionAuth for testing
      QuestionAuth.instance.configure(
        baseUrl: 'https://test-api.com/api/v1/',
      );

      // Test your authentication logic
      final loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(loginRequest.isValid, isTrue);
    });
  });
}
```

### Widget Testing

```dart
testWidgets('should show login screen when unauthenticated', (tester) async {
  QuestionAuth.reset();
  QuestionAuth.instance.configure(baseUrl: 'https://test-api.com/api/v1/');

  await tester.pumpWidget(
    MaterialApp(
      home: AuthWrapper(),
    ),
  );

  // Test your authentication UI
  expect(find.byType(LoginScreen), findsOneWidget);
});
```

### Mock Testing

```dart
import 'package:question_auth/question_auth.dart';

// Create mock implementations for testing
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('Mock Authentication Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    test('should handle mock login', () async {
      // Setup mock behavior
      when(mockAuthService.login(any))
          .thenAnswer((_) async => AuthResult.success(
            user: User(
              id: '1',
              email: 'test@example.com',
              username: 'testuser',
            ),
          ));

      // Test with mock
      final result = await mockAuthService.login(
        LoginRequest(email: 'test@example.com', password: 'password'),
      );

      expect(result.success, isTrue);
      expect(result.user?.username, equals('testuser'));
    });
  });
}
```

## API Reference

### Core Classes

#### QuestionAuth
Main singleton entry point for the authentication package.

```dart
// Configuration
QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
await QuestionAuth.instance.initialize();

// Authentication methods
Future<AuthResult> signUp(SignUpRequest request);
Future<AuthResult> login(LoginRequest request);
Future<User> getCurrentUser();
Future<void> logout();

// State access
Stream<AuthState> get authStateStream;
bool get isAuthenticated;
User? get currentUser;
AuthState get currentAuthState;
```

#### AuthState
Represents the current authentication state.

```dart
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
}
```

#### User
User model representing authenticated user data.

```dart
class User {
  final String id;
  final String email;
  final String username;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### Request Models

#### SignUpRequest
```dart
class SignUpRequest {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  
  // Validation
  bool get isValid;
  List<String> validate();
  Map<String, List<String>> validateFields();
}
```

#### LoginRequest
```dart
class LoginRequest {
  final String email;
  final String password;
  
  // Validation
  bool get isValid;
  List<String> validate();
  Map<String, List<String>> validateFields();
}
```

### Response Models

#### AuthResult
```dart
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
}
```

## API Requirements

Your backend API should implement the following endpoints:

### POST /accounts/signup/
```json
// Request
{
  "email": "user@example.com",
  "username": "username",
  "password": "password123",
  "confirm_password": "password123"
}

// Success Response (201)
{
  "success": true,
  "message": "User created successfully",
  "token": "jwt_token_here",
  "user": {
    "id": "1",
    "email": "user@example.com",
    "username": "username",
    "created_at": "2023-01-01T00:00:00Z",
    "updated_at": "2023-01-01T00:00:00Z"
  }
}

// Error Response (400)
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Email already exists"],
    "username": ["Username is required"]
  }
}
```

### POST /accounts/login/
```json
// Request
{
  "email": "user@example.com",
  "password": "password123"
}

// Success Response (200)
{
  "success": true,
  "message": "Login successful",
  "token": "jwt_token_here",
  "user": {
    "id": "1",
    "email": "user@example.com",
    "username": "username",
    "created_at": "2023-01-01T00:00:00Z",
    "updated_at": "2023-01-01T00:00:00Z"
  }
}
```

### GET /accounts/me/
```json
// Headers: Authorization: Bearer jwt_token_here

// Success Response (200)
{
  "id": "1",
  "email": "user@example.com",
  "username": "username",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z"
}
```

### POST /logout/
```json
// Headers: Authorization: Bearer jwt_token_here

// Success Response (200)
{
  "success": true,
  "message": "Logout successful"
}
```

## Troubleshooting

### Common Issues

1. **Configuration Error**: Make sure to call `QuestionAuth.instance.configure()` before using any authentication methods.

2. **Network Timeouts**: Adjust the timeout configuration if you're experiencing network issues:
   ```dart
   QuestionAuth.instance.configure(
     baseUrl: 'https://your-api.com/api/v1/',
     timeout: const Duration(seconds: 60),
   );
   ```

3. **Token Persistence Issues**: The package uses `flutter_secure_storage` which requires platform-specific setup for some advanced configurations.

4. **State Not Updating**: Make sure you're listening to `authStateStream` for reactive updates.

### Debug Mode

Enable logging to debug issues:

```dart
QuestionAuth.instance.configure(
  baseUrl: 'https://your-api.com/api/v1/',
  enableLogging: true,
);
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions, issues, or feature requests, please:

1. Check the [documentation](https://pub.dev/packages/question_auth)
2. Search [existing issues](https://github.com/your-org/question_auth/issues)
3. Create a [new issue](https://github.com/your-org/question_auth/issues/new) if needed

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.