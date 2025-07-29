import 'dart:async';

import '../models/auth_request.dart';
import '../models/auth_result.dart';
import '../models/user.dart';
import '../core/auth_state.dart';
import '../services/auth_service.dart';
import '../repositories/auth_repository.dart';
import '../services/api_client.dart';
import '../core/token_manager.dart';

/// Configuration class for QuestionAuth
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

/// Main QuestionAuth singleton entry point
/// 
/// This class provides the primary API for the authentication package,
/// implementing a singleton pattern for easy access throughout the application.
class QuestionAuth {
  static QuestionAuth? _instance;
  AuthService? _authService;
  AuthConfig? _config;
  bool _isConfigured = false;
  
  /// Private constructor for singleton pattern
  QuestionAuth._();
  
  /// Get the singleton instance of QuestionAuth
  static QuestionAuth get instance => _instance ??= QuestionAuth._();
  
  /// Configure the QuestionAuth instance with the required settings
  /// 
  /// [baseUrl] - The base URL for the authentication API
  /// [apiVersion] - Optional API version (defaults to 'v1')
  /// [timeout] - Optional request timeout (defaults to 30 seconds)
  /// [enableLogging] - Optional logging flag (defaults to false)
  /// [defaultHeaders] - Optional default headers for all requests
  /// 
  /// This method must be called before using any authentication methods.
  void configure({
    required String baseUrl,
    String? apiVersion,
    Duration? timeout,
    bool? enableLogging,
    Map<String, String>? defaultHeaders,
  }) {
    _config = AuthConfig(
      baseUrl: baseUrl,
      apiVersion: apiVersion ?? 'v1',
      timeout: timeout ?? const Duration(seconds: 30),
      enableLogging: enableLogging ?? false,
      defaultHeaders: defaultHeaders ?? const {},
    );
    
    // Initialize dependencies
    final tokenManager = SecureTokenManager();
    final apiClient = HttpApiClient(
      baseUrl: _config!.baseUrl,
      timeout: _config!.timeout,
      defaultHeaders: _config!.defaultHeaders,
    );
    final repository = AuthRepositoryImpl(
      apiClient: apiClient,
      tokenManager: tokenManager,
    );
    
    _authService = AuthServiceImpl(repository: repository);
    _isConfigured = true;
  }
  
  /// Ensures that QuestionAuth is configured before use
  void _ensureConfigured() {
    if (!_isConfigured || _authService == null) {
      throw StateError(
        'QuestionAuth must be configured before use. Call QuestionAuth.instance.configure() first.',
      );
    }
  }
  
  /// Initialize the authentication service
  /// 
  /// This method should be called during app startup to restore
  /// authentication state from stored tokens.
  Future<void> initialize() async {
    _ensureConfigured();
    await _authService!.initialize();
  }
  
  /// Register a new user account
  /// 
  /// [request] - The signup request containing user registration data
  /// 
  /// Returns [AuthResult] with registration result
  Future<AuthResult> signUp(SignUpRequest request) async {
    _ensureConfigured();
    return await _authService!.signUp(request);
  }
  
  /// Authenticate a user with email and password
  /// 
  /// [request] - The login request containing credentials
  /// 
  /// Returns [AuthResult] with authentication result
  Future<AuthResult> login(LoginRequest request) async {
    _ensureConfigured();
    return await _authService!.login(request);
  }
  
  /// Retrieve the current authenticated user's profile
  /// 
  /// Returns [User] profile data
  /// Throws exceptions if user is not authenticated or network errors occur
  Future<User> getCurrentUser() async {
    _ensureConfigured();
    return await _authService!.getCurrentUser();
  }
  
  /// Log out the current user
  /// 
  /// Clears the stored authentication token and updates authentication state
  Future<void> logout() async {
    _ensureConfigured();
    await _authService!.logout();
  }
  
  /// Stream of authentication state changes
  /// 
  /// Listen to this stream to react to authentication state changes
  /// throughout the application.
  Stream<AuthState> get authStateStream {
    _ensureConfigured();
    return _authService!.authStateStream;
  }
  
  /// Check if the user is currently authenticated
  /// 
  /// Returns true if user is authenticated, false otherwise
  bool get isAuthenticated {
    if (!_isConfigured || _authService == null) {
      return false;
    }
    return _authService!.isAuthenticated;
  }
  
  /// Get the current authenticated user
  /// 
  /// Returns the current [User] if authenticated, null otherwise
  User? get currentUser {
    if (!_isConfigured || _authService == null) {
      return null;
    }
    return _authService!.currentUser;
  }
  
  /// Get the current authentication state
  /// 
  /// Returns the current [AuthState]
  AuthState get currentAuthState {
    if (!_isConfigured || _authService == null) {
      return const AuthState(status: AuthStatus.unknown);
    }
    return _authService!.currentAuthState;
  }
  
  /// Reset the singleton instance (primarily for testing)
  /// 
  /// This method clears the singleton instance and configuration,
  /// allowing for fresh initialization in tests.
  static void reset() {
    _instance = null;
  }
}