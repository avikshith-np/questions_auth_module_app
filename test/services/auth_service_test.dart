import 'package:flutter_test/flutter_test.dart';

import 'package:question_auth/src/services/auth_service.dart';
import 'package:question_auth/src/repositories/auth_repository.dart';
import 'package:question_auth/src/core/auth_state.dart';
import 'package:question_auth/src/models/auth_request.dart';
import 'package:question_auth/src/models/auth_response.dart';
import 'package:question_auth/src/models/auth_result.dart';
import 'package:question_auth/src/models/user.dart';
import 'package:question_auth/src/core/exceptions.dart';

// Mock repository for testing
class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> signUp(SignUpRequest request) async {
    final signUpResponse = SignUpResponse(
      detail: 'Registration successful! Please check your email to verify your account.',
      data: SignUpData(
        email: request.email,
        verificationTokenExpiresIn: '10 minutes',
      ),
    );
    
    return AuthResult.success(signUpData: signUpResponse);
  }

  @override
  Future<AuthResult> login(LoginRequest request) async {
    final user = User(
      email: request.email,
      displayName: 'Test User',
      isVerified: true,
      isNew: false,
    );
    
    final loginResponse = LoginResponse(
      token: 'test_token_123',
      user: user,
      roles: ['Creator', 'Student'],
      profileComplete: {'creator': true, 'student': false},
      onboardingComplete: true,
      incompleteRoles: ['student'],
      appAccess: 'full',
      redirectTo: '/dashboard',
    );
    
    return AuthResult.success(
      user: user,
      token: 'test_token_123',
      loginData: loginResponse,
    );
  }

  @override
  Future<UserProfileResponse> getCurrentUser() async {
    final user = User(
      email: 'test@example.com',
      displayName: 'Test User',
      isActive: true,
      emailVerified: true,
      isVerified: true,
      isNew: false,
      dateJoined: DateTime(2024, 1, 1),
    );
    
    return UserProfileResponse(
      user: user,
      isNew: false,
      mode: 'creator',
      roles: ['Creator', 'Student'],
      availableRoles: ['Creator'],
      removableRoles: [],
      profileComplete: {'creator': true, 'student': false},
      onboardingComplete: true,
      incompleteRoles: ['student'],
      appAccess: 'full',
      viewType: 'creator-complete-creator-only',
      redirectTo: '/dashboard',
    );
  }

  @override
  Future<void> logout() async {
    // Mock logout
  }
  
  @override
  Future<bool> hasStoredToken() async {
    return true;
  }
  
  @override
  Future<bool> isTokenExpired() async {
    return false;
  }
  
  @override
  Future<void> clearExpiredToken() async {
    // Mock clear expired token
  }
}

// Mock repository that throws validation exception
class _ValidationErrorMockRepository implements AuthRepository {
  @override
  Future<AuthResult> signUp(SignUpRequest request) async {
    throw ValidationException('Invalid credentials', {'email': ['Invalid email format']});
  }

  @override
  Future<AuthResult> login(LoginRequest request) async {
    throw ValidationException('Invalid credentials', {'email': ['Invalid email format']});
  }

  @override
  Future<UserProfileResponse> getCurrentUser() async {
    throw ValidationException('Invalid request', {'general': ['Validation failed']});
  }

  @override
  Future<void> logout() async {}
  
  @override
  Future<bool> hasStoredToken() async => false;
  
  @override
  Future<bool> isTokenExpired() async => true;
  
  @override
  Future<void> clearExpiredToken() async {}
}

// Mock repository that throws API exception
class _ApiErrorMockRepository implements AuthRepository {
  @override
  Future<AuthResult> signUp(SignUpRequest request) async {
    throw ApiException('Unauthorized', 401);
  }

  @override
  Future<AuthResult> login(LoginRequest request) async {
    throw ApiException('Unauthorized', 401);
  }

  @override
  Future<UserProfileResponse> getCurrentUser() async {
    throw ApiException('Unauthorized', 401);
  }

  @override
  Future<void> logout() async {}
  
  @override
  Future<bool> hasStoredToken() async => false;
  
  @override
  Future<bool> isTokenExpired() async => true;
  
  @override
  Future<void> clearExpiredToken() async {}
}

// Mock repository that throws network exception
class _NetworkErrorMockRepository implements AuthRepository {
  @override
  Future<AuthResult> signUp(SignUpRequest request) async {
    throw NetworkException('Network connection failed');
  }

  @override
  Future<AuthResult> login(LoginRequest request) async {
    throw NetworkException('Network connection failed');
  }

  @override
  Future<UserProfileResponse> getCurrentUser() async {
    throw NetworkException('Network connection failed');
  }

  @override
  Future<void> logout() async {}
  
  @override
  Future<bool> hasStoredToken() async => false;
  
  @override
  Future<bool> isTokenExpired() async => true;
  
  @override
  Future<void> clearExpiredToken() async {}
}

void main() {
  group('AuthService Enhanced Functionality Tests', () {
    late AuthService authService;
    late MockAuthRepository mockRepository;
    late AuthStateNotifier stateNotifier;

    setUp(() {
      mockRepository = MockAuthRepository();
      stateNotifier = AuthStateNotifier();
      authService = AuthServiceImpl(
        repository: mockRepository,
        stateNotifier: stateNotifier,
      );
    });

    tearDown(() {
      stateNotifier.dispose();
    });

    test('should create AuthServiceImpl instance', () {
      expect(authService, isA<AuthServiceImpl>());
      expect(authService.isAuthenticated, false);
    });

    test('should handle successful signup', () async {
      final request = SignUpRequest(
        email: 'test@example.com',
        displayName: 'Test User',
        password: 'password123',
        confirmPassword: 'password123',
      );

      final result = await authService.signUp(request);

      expect(result.success, true);
      expect(result.signUpData?.detail, contains('Registration successful'));
      expect(result.signUpData?.data?.email, 'test@example.com');
      // Signup doesn't authenticate the user, so they should still be unauthenticated
      expect(authService.isAuthenticated, false);
    });

    test('should handle successful login with rich user profile data', () async {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final result = await authService.login(request);

      expect(result.success, true);
      expect(result.user?.email, 'test@example.com');
      expect(result.loginData?.token, 'test_token_123');
      expect(authService.isAuthenticated, true);
      
      // Test user profile data access
      expect(authService.userRoles, contains('Creator'));
      expect(authService.userRoles, contains('Student'));
      expect(authService.profileComplete?['creator'], true);
      expect(authService.profileComplete?['student'], false);
      expect(authService.onboardingComplete, true);
      expect(authService.appAccess, 'full');
      expect(authService.incompleteRoles, contains('student'));
      expect(authService.redirectTo, '/dashboard');
    });

    test('should provide user profile helper methods', () async {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      await authService.login(request);

      // Test helper methods
      expect(authService.hasRole('Creator'), true);
      expect(authService.hasRole('Admin'), false);
      expect(authService.isProfileCompleteForRole('creator'), true);
      expect(authService.isProfileCompleteForRole('student'), false);
      expect(authService.hasFullAppAccess, true);
      expect(authService.hasIncompleteRoles, true);
    });

    test('should handle getCurrentUser with rich profile data', () async {
      final userProfile = await authService.getCurrentUser();

      expect(userProfile.user.email, 'test@example.com');
      expect(userProfile.user.displayName, 'Test User');
      expect(userProfile.roles, contains('Creator'));
      expect(userProfile.roles, contains('Student'));
      expect(userProfile.profileComplete['creator'], true);
      expect(userProfile.profileComplete['student'], false);
      expect(userProfile.onboardingComplete, true);
      expect(userProfile.appAccess, 'full');
      expect(userProfile.mode, 'creator');
      expect(userProfile.viewType, 'creator-complete-creator-only');
      expect(userProfile.availableRoles, contains('Creator'));
      expect(userProfile.incompleteRoles, contains('student'));
      
      // Verify state is updated with profile data
      expect(authService.isAuthenticated, true);
      expect(authService.userRoles, contains('Creator'));
      expect(authService.mode, 'creator');
      expect(authService.viewType, 'creator-complete-creator-only');
      expect(authService.availableRoles, contains('Creator'));
    });

    test('should handle logout and clear profile data', () async {
      // First login to set profile data
      final loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );
      await authService.login(loginRequest);
      expect(authService.isAuthenticated, true);
      expect(authService.userRoles, isNotNull);
      expect(authService.profileComplete, isNotNull);

      // Then logout
      await authService.logout();
      expect(authService.isAuthenticated, false);
      expect(authService.currentUser, null);
      expect(authService.userRoles, null);
      expect(authService.profileComplete, null);
      expect(authService.onboardingComplete, null);
      expect(authService.appAccess, null);
      expect(authService.availableRoles, null);
      expect(authService.incompleteRoles, null);
      expect(authService.mode, null);
      expect(authService.viewType, null);
      expect(authService.redirectTo, null);
    });

    test('should initialize with existing user and profile data', () async {
      await authService.initialize();
      
      expect(authService.isAuthenticated, true);
      expect(authService.currentUser?.email, 'test@example.com');
      expect(authService.userRoles, contains('Creator'));
      expect(authService.profileComplete?['creator'], true);
      expect(authService.onboardingComplete, true);
      expect(authService.appAccess, 'full');
      expect(authService.mode, 'creator');
      expect(authService.availableRoles, contains('Creator'));
    });

    test('should handle authentication state stream with profile data', () async {
      final stateChanges = <AuthState>[];
      
      // Check initial state directly
      expect(authService.currentAuthState.status, AuthStatus.unknown);
      
      final subscription = authService.authStateStream.listen(stateChanges.add);

      // Login should update state with profile data
      final loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );
      await authService.login(loginRequest);

      // Wait for state change
      await Future.delayed(Duration.zero);

      // Check that we received at least one state change
      expect(stateChanges.length, greaterThanOrEqualTo(1));
      final authenticatedState = stateChanges.last;
      expect(authenticatedState.status, AuthStatus.authenticated);
      expect(authenticatedState.user?.email, 'test@example.com');
      expect(authenticatedState.userRoles, contains('Creator'));
      expect(authenticatedState.profileComplete?['creator'], true);
      expect(authenticatedState.onboardingComplete, true);
      expect(authenticatedState.appAccess, 'full');

      await subscription.cancel();
    });

    test('should handle validation errors during login', () async {
      // Create a custom mock repository that throws validation exception
      final mockRepo = _ValidationErrorMockRepository();
      
      final service = AuthServiceImpl(repository: mockRepo);
      
      final request = LoginRequest(
        email: 'invalid-email',
        password: 'password123',
      );

      final result = await service.login(request);

      expect(result.success, false);
      expect(result.error, 'Invalid credentials');
      expect(result.fieldErrors?['email'], contains('Invalid email format'));
      expect(service.isAuthenticated, false);
    });

    test('should handle API errors during getCurrentUser', () async {
      // Create a custom mock repository that throws API exception
      final mockRepo = _ApiErrorMockRepository();
      
      final service = AuthServiceImpl(repository: mockRepo);

      expect(
        () => service.getCurrentUser(),
        throwsA(isA<ApiException>()),
      );
      expect(service.isAuthenticated, false);
    });

    test('should handle network errors during login', () async {
      // Create a custom mock repository that throws network exception
      final mockRepo = _NetworkErrorMockRepository();
      
      final service = AuthServiceImpl(repository: mockRepo);
      
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final result = await service.login(request);

      expect(result.success, false);
      expect(result.error, 'Network connection failed');
      expect(service.isAuthenticated, false);
    });
  });
}