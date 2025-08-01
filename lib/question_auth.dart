/// A comprehensive Flutter authentication package that provides a modular
/// authentication solution for Flutter applications.
/// 
/// This package handles user registration, login, profile management, and
/// logout functionality through a REST API, allowing it to be easily
/// integrated into multiple Flutter projects.
/// 
/// ## Features
/// 
/// - **User Registration**: Complete signup flow with validation
/// - **User Authentication**: Secure login with token management
/// - **Profile Management**: Retrieve and manage user profiles
/// - **Secure Token Storage**: Automatic token storage using flutter_secure_storage
/// - **Reactive State Management**: Real-time authentication state updates
/// - **Comprehensive Error Handling**: Structured error responses with field-level validation
/// - **Network Resilience**: Timeout handling and retry mechanisms
/// - **Testing Support**: Mock implementations and test utilities
/// 
/// ## Quick Start
/// 
/// ```dart
/// import 'package:question_auth/question_auth.dart';
/// 
/// void main() {
///   // Configure the authentication package
///   QuestionAuth.instance.configure(
///     baseUrl: 'https://your-api.com/api/v1/',
///   );
///   
///   runApp(MyApp());
/// }
/// 
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: AuthWrapper(),
///     );
///   }
/// }
/// 
/// class AuthWrapper extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return StreamBuilder<AuthState>(
///       stream: QuestionAuth.instance.authStateStream,
///       builder: (context, snapshot) {
///         final authState = snapshot.data ?? const AuthState.unknown();
///         
///         switch (authState.status) {
///           case AuthStatus.authenticated:
///             return HomeScreen(user: authState.user!);
///           case AuthStatus.unauthenticated:
///             return LoginScreen();
///           case AuthStatus.unknown:
///           default:
///             return SplashScreen();
///         }
///       },
///     );
///   }
/// }
/// ```
/// 
/// ## Authentication Flow
/// 
/// ### User Registration
/// 
/// ```dart
/// final result = await QuestionAuth.instance.signUp(
///   SignUpRequest(
///     email: 'user@example.com',
///     username: 'username',
///     password: 'password123',
///     confirmPassword: 'password123',
///   ),
/// );
/// 
/// if (result.success) {
///   print('User registered: ${result.user?.username}');
/// } else {
///   print('Registration failed: ${result.error}');
///   // Handle field-specific errors
///   result.fieldErrors?.forEach((field, errors) {
///     print('$field: ${errors.join(', ')}');
///   });
/// }
/// ```
/// 
/// ### User Login
/// 
/// ```dart
/// final result = await QuestionAuth.instance.login(
///   LoginRequest(
///     email: 'user@example.com',
///     password: 'password123',
///   ),
/// );
/// 
/// if (result.success) {
///   print('Login successful: ${result.user?.username}');
/// } else {
///   print('Login failed: ${result.error}');
/// }
/// ```
/// 
/// ### Get Current User
/// 
/// ```dart
/// try {
///   final user = await QuestionAuth.instance.getCurrentUser();
///   print('Current user: ${user.username}');
/// } on ApiException catch (e) {
///   print('Failed to get user: ${e.message}');
/// } on NetworkException catch (e) {
///   print('Network error: ${e.message}');
/// }
/// ```
/// 
/// ### Logout
/// 
/// ```dart
/// await QuestionAuth.instance.logout();
/// print('User logged out');
/// ```
/// 
/// ## State Management
/// 
/// The package provides reactive state management through streams:
/// 
/// ```dart
/// // Listen to authentication state changes
/// QuestionAuth.instance.authStateStream.listen((authState) {
///   switch (authState.status) {
///     case AuthStatus.authenticated:
///       print('User is authenticated: ${authState.user?.username}');
///       break;
///     case AuthStatus.unauthenticated:
///       print('User is not authenticated');
///       if (authState.error != null) {
///         print('Error: ${authState.error}');
///       }
///       break;
///     case AuthStatus.unknown:
///       print('Authentication status unknown');
///       break;
///   }
/// });
/// 
/// // Check current authentication status
/// if (QuestionAuth.instance.isAuthenticated) {
///   final user = QuestionAuth.instance.currentUser;
///   print('Currently logged in as: ${user?.username}');
/// }
/// ```
/// 
/// ## Error Handling
/// 
/// The package provides comprehensive error handling with specific exception types:
/// 
/// - `NetworkException`: Network connectivity issues
/// - `ApiException`: Server-side errors with HTTP status codes
/// - `ValidationException`: Client-side validation errors with field details
/// - `TokenException`: Token-related errors (expired, invalid, etc.)
/// 
/// ## Testing
/// 
/// The package includes comprehensive testing utilities:
/// 
/// ```dart
/// import 'package:question_auth/question_auth.dart';
/// 
/// void main() {
///   group('Authentication Tests', () {
///     setUp(() {
///       QuestionAuth.reset(); // Reset singleton for testing
///     });
///     
///     testWidgets('should show login screen when unauthenticated', (tester) async {
///       // Use test utilities
///       final mockAuthService = MockAuthService();
///       when(mockAuthService.authStateStream)
///           .thenAnswer((_) => Stream.value(const AuthState.unauthenticated()));
///       
///       await tester.pumpWidget(
///         AuthTestWidget(
///           mockAuthService: mockAuthService,
///           child: MyApp(),
///         ),
///       );
///       
///       expect(find.byType(LoginScreen), findsOneWidget);
///     });
///   });
/// }
/// ```
/// 
/// ## Configuration
/// 
/// Advanced configuration options:
/// 
/// ```dart
/// QuestionAuth.instance.configure(
///   baseUrl: 'https://your-api.com/api/v1/',
///   apiVersion: 'v2',
///   timeout: const Duration(seconds: 45),
///   enableLogging: true,
///   defaultHeaders: {
///     'X-Client-Version': '1.0.0',
///     'Accept': 'application/json',
///   },
/// );
/// ```
library question_auth;

// Core exports - Authentication state and error handling
export 'src/core/auth_state.dart' show 
    AuthState, 
    AuthStatus, 
    AuthStateNotifier;
export 'src/core/exceptions.dart' show 
    AuthException,
    NetworkException,
    ValidationException,
    ApiException,
    TokenException;

// Model exports - Data models for requests and responses
export 'src/models/user.dart' show User;
export 'src/models/auth_request.dart' show 
    SignUpRequest, 
    LoginRequest;
export 'src/models/auth_response.dart' show 
    AuthResponse,
    SignUpResponse,
    SignUpData,
    LoginResponse,
    UserProfileResponse,
    LogoutResponse;
export 'src/models/auth_result.dart' show AuthResult;

// Service exports - Main authentication services
export 'src/services/auth_service.dart' show AuthService, AuthServiceImpl;
export 'src/services/question_auth.dart' show 
    QuestionAuth, 
    AuthConfig;

// Repository exports - For advanced usage and dependency injection
export 'src/repositories/auth_repository.dart' show AuthRepository, AuthRepositoryImpl;

// Token manager exports - For advanced token management
export 'src/core/token_manager.dart' show TokenManager, SecureTokenManager;

// API client exports - For advanced usage and dependency injection
export 'src/services/api_client.dart' show ApiClient, HttpApiClient;