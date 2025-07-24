import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../core/token_manager.dart';
import '../core/exceptions.dart';

/// Abstract interface for authentication repository operations
abstract class AuthRepository {
  /// Registers a new user account
  /// 
  /// [request] - The signup request containing user registration data
  /// 
  /// Returns [AuthResponse] with registration result
  /// Throws [ValidationException] for validation errors
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  Future<AuthResponse> signUp(SignUpRequest request);
  
  /// Authenticates a user with email and password
  /// 
  /// [request] - The login request containing credentials
  /// 
  /// Returns [AuthResponse] with authentication result and token
  /// Throws [ValidationException] for validation errors
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  Future<AuthResponse> login(LoginRequest request);
  
  /// Retrieves the current authenticated user's profile
  /// 
  /// Returns [User] profile data
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  /// Throws [TokenException] if no valid token is available
  Future<User> getCurrentUser();
  
  /// Logs out the current user
  /// 
  /// Clears the stored authentication token
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  Future<void> logout();
}

/// Implementation of AuthRepository using HTTP API client and token manager
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;
  
  /// Creates an AuthRepositoryImpl instance
  /// 
  /// [apiClient] - The API client for HTTP operations
  /// [tokenManager] - The token manager for secure token storage
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required TokenManager tokenManager,
  }) : _apiClient = apiClient,
       _tokenManager = tokenManager;

  @override
  Future<AuthResponse> signUp(SignUpRequest request) async {
    try {
      // Validate request before making API call
      final validationErrors = request.validate();
      if (validationErrors.isNotEmpty) {
        final fieldErrors = <String, List<String>>{
          'general': validationErrors,
        };
        throw ValidationException('Validation failed', fieldErrors);
      }
      
      // Make API call
      final response = await _apiClient.post('accounts/signup/', request.toJson());
      
      // Parse response
      final authResponse = AuthResponse.fromJson(response);
      
      // Store token if login was successful
      if (authResponse.success && authResponse.token != null) {
        await _tokenManager.saveToken(authResponse.token!);
        _apiClient.setAuthToken(authResponse.token!);
      }
      
      return authResponse;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Unexpected error during signup: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      // Validate request before making API call
      final validationErrors = request.validate();
      if (validationErrors.isNotEmpty) {
        final fieldErrors = <String, List<String>>{
          'general': validationErrors,
        };
        throw ValidationException('Validation failed', fieldErrors);
      }
      
      // Make API call
      final response = await _apiClient.post('accounts/login/', request.toJson());
      
      // Parse response
      final authResponse = AuthResponse.fromJson(response);
      
      // Store token if login was successful
      if (authResponse.success && authResponse.token != null) {
        await _tokenManager.saveToken(authResponse.token!);
        _apiClient.setAuthToken(authResponse.token!);
      }
      
      return authResponse;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Unexpected error during login: ${e.toString()}');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      // Check if we have a valid token
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw TokenException('No authentication token available');
      }
      
      // Set the token in API client
      _apiClient.setAuthToken(token);
      
      // Make API call to get user profile
      final response = await _apiClient.get('accounts/me/');
      
      // Parse and return user data
      return User.fromJson(response);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Unexpected error getting user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Get current token
      final token = await _tokenManager.getToken();
      
      // If we have a token, try to logout from server
      if (token != null) {
        try {
          _apiClient.setAuthToken(token);
          await _apiClient.post('logout/', {});
        } catch (e) {
          // Even if server logout fails, we still clear local token for security
          // Log the error but don't throw it
        }
      }
      
      // Always clear local token and API client token
      await _tokenManager.clearToken();
      _apiClient.clearAuthToken();
    } catch (e) {
      // Ensure we always clear the token even if there's an error
      await _tokenManager.clearToken();
      _apiClient.clearAuthToken();
      
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Unexpected error during logout: ${e.toString()}');
    }
  }
}