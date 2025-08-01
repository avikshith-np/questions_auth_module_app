import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/auth_result.dart';
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
  /// Returns [AuthResult] with registration result and signup data
  /// Throws [ValidationException] for validation errors
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  Future<AuthResult> signUp(SignUpRequest request);
  
  /// Authenticates a user with email and password
  /// 
  /// [request] - The login request containing credentials
  /// 
  /// Returns [AuthResult] with authentication result, token, and rich user profile data
  /// Throws [ValidationException] for validation errors
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  Future<AuthResult> login(LoginRequest request);
  
  /// Retrieves the current authenticated user's profile
  /// 
  /// Returns [UserProfileResponse] with comprehensive user profile data
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  /// Throws [TokenException] if no valid token is available
  Future<UserProfileResponse> getCurrentUser();
  
  /// Logs out the current user
  /// 
  /// Clears the stored authentication token
  /// Throws [ApiException] for API-related errors
  /// Throws [NetworkException] for network-related errors
  Future<void> logout();
  
  /// Check if there is a stored authentication token
  /// 
  /// Returns true if a token is stored, false otherwise
  Future<bool> hasStoredToken();
  
  /// Check if the stored token is expired
  /// 
  /// Returns true if token is expired or invalid, false if valid
  Future<bool> isTokenExpired();
  
  /// Clear expired token from storage
  /// 
  /// This method clears both the token from storage and API client
  Future<void> clearExpiredToken();
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
  Future<AuthResult> signUp(SignUpRequest request) async {
    try {
      // Validate request before making API call
      final validationErrors = request.validate();
      if (validationErrors.isNotEmpty) {
        final fieldErrors = <String, List<String>>{
          'general': validationErrors,
        };
        throw ValidationException('Validation failed', fieldErrors);
      }
      
      // Make API call using the new register endpoint
      final signUpResponse = await _apiClient.register(request);
      
      // Return successful AuthResult with signup data
      return AuthResult.success(
        signUpData: signUpResponse,
      );
    } catch (e) {
      if (e is ValidationException) {
        return AuthResult.failure(
          error: e.message,
          fieldErrors: e.fieldErrors,
        );
      } else if (e is ApiException) {
        return AuthResult.failure(error: e.message);
      } else if (e is NetworkException) {
        return AuthResult.failure(error: e.message);
      } else {
        return AuthResult.failure(
          error: 'Unexpected error during signup: ${e.toString()}',
        );
      }
    }
  }

  @override
  Future<AuthResult> login(LoginRequest request) async {
    try {
      // Validate request before making API call
      final validationErrors = request.validate();
      if (validationErrors.isNotEmpty) {
        final fieldErrors = <String, List<String>>{
          'general': validationErrors,
        };
        throw ValidationException('Validation failed', fieldErrors);
      }
      
      // Make API call using the new login endpoint
      final loginResponse = await _apiClient.login(request);
      
      // Store token and set it in API client
      await _tokenManager.saveToken(loginResponse.token);
      _apiClient.setAuthToken(loginResponse.token);
      
      // Return successful AuthResult with rich user profile data
      return AuthResult.success(
        user: loginResponse.user,
        token: loginResponse.token,
        loginData: loginResponse,
      );
    } catch (e) {
      if (e is ValidationException) {
        return AuthResult.failure(
          error: e.message,
          fieldErrors: e.fieldErrors,
        );
      } else if (e is ApiException) {
        return AuthResult.failure(error: e.message);
      } else if (e is NetworkException) {
        return AuthResult.failure(error: e.message);
      } else {
        return AuthResult.failure(
          error: 'Unexpected error during login: ${e.toString()}',
        );
      }
    }
  }

  @override
  Future<UserProfileResponse> getCurrentUser() async {
    try {
      // Check if we have a valid token
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw TokenException('No authentication token available');
      }
      
      // Set the token in API client
      _apiClient.setAuthToken(token);
      
      // Make API call to get comprehensive user profile
      final userProfileResponse = await _apiClient.getCurrentUser();
      
      return userProfileResponse;
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
      
      // If we have a token, try to logout from server using the new logout endpoint
      if (token != null) {
        try {
          _apiClient.setAuthToken(token);
          await _apiClient.logout();
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
  
  @override
  Future<bool> hasStoredToken() async {
    try {
      return await _tokenManager.hasValidToken();
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> isTokenExpired() async {
    try {
      return await _tokenManager.isTokenExpired();
    } catch (e) {
      // If we can't determine expiration status, assume expired for security
      return true;
    }
  }
  
  @override
  Future<void> clearExpiredToken() async {
    try {
      await _tokenManager.clearToken();
      _apiClient.clearAuthToken();
    } catch (e) {
      // Ensure we always try to clear even if there's an error
      try {
        await _tokenManager.clearToken();
      } catch (_) {}
      try {
        _apiClient.clearAuthToken();
      } catch (_) {}
      
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Unexpected error clearing expired token: ${e.toString()}');
    }
  }
}