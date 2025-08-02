import 'dart:async';

import '../models/auth_request.dart';
import '../models/auth_result.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import '../core/auth_state.dart';
import '../core/token_manager.dart';
import '../repositories/auth_repository.dart';
import '../core/exceptions.dart';

abstract class AuthService {
  Future<AuthResult> signUp(SignUpRequest request);
  Future<AuthResult> login(LoginRequest request);
  Future<UserProfileResponse> getCurrentUser();
  Future<void> logout();
  Stream<AuthState> get authStateStream;
  bool get isAuthenticated;
  User? get currentUser;
  AuthState get currentAuthState;
  Future<void> initialize();
  
  // User profile methods
  List<String>? get userRoles;
  Map<String, bool>? get profileComplete;
  bool? get onboardingComplete;
  String? get appAccess;
  List<String>? get availableRoles;
  List<String>? get incompleteRoles;
  String? get mode;
  String? get viewType;
  String? get redirectTo;
  
  // Helper methods for user profile information
  bool hasRole(String role);
  bool isProfileCompleteForRole(String role);
  bool get hasFullAppAccess;
  bool get hasIncompleteRoles;
}

class AuthServiceImpl implements AuthService {
  final AuthRepository _repository;
  final AuthStateNotifier _stateNotifier;
  
  AuthServiceImpl({
    required AuthRepository repository,
    AuthStateNotifier? stateNotifier,
  }) : _repository = repository,
       _stateNotifier = stateNotifier ?? AuthStateNotifier();

  @override
  Stream<AuthState> get authStateStream => _stateNotifier.stream;

  @override
  bool get isAuthenticated => _stateNotifier.isAuthenticated;

  @override
  User? get currentUser => _stateNotifier.currentUser;

  @override
  AuthState get currentAuthState => _stateNotifier.value;

  // User profile methods
  @override
  List<String>? get userRoles => _stateNotifier.currentUserRoles;

  @override
  Map<String, bool>? get profileComplete => _stateNotifier.currentProfileComplete;

  @override
  bool? get onboardingComplete => _stateNotifier.currentOnboardingComplete;

  @override
  String? get appAccess => _stateNotifier.currentAppAccess;

  @override
  List<String>? get availableRoles => _stateNotifier.currentAvailableRoles;

  @override
  List<String>? get incompleteRoles => _stateNotifier.currentIncompleteRoles;

  @override
  String? get mode => _stateNotifier.currentMode;

  @override
  String? get viewType => _stateNotifier.currentViewType;

  @override
  String? get redirectTo => _stateNotifier.currentRedirectTo;

  // Helper methods for user profile information
  @override
  bool hasRole(String role) => currentAuthState.hasRole(role);

  @override
  bool isProfileCompleteForRole(String role) => currentAuthState.isProfileCompleteForRole(role);

  @override
  bool get hasFullAppAccess => currentAuthState.hasFullAppAccess;

  @override
  bool get hasIncompleteRoles => currentAuthState.hasIncompleteRoles;

  @override
  Future<void> initialize() async {
    try {
      // Check if we have a stored token
      final hasToken = await _repository.hasStoredToken();
      if (!hasToken) {
        _stateNotifier.setUnauthenticated();
        return;
      }
      
      // Check if token is expired
      final isExpired = await _repository.isTokenExpired();
      if (isExpired) {
        // Clear expired token and set unauthenticated
        await _repository.clearExpiredToken();
        _stateNotifier.setUnauthenticated('Session expired');
        return;
      }
      
      // Try to restore user profile data from storage first
      UserProfileData? storedProfile;
      if (_repository is AuthRepositoryImpl) {
        storedProfile = await _repository.getStoredUserProfile();
      }
      if (storedProfile != null) {
        // Restore authentication state from stored profile data
        _stateNotifier.setAuthenticatedWithProfile(
          storedProfile.user,
          userRoles: storedProfile.userRoles,
          profileComplete: storedProfile.profileComplete,
          onboardingComplete: storedProfile.onboardingComplete,
          appAccess: storedProfile.appAccess,
          availableRoles: storedProfile.availableRoles,
          incompleteRoles: storedProfile.incompleteRoles,
          mode: storedProfile.mode,
          viewType: storedProfile.viewType,
          redirectTo: storedProfile.redirectTo,
        );
        
        // Try to refresh user profile data from server in background
        try {
          final userProfile = await _repository.getCurrentUser();
          _stateNotifier.setAuthenticatedFromUserProfileResponse(userProfile);
        } catch (e) {
          // If refresh fails, keep the stored profile data
          // This allows offline functionality with cached profile data
        }
      } else {
        // No stored profile data, fetch from server
        final userProfile = await _repository.getCurrentUser();
        _stateNotifier.setAuthenticatedFromUserProfileResponse(userProfile);
      }
    } on TokenException catch (e) {
      // Token is invalid or expired, clear it
      await _repository.clearExpiredToken();
      _stateNotifier.setUnauthenticated(e.message);
    } on ApiException catch (e) {
      // API error (e.g., 401 Unauthorized), likely expired token
      if (e.statusCode == 401) {
        await _repository.clearExpiredToken();
        _stateNotifier.setUnauthenticated('Session expired');
      } else {
        _stateNotifier.setUnauthenticated(e.message);
      }
    } on NetworkException {
      // Network error during initialization - try to use stored profile data
      UserProfileData? storedProfile;
      if (_repository is AuthRepositoryImpl) {
        storedProfile = await _repository.getStoredUserProfile();
      }
      if (storedProfile != null) {
        // Use cached profile data when network is unavailable
        _stateNotifier.setAuthenticatedWithProfile(
          storedProfile.user,
          userRoles: storedProfile.userRoles,
          profileComplete: storedProfile.profileComplete,
          onboardingComplete: storedProfile.onboardingComplete,
          appAccess: storedProfile.appAccess,
          availableRoles: storedProfile.availableRoles,
          incompleteRoles: storedProfile.incompleteRoles,
          mode: storedProfile.mode,
          viewType: storedProfile.viewType,
          redirectTo: storedProfile.redirectTo,
        );
      } else {
        // No cached data and network error - keep unknown state
        _stateNotifier.setUnknown();
      }
    } catch (e) {
      // Unexpected error - try to use stored profile data as fallback
      UserProfileData? storedProfile;
      if (_repository is AuthRepositoryImpl) {
        storedProfile = await _repository.getStoredUserProfile();
      }
      if (storedProfile != null) {
        _stateNotifier.setAuthenticatedWithProfile(
          storedProfile.user,
          userRoles: storedProfile.userRoles,
          profileComplete: storedProfile.profileComplete,
          onboardingComplete: storedProfile.onboardingComplete,
          appAccess: storedProfile.appAccess,
          availableRoles: storedProfile.availableRoles,
          incompleteRoles: storedProfile.incompleteRoles,
          mode: storedProfile.mode,
          viewType: storedProfile.viewType,
          redirectTo: storedProfile.redirectTo,
        );
      } else {
        // No fallback data available - set to unauthenticated for security
        _stateNotifier.setUnauthenticated('Authentication initialization failed');
      }
    }
  }

  @override
  Future<AuthResult> signUp(SignUpRequest request) async {
    try {
      _stateNotifier.clearError();
      final signUpResult = await _repository.signUp(request);
      
      if (signUpResult.success) {
        return signUpResult;
      } else {
        final errorMessage = signUpResult.error ?? 'Signup failed';
        _stateNotifier.setUnauthenticated(errorMessage);
        return signUpResult;
      }
    } on ValidationException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
    } on ApiException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(error: e.message);
    } on NetworkException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(error: e.message);
    } catch (e) {
      const errorMessage = 'An unexpected error occurred during signup';
      _stateNotifier.setUnauthenticated(errorMessage);
      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  Future<AuthResult> login(LoginRequest request) async {
    try {
      _stateNotifier.clearError();
      final loginResult = await _repository.login(request);
      
      if (loginResult.success && loginResult.user != null && loginResult.loginData != null) {
        _stateNotifier.setAuthenticatedFromLoginResponse(loginResult.loginData!);
        return loginResult;
      } else {
        final errorMessage = loginResult.error ?? 'Login failed';
        _stateNotifier.setUnauthenticated(errorMessage);
        return loginResult;
      }
    } on ValidationException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
    } on ApiException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(error: e.message);
    } on NetworkException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      return AuthResult.failure(error: e.message);
    } catch (e) {
      const errorMessage = 'An unexpected error occurred during login';
      _stateNotifier.setUnauthenticated(errorMessage);
      return AuthResult.failure(error: errorMessage);
    }
  }

  @override
  Future<UserProfileResponse> getCurrentUser() async {
    try {
      final userProfile = await _repository.getCurrentUser();
      _stateNotifier.setAuthenticatedFromUserProfileResponse(userProfile);
      return userProfile;
    } on TokenException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      rethrow;
    } on ApiException catch (e) {
      _stateNotifier.setUnauthenticated(e.message);
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (_) {
      _stateNotifier.setUnauthenticated('Failed to get user profile');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Even if repository logout fails, we still want to clear local state
    } finally {
      _stateNotifier.setUnauthenticated();
    }
  }

  /// Update user profile data in storage and state
  /// 
  /// This method allows updating specific fields in the user profile
  /// without making a full API call
  Future<void> updateUserProfile({
    User? user,
    List<String>? userRoles,
    Map<String, bool>? profileComplete,
    bool? onboardingComplete,
    String? appAccess,
    List<String>? availableRoles,
    List<String>? incompleteRoles,
    String? mode,
    String? viewType,
    String? redirectTo,
  }) async {
    try {
      // Update stored profile data
      if (_repository is AuthRepositoryImpl) {
        await _repository.updateStoredUserProfile(
        user: user,
        userRoles: userRoles,
        profileComplete: profileComplete,
        onboardingComplete: onboardingComplete,
        appAccess: appAccess,
        availableRoles: availableRoles,
        incompleteRoles: incompleteRoles,
        mode: mode,
        viewType: viewType,
        redirectTo: redirectTo,
      );
      }

      // Update current authentication state
      _stateNotifier.updateProfileData(
        userRoles: userRoles,
        profileComplete: profileComplete,
        onboardingComplete: onboardingComplete,
        appAccess: appAccess,
        availableRoles: availableRoles,
        incompleteRoles: incompleteRoles,
        mode: mode,
        viewType: viewType,
        redirectTo: redirectTo,
      );
    } catch (e) {
      throw NetworkException('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Refresh user profile data from server
  /// 
  /// This method fetches the latest user profile data from the server
  /// and updates both storage and state
  Future<void> refreshUserProfile() async {
    try {
      final userProfile = await _repository.getCurrentUser();
      _stateNotifier.setAuthenticatedFromUserProfileResponse(userProfile);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user profile data is available in storage
  /// 
  /// Returns true if profile data is cached locally
  Future<bool> hasStoredUserProfile() async {
    try {
      if (_repository is AuthRepositoryImpl) {
        return await _repository.hasStoredUserProfile();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get stored user profile data
  /// 
  /// Returns cached profile data if available, null otherwise
  Future<UserProfileData?> getStoredUserProfile() async {
    try {
      if (_repository is AuthRepositoryImpl) {
        return await _repository.getStoredUserProfile();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}