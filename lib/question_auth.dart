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
///     displayName: 'John Doe',
///     password: 'password123',
///     confirmPassword: 'password123',
///   ),
/// );
/// 
/// if (result.success) {
///   print('Registration successful!');
///   if (result.signUpData != null) {
///     print('Verification email sent to: ${result.signUpData!.data?.email}');
///     print('Token expires in: ${result.signUpData!.data?.verificationTokenExpiresIn}');
///   }
/// } else {
///   print('Registration failed: ${result.error}');
///   // Handle field-specific errors
///   result.fieldErrors?.forEach((field, errors) {
///     print('$field: ${errors.join(', ')}');
///   });
/// }
/// ```
/// 
/// ### User Login with Rich Profile Data
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
///   print('Login successful: ${result.user?.displayName}');
///   
///   // Access rich login data
///   if (result.loginData != null) {
///     final loginData = result.loginData!;
///     print('User roles: ${loginData.roles}');
///     print('Profile completion status: ${loginData.profileComplete}');
///     print('Onboarding complete: ${loginData.onboardingComplete}');
///     print('App access level: ${loginData.appAccess}');
///     print('Redirect to: ${loginData.redirectTo}');
///     
///     // Check specific role completion
///     if (loginData.profileComplete['creator'] == true) {
///       print('Creator profile is complete');
///     }
///     
///     // Handle incomplete roles
///     if (loginData.incompleteRoles.isNotEmpty) {
///       print('Incomplete roles: ${loginData.incompleteRoles}');
///     }
///   }
/// } else {
///   print('Login failed: ${result.error}');
/// }
/// ```
/// 
/// ### Get Current User Profile with Enhanced Data
/// 
/// ```dart
/// try {
///   final userProfile = await QuestionAuth.instance.getCurrentUser();
///   
///   // Basic user information
///   print('User: ${userProfile.user.displayName}');
///   print('Email: ${userProfile.user.email}');
///   print('Email verified: ${userProfile.user.emailVerified}');
///   print('Account active: ${userProfile.user.isActive}');
///   
///   // Profile status and roles
///   print('Current mode: ${userProfile.mode}');
///   print('User roles: ${userProfile.roles}');
///   print('Available roles: ${userProfile.availableRoles}');
///   print('Removable roles: ${userProfile.removableRoles}');
///   
///   // Profile completion status
///   print('Profile completion: ${userProfile.profileComplete}');
///   print('Onboarding complete: ${userProfile.onboardingComplete}');
///   print('Incomplete roles: ${userProfile.incompleteRoles}');
///   
///   // App access and navigation
///   print('App access: ${userProfile.appAccess}');
///   print('View type: ${userProfile.viewType}');
///   print('Redirect to: ${userProfile.redirectTo}');
///   
///   // Check specific conditions
///   if (userProfile.isNew) {
///     print('This is a new user');
///   }
///   
///   if (userProfile.appAccess == 'full') {
///     print('User has full app access');
///   }
///   
///   // Handle profile completion
///   userProfile.profileComplete.forEach((role, isComplete) {
///     if (!isComplete) {
///       print('$role profile needs completion');
///     }
///   });
///   
/// } on ApiException catch (e) {
///   print('Failed to get user profile: ${e.message}');
/// } on NetworkException catch (e) {
///   print('Network error: ${e.message}');
/// }
/// ```
/// 
/// ### Accessing User Profile Data from QuestionAuth Instance
/// 
/// ```dart
/// // Quick access to user profile information
/// if (QuestionAuth.instance.isAuthenticated) {
///   // Basic user info
///   final user = QuestionAuth.instance.currentUser;
///   print('Current user: ${user?.displayName}');
///   
///   // User roles and permissions
///   final roles = QuestionAuth.instance.userRoles;
///   print('User roles: $roles');
///   
///   // Profile completion status
///   final profileComplete = QuestionAuth.instance.profileComplete;
///   print('Profile completion: $profileComplete');
///   
///   // Onboarding status
///   final onboardingComplete = QuestionAuth.instance.onboardingComplete;
///   print('Onboarding complete: $onboardingComplete');
///   
///   // App access level
///   final appAccess = QuestionAuth.instance.appAccess;
///   print('App access: $appAccess');
///   
///   // Check specific role completion
///   if (profileComplete?['student'] == true) {
///     print('Student profile is complete');
///   }
///   
///   // Check if user has specific role
///   if (roles?.contains('creator') == true) {
///     print('User is a creator');
///   }
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
///       print('User is authenticated: ${authState.user?.displayName}');
///       
///       // Access user profile data from state
///       if (authState.userProfileData != null) {
///         final profileData = authState.userProfileData!;
///         print('User roles: ${profileData.roles}');
///         print('Profile complete: ${profileData.profileComplete}');
///         print('App access: ${profileData.appAccess}');
///       }
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
/// // Check current authentication status with profile data
/// if (QuestionAuth.instance.isAuthenticated) {
///   final user = QuestionAuth.instance.currentUser;
///   print('Currently logged in as: ${user?.displayName}');
///   
///   // Access profile information
///   final roles = QuestionAuth.instance.userRoles;
///   final profileComplete = QuestionAuth.instance.profileComplete;
///   final onboardingComplete = QuestionAuth.instance.onboardingComplete;
///   final appAccess = QuestionAuth.instance.appAccess;
///   
///   print('Roles: $roles');
///   print('Profile complete: $profileComplete');
///   print('Onboarding complete: $onboardingComplete');
///   print('App access: $appAccess');
/// }
/// ```
/// 
/// ## API Response Models
/// 
/// The package provides comprehensive response models for all API endpoints:
/// 
/// ### SignUpResponse
/// 
/// ```dart
/// // After successful registration
/// final result = await QuestionAuth.instance.signUp(request);
/// if (result.success && result.signUpData != null) {
///   final signUpResponse = result.signUpData!;
///   print('Message: ${signUpResponse.detail}');
///   
///   if (signUpResponse.data != null) {
///     print('Email: ${signUpResponse.data!.email}');
///     print('Token expires in: ${signUpResponse.data!.verificationTokenExpiresIn}');
///   }
/// }
/// ```
/// 
/// ### LoginResponse
/// 
/// ```dart
/// // After successful login
/// final result = await QuestionAuth.instance.login(request);
/// if (result.success && result.loginData != null) {
///   final loginResponse = result.loginData!;
///   
///   print('Token: ${loginResponse.token}');
///   print('User: ${loginResponse.user.displayName}');
///   print('Roles: ${loginResponse.roles}');
///   print('Profile complete: ${loginResponse.profileComplete}');
///   print('Onboarding complete: ${loginResponse.onboardingComplete}');
///   print('Incomplete roles: ${loginResponse.incompleteRoles}');
///   print('App access: ${loginResponse.appAccess}');
///   print('Redirect to: ${loginResponse.redirectTo}');
/// }
/// ```
/// 
/// ### UserProfileResponse
/// 
/// ```dart
/// // Get detailed user profile
/// final userProfile = await QuestionAuth.instance.getCurrentUser();
/// 
/// print('User: ${userProfile.user.displayName}');
/// print('Is new user: ${userProfile.isNew}');
/// print('Current mode: ${userProfile.mode}');
/// print('Roles: ${userProfile.roles}');
/// print('Available roles: ${userProfile.availableRoles}');
/// print('Removable roles: ${userProfile.removableRoles}');
/// print('Profile complete: ${userProfile.profileComplete}');
/// print('Onboarding complete: ${userProfile.onboardingComplete}');
/// print('Incomplete roles: ${userProfile.incompleteRoles}');
/// print('App access: ${userProfile.appAccess}');
/// print('View type: ${userProfile.viewType}');
/// print('Redirect to: ${userProfile.redirectTo}');
/// ```
/// 
/// ### LogoutResponse
/// 
/// ```dart
/// // After logout
/// await QuestionAuth.instance.logout();
/// // LogoutResponse is handled internally, but you can access it through the API client if needed
/// ```
/// 
/// ## User Profile Data Management
/// 
/// The package provides rich user profile data management with automatic persistence:
/// 
/// ```dart
/// // Profile data is automatically stored and restored
/// class ProfileManager {
///   static void handleUserProfile(UserProfileResponse profile) {
///     // Check user roles and customize UI
///     if (profile.roles.contains('creator')) {
///       showCreatorFeatures();
///     }
///     
///     if (profile.roles.contains('student')) {
///       showStudentFeatures();
///     }
///     
///     // Handle profile completion
///     profile.profileComplete.forEach((role, isComplete) {
///       if (!isComplete) {
///         showProfileCompletionPrompt(role);
///       }
///     });
///     
///     // Handle onboarding
///     if (!profile.onboardingComplete) {
///       navigateToOnboarding(profile.redirectTo);
///     }
///     
///     // Handle app access
///     switch (profile.appAccess) {
///       case 'full':
///         enableAllFeatures();
///         break;
///       case 'limited':
///         enableLimitedFeatures();
///         break;
///       case 'restricted':
///         showRestrictedAccess();
///         break;
///     }
///   }
///   
///   static void showCreatorFeatures() {
///     // Show creator-specific UI elements
///   }
///   
///   static void showStudentFeatures() {
///     // Show student-specific UI elements
///   }
///   
///   static void showProfileCompletionPrompt(String role) {
///     // Show profile completion UI for specific role
///   }
///   
///   static void navigateToOnboarding(String redirectTo) {
///     // Navigate to onboarding flow
///   }
///   
///   static void enableAllFeatures() {
///     // Enable all app features
///   }
///   
///   static void enableLimitedFeatures() {
///     // Enable limited app features
///   }
///   
///   static void showRestrictedAccess() {
///     // Show restricted access message
///   }
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
library;

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
export 'src/core/token_manager.dart' show TokenManager, SecureTokenManager, UserProfileData;

// API client exports - For advanced usage and dependency injection
export 'src/services/api_client.dart' show ApiClient, HttpApiClient;