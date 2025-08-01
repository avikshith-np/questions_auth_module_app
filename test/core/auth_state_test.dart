import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/core/auth_state.dart';
import 'package:question_auth/src/models/user.dart';
import 'package:question_auth/src/models/auth_response.dart';

void main() {
  group('AuthStatus', () {
    test('should have correct enum values', () {
      expect(AuthStatus.values, [
        AuthStatus.unknown,
        AuthStatus.authenticated,
        AuthStatus.unauthenticated,
      ]);
    });
  });

  group('AuthState', () {
    const testUser = User(
      email: 'test@example.com',
      displayName: 'Test User',
    );

    final testRoles = ['student', 'creator'];
    final testProfileComplete = {'student': true, 'creator': false};
    final testAvailableRoles = ['creator'];
    final testIncompleteRoles = ['creator'];

    final testLoginResponse = LoginResponse(
      token: 'test_token',
      user: testUser,
      roles: testRoles,
      profileComplete: testProfileComplete,
      onboardingComplete: true,
      incompleteRoles: testIncompleteRoles,
      appAccess: 'full',
      redirectTo: '/dashboard',
    );

    final testUserProfileResponse = UserProfileResponse(
      user: testUser,
      isNew: false,
      mode: 'student',
      roles: testRoles,
      availableRoles: testAvailableRoles,
      removableRoles: [],
      profileComplete: testProfileComplete,
      onboardingComplete: true,
      incompleteRoles: testIncompleteRoles,
      appAccess: 'full',
      viewType: 'student-complete',
      redirectTo: '/dashboard',
    );

    group('constructors', () {
      test('should create state with required status', () {
        const state = AuthState(status: AuthStatus.unknown);
        
        expect(state.status, AuthStatus.unknown);
        expect(state.user, isNull);
        expect(state.error, isNull);
        expect(state.userRoles, isNull);
        expect(state.profileComplete, isNull);
        expect(state.onboardingComplete, isNull);
        expect(state.appAccess, isNull);
      });

      test('should create state with user and profile data', () {
        final state = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
          availableRoles: testAvailableRoles,
          incompleteRoles: testIncompleteRoles,
          mode: 'student',
          viewType: 'student-complete',
          redirectTo: '/dashboard',
        );
        
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(state.error, 'test error');
        expect(state.userRoles, testRoles);
        expect(state.profileComplete, testProfileComplete);
        expect(state.onboardingComplete, true);
        expect(state.appAccess, 'full');
        expect(state.availableRoles, testAvailableRoles);
        expect(state.incompleteRoles, testIncompleteRoles);
        expect(state.mode, 'student');
        expect(state.viewType, 'student-complete');
        expect(state.redirectTo, '/dashboard');
      });

      test('unknown() should create unknown state', () {
        const state = AuthState.unknown();
        
        expect(state.status, AuthStatus.unknown);
        expect(state.user, isNull);
        expect(state.error, isNull);
        expect(state.userRoles, isNull);
        expect(state.profileComplete, isNull);
        expect(state.onboardingComplete, isNull);
        expect(state.appAccess, isNull);
      });

      test('authenticated() should create authenticated state with user', () {
        const state = AuthState.authenticated(testUser);
        
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(state.error, isNull);
        expect(state.userRoles, isNull);
        expect(state.profileComplete, isNull);
        expect(state.onboardingComplete, isNull);
        expect(state.appAccess, isNull);
      });

      test('authenticated() should create authenticated state with profile data', () {
        final state = AuthState.authenticated(
          testUser,
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
          availableRoles: testAvailableRoles,
          incompleteRoles: testIncompleteRoles,
          mode: 'student',
          viewType: 'student-complete',
          redirectTo: '/dashboard',
        );
        
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(state.userRoles, testRoles);
        expect(state.profileComplete, testProfileComplete);
        expect(state.onboardingComplete, true);
        expect(state.appAccess, 'full');
        expect(state.availableRoles, testAvailableRoles);
        expect(state.incompleteRoles, testIncompleteRoles);
        expect(state.mode, 'student');
        expect(state.viewType, 'student-complete');
        expect(state.redirectTo, '/dashboard');
      });

      test('fromLoginResponse() should create authenticated state from LoginResponse', () {
        final state = AuthState.fromLoginResponse(testLoginResponse);
        
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(state.userRoles, testRoles);
        expect(state.profileComplete, testProfileComplete);
        expect(state.onboardingComplete, true);
        expect(state.appAccess, 'full');
        expect(state.incompleteRoles, testIncompleteRoles);
        expect(state.redirectTo, '/dashboard');
        expect(state.availableRoles, isNull); // Not in LoginResponse
        expect(state.mode, isNull); // Not in LoginResponse
        expect(state.viewType, isNull); // Not in LoginResponse
      });

      test('fromUserProfileResponse() should create authenticated state from UserProfileResponse', () {
        final state = AuthState.fromUserProfileResponse(testUserProfileResponse);
        
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(state.userRoles, testRoles);
        expect(state.profileComplete, testProfileComplete);
        expect(state.onboardingComplete, true);
        expect(state.appAccess, 'full');
        expect(state.availableRoles, testAvailableRoles);
        expect(state.incompleteRoles, testIncompleteRoles);
        expect(state.mode, 'student');
        expect(state.viewType, 'student-complete');
        expect(state.redirectTo, '/dashboard');
      });

      test('unauthenticated() should create unauthenticated state', () {
        const state = AuthState.unauthenticated();
        
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
        expect(state.error, isNull);
        expect(state.userRoles, isNull);
        expect(state.profileComplete, isNull);
        expect(state.onboardingComplete, isNull);
        expect(state.appAccess, isNull);
      });

      test('unauthenticated() should create unauthenticated state with error', () {
        const state = AuthState.unauthenticated('Login failed');
        
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
        expect(state.error, 'Login failed');
        expect(state.userRoles, isNull);
        expect(state.profileComplete, isNull);
        expect(state.onboardingComplete, isNull);
        expect(state.appAccess, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated status', () {
        const original = AuthState.unknown();
        final updated = original.copyWith(status: AuthStatus.authenticated);
        
        expect(updated.status, AuthStatus.authenticated);
        expect(updated.user, isNull);
        expect(updated.error, isNull);
        expect(updated.userRoles, isNull);
        expect(updated.profileComplete, isNull);
      });

      test('should create copy with updated user', () {
        const original = AuthState.unknown();
        final updated = original.copyWith(user: testUser);
        
        expect(updated.status, AuthStatus.unknown);
        expect(updated.user, testUser);
        expect(updated.error, isNull);
      });

      test('should create copy with updated profile data', () {
        const original = AuthState.unknown();
        final updated = original.copyWith(
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
          availableRoles: testAvailableRoles,
          incompleteRoles: testIncompleteRoles,
          mode: 'student',
          viewType: 'student-complete',
          redirectTo: '/dashboard',
        );
        
        expect(updated.status, AuthStatus.unknown);
        expect(updated.userRoles, testRoles);
        expect(updated.profileComplete, testProfileComplete);
        expect(updated.onboardingComplete, true);
        expect(updated.appAccess, 'full');
        expect(updated.availableRoles, testAvailableRoles);
        expect(updated.incompleteRoles, testIncompleteRoles);
        expect(updated.mode, 'student');
        expect(updated.viewType, 'student-complete');
        expect(updated.redirectTo, '/dashboard');
      });

      test('should create copy with all fields updated', () {
        const original = AuthState.unknown();
        final updated = original.copyWith(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
        );
        
        expect(updated.status, AuthStatus.authenticated);
        expect(updated.user, testUser);
        expect(updated.error, 'test error');
        expect(updated.userRoles, testRoles);
        expect(updated.profileComplete, testProfileComplete);
        expect(updated.onboardingComplete, true);
        expect(updated.appAccess, 'full');
      });

      test('should preserve original values when not specified', () {
        final original = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'original error',
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
        );
        final updated = original.copyWith(status: AuthStatus.unauthenticated);
        
        expect(updated.status, AuthStatus.unauthenticated);
        expect(updated.user, testUser);
        expect(updated.error, 'original error');
        expect(updated.userRoles, testRoles);
        expect(updated.profileComplete, testProfileComplete);
        expect(updated.onboardingComplete, true);
        expect(updated.appAccess, 'full');
      });

      test('should clear error when clearError is true', () {
        const original = AuthState(
          status: AuthStatus.unauthenticated,
          error: 'test error',
        );
        final updated = original.copyWith(clearError: true);
        
        expect(updated.status, AuthStatus.unauthenticated);
        expect(updated.user, isNull);
        expect(updated.error, isNull);
      });

      test('should clear profile data when clearProfileData is true', () {
        final original = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
          availableRoles: testAvailableRoles,
          incompleteRoles: testIncompleteRoles,
          mode: 'student',
          viewType: 'student-complete',
          redirectTo: '/dashboard',
        );
        final updated = original.copyWith(clearProfileData: true);
        
        expect(updated.status, AuthStatus.authenticated);
        expect(updated.user, testUser);
        expect(updated.userRoles, isNull);
        expect(updated.profileComplete, isNull);
        expect(updated.onboardingComplete, isNull);
        expect(updated.appAccess, isNull);
        expect(updated.availableRoles, isNull);
        expect(updated.incompleteRoles, isNull);
        expect(updated.mode, isNull);
        expect(updated.viewType, isNull);
        expect(updated.redirectTo, isNull);
      });
    });

    group('getters', () {
      test('isAuthenticated should return true for authenticated status', () {
        const state = AuthState.authenticated(testUser);
        expect(state.isAuthenticated, isTrue);
      });

      test('isAuthenticated should return false for non-authenticated status', () {
        const unknownState = AuthState.unknown();
        const unauthenticatedState = AuthState.unauthenticated();
        
        expect(unknownState.isAuthenticated, isFalse);
        expect(unauthenticatedState.isAuthenticated, isFalse);
      });

      test('isUnauthenticated should return true for unauthenticated status', () {
        const state = AuthState.unauthenticated();
        expect(state.isUnauthenticated, isTrue);
      });

      test('isUnauthenticated should return false for non-unauthenticated status', () {
        const unknownState = AuthState.unknown();
        const authenticatedState = AuthState.authenticated(testUser);
        
        expect(unknownState.isUnauthenticated, isFalse);
        expect(authenticatedState.isUnauthenticated, isFalse);
      });

      test('isUnknown should return true for unknown status', () {
        const state = AuthState.unknown();
        expect(state.isUnknown, isTrue);
      });

      test('isUnknown should return false for non-unknown status', () {
        const authenticatedState = AuthState.authenticated(testUser);
        const unauthenticatedState = AuthState.unauthenticated();
        
        expect(authenticatedState.isUnknown, isFalse);
        expect(unauthenticatedState.isUnknown, isFalse);
      });

      test('hasRole should return true when user has the role', () {
        final state = AuthState.authenticated(
          testUser,
          userRoles: testRoles,
        );
        
        expect(state.hasRole('student'), isTrue);
        expect(state.hasRole('creator'), isTrue);
        expect(state.hasRole('admin'), isFalse);
      });

      test('hasRole should return false when userRoles is null', () {
        const state = AuthState.authenticated(testUser);
        
        expect(state.hasRole('student'), isFalse);
        expect(state.hasRole('creator'), isFalse);
      });

      test('isProfileCompleteForRole should return correct value', () {
        final state = AuthState.authenticated(
          testUser,
          profileComplete: testProfileComplete,
        );
        
        expect(state.isProfileCompleteForRole('student'), isTrue);
        expect(state.isProfileCompleteForRole('creator'), isFalse);
        expect(state.isProfileCompleteForRole('admin'), isFalse);
      });

      test('isProfileCompleteForRole should return false when profileComplete is null', () {
        const state = AuthState.authenticated(testUser);
        
        expect(state.isProfileCompleteForRole('student'), isFalse);
        expect(state.isProfileCompleteForRole('creator'), isFalse);
      });

      test('hasFullAppAccess should return true when appAccess is full', () {
        final state = AuthState.authenticated(
          testUser,
          appAccess: 'full',
        );
        
        expect(state.hasFullAppAccess, isTrue);
      });

      test('hasFullAppAccess should return false when appAccess is not full', () {
        final state1 = AuthState.authenticated(
          testUser,
          appAccess: 'limited',
        );
        const state2 = AuthState.authenticated(testUser);
        
        expect(state1.hasFullAppAccess, isFalse);
        expect(state2.hasFullAppAccess, isFalse);
      });

      test('hasIncompleteRoles should return true when there are incomplete roles', () {
        final state = AuthState.authenticated(
          testUser,
          incompleteRoles: testIncompleteRoles,
        );
        
        expect(state.hasIncompleteRoles, isTrue);
      });

      test('hasIncompleteRoles should return false when there are no incomplete roles', () {
        final state1 = AuthState.authenticated(
          testUser,
          incompleteRoles: [],
        );
        const state2 = AuthState.authenticated(testUser);
        
        expect(state1.hasIncompleteRoles, isFalse);
        expect(state2.hasIncompleteRoles, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final state1 = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
        );
        final state2 = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
        );
        
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when status differs', () {
        const state1 = AuthState.authenticated(testUser);
        const state2 = AuthState.unauthenticated();
        
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when user differs', () {
        const user2 = User(
          email: 'test2@example.com',
          displayName: 'Test User 2',
        );
        
        const state1 = AuthState.authenticated(testUser);
        const state2 = AuthState.authenticated(user2);
        
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when error differs', () {
        const state1 = AuthState.unauthenticated('error1');
        const state2 = AuthState.unauthenticated('error2');
        
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when userRoles differs', () {
        final state1 = AuthState.authenticated(
          testUser,
          userRoles: ['student'],
        );
        final state2 = AuthState.authenticated(
          testUser,
          userRoles: ['creator'],
        );
        
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when profileComplete differs', () {
        final state1 = AuthState.authenticated(
          testUser,
          profileComplete: {'student': true},
        );
        final state2 = AuthState.authenticated(
          testUser,
          profileComplete: {'student': false},
        );
        
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when onboardingComplete differs', () {
        final state1 = AuthState.authenticated(
          testUser,
          onboardingComplete: true,
        );
        final state2 = AuthState.authenticated(
          testUser,
          onboardingComplete: false,
        );
        
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when appAccess differs', () {
        final state1 = AuthState.authenticated(
          testUser,
          appAccess: 'full',
        );
        final state2 = AuthState.authenticated(
          testUser,
          appAccess: 'limited',
        );
        
        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        final state = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
        );
        
        final result = state.toString();
        expect(result, contains('AuthState'));
        expect(result, contains('authenticated'));
        expect(result, contains('test error'));
        expect(result, contains('student'));
        expect(result, contains('creator'));
        expect(result, contains('full'));
      });
    });
  });

  group('AuthStateNotifier', () {
    late AuthStateNotifier notifier;
    const testUser = User(
      email: 'test@example.com',
      displayName: 'Test User',
    );

    final testRoles = ['student', 'creator'];
    final testProfileComplete = {'student': true, 'creator': false};
    final testAvailableRoles = ['creator'];
    final testIncompleteRoles = ['creator'];

    final testLoginResponse = LoginResponse(
      token: 'test_token',
      user: testUser,
      roles: testRoles,
      profileComplete: testProfileComplete,
      onboardingComplete: true,
      incompleteRoles: testIncompleteRoles,
      appAccess: 'full',
      redirectTo: '/dashboard',
    );

    final testUserProfileResponse = UserProfileResponse(
      user: testUser,
      isNew: false,
      mode: 'student',
      roles: testRoles,
      availableRoles: testAvailableRoles,
      removableRoles: [],
      profileComplete: testProfileComplete,
      onboardingComplete: true,
      incompleteRoles: testIncompleteRoles,
      appAccess: 'full',
      viewType: 'student-complete',
      redirectTo: '/dashboard',
    );

    setUp(() {
      notifier = AuthStateNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    group('initialization', () {
      test('should start with unknown state', () {
        expect(notifier.value.status, AuthStatus.unknown);
        expect(notifier.value.user, isNull);
        expect(notifier.value.error, isNull);
        expect(notifier.value.userRoles, isNull);
        expect(notifier.value.profileComplete, isNull);
        expect(notifier.value.onboardingComplete, isNull);
        expect(notifier.value.appAccess, isNull);
      });
    });

    group('setAuthenticated', () {
      test('should set authenticated state with user', () {
        notifier.setAuthenticated(testUser);
        
        expect(notifier.value.status, AuthStatus.authenticated);
        expect(notifier.value.user, testUser);
        expect(notifier.value.error, isNull);
        expect(notifier.value.userRoles, isNull);
        expect(notifier.value.profileComplete, isNull);
      });

      test('should notify listeners when state changes', () {
        bool notified = false;
        notifier.addListener(() {
          notified = true;
        });
        
        notifier.setAuthenticated(testUser);
        
        expect(notified, isTrue);
      });
    });

    group('setAuthenticatedWithProfile', () {
      test('should set authenticated state with user and profile data', () {
        notifier.setAuthenticatedWithProfile(
          testUser,
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
          availableRoles: testAvailableRoles,
          incompleteRoles: testIncompleteRoles,
          mode: 'student',
          viewType: 'student-complete',
          redirectTo: '/dashboard',
        );
        
        expect(notifier.value.status, AuthStatus.authenticated);
        expect(notifier.value.user, testUser);
        expect(notifier.value.userRoles, testRoles);
        expect(notifier.value.profileComplete, testProfileComplete);
        expect(notifier.value.onboardingComplete, true);
        expect(notifier.value.appAccess, 'full');
        expect(notifier.value.availableRoles, testAvailableRoles);
        expect(notifier.value.incompleteRoles, testIncompleteRoles);
        expect(notifier.value.mode, 'student');
        expect(notifier.value.viewType, 'student-complete');
        expect(notifier.value.redirectTo, '/dashboard');
      });

      test('should notify listeners when state changes', () {
        bool notified = false;
        notifier.addListener(() {
          notified = true;
        });
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
        );
        
        expect(notified, isTrue);
      });
    });

    group('setAuthenticatedFromLoginResponse', () {
      test('should set authenticated state from LoginResponse', () {
        notifier.setAuthenticatedFromLoginResponse(testLoginResponse);
        
        expect(notifier.value.status, AuthStatus.authenticated);
        expect(notifier.value.user, testUser);
        expect(notifier.value.userRoles, testRoles);
        expect(notifier.value.profileComplete, testProfileComplete);
        expect(notifier.value.onboardingComplete, true);
        expect(notifier.value.appAccess, 'full');
        expect(notifier.value.incompleteRoles, testIncompleteRoles);
        expect(notifier.value.redirectTo, '/dashboard');
      });

      test('should notify listeners when state changes', () {
        bool notified = false;
        notifier.addListener(() {
          notified = true;
        });
        
        notifier.setAuthenticatedFromLoginResponse(testLoginResponse);
        
        expect(notified, isTrue);
      });
    });

    group('setAuthenticatedFromUserProfileResponse', () {
      test('should set authenticated state from UserProfileResponse', () {
        notifier.setAuthenticatedFromUserProfileResponse(testUserProfileResponse);
        
        expect(notifier.value.status, AuthStatus.authenticated);
        expect(notifier.value.user, testUser);
        expect(notifier.value.userRoles, testRoles);
        expect(notifier.value.profileComplete, testProfileComplete);
        expect(notifier.value.onboardingComplete, true);
        expect(notifier.value.appAccess, 'full');
        expect(notifier.value.availableRoles, testAvailableRoles);
        expect(notifier.value.incompleteRoles, testIncompleteRoles);
        expect(notifier.value.mode, 'student');
        expect(notifier.value.viewType, 'student-complete');
        expect(notifier.value.redirectTo, '/dashboard');
      });

      test('should notify listeners when state changes', () {
        bool notified = false;
        notifier.addListener(() {
          notified = true;
        });
        
        notifier.setAuthenticatedFromUserProfileResponse(testUserProfileResponse);
        
        expect(notified, isTrue);
      });
    });

    group('updateProfileData', () {
      test('should update profile data when authenticated', () {
        // First authenticate
        notifier.setAuthenticated(testUser);
        
        // Then update profile data
        notifier.updateProfileData(
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
        );
        
        expect(notifier.value.status, AuthStatus.authenticated);
        expect(notifier.value.user, testUser);
        expect(notifier.value.userRoles, testRoles);
        expect(notifier.value.profileComplete, testProfileComplete);
        expect(notifier.value.onboardingComplete, true);
        expect(notifier.value.appAccess, 'full');
      });

      test('should not update profile data when not authenticated', () {
        // Start with unauthenticated state
        notifier.setUnauthenticated();
        
        // Try to update profile data
        notifier.updateProfileData(
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
        );
        
        expect(notifier.value.status, AuthStatus.unauthenticated);
        expect(notifier.value.userRoles, isNull);
        expect(notifier.value.profileComplete, isNull);
        expect(notifier.value.onboardingComplete, isNull);
        expect(notifier.value.appAccess, isNull);
      });

      test('should notify listeners when profile data is updated', () {
        notifier.setAuthenticated(testUser);
        
        bool notified = false;
        notifier.addListener(() {
          notified = true;
        });
        
        notifier.updateProfileData(
          userRoles: testRoles,
          profileComplete: testProfileComplete,
        );
        
        expect(notified, isTrue);
      });
    });

    group('setUnauthenticated', () {
      test('should set unauthenticated state without error', () {
        notifier.setUnauthenticated();
        
        expect(notifier.value.status, AuthStatus.unauthenticated);
        expect(notifier.value.user, isNull);
        expect(notifier.value.error, isNull);
      });

      test('should set unauthenticated state with error', () {
        notifier.setUnauthenticated('Login failed');
        
        expect(notifier.value.status, AuthStatus.unauthenticated);
        expect(notifier.value.user, isNull);
        expect(notifier.value.error, 'Login failed');
      });

      test('should notify listeners when state changes', () {
        bool notified = false;
        notifier.addListener(() {
          notified = true;
        });
        
        notifier.setUnauthenticated();
        
        expect(notified, isTrue);
      });
    });

    group('setUnknown', () {
      test('should set unknown state', () {
        // First set to authenticated
        notifier.setAuthenticated(testUser);
        
        // Then set to unknown
        notifier.setUnknown();
        
        expect(notifier.value.status, AuthStatus.unknown);
        expect(notifier.value.user, isNull);
        expect(notifier.value.error, isNull);
      });

      test('should notify listeners when state changes', () {
        notifier.setAuthenticated(testUser);
        
        bool notified = false;
        notifier.addListener(() {
          notified = true;
        });
        
        notifier.setUnknown();
        
        expect(notified, isTrue);
      });
    });

    group('clearError', () {
      test('should clear error when present', () {
        notifier.setUnauthenticated('Login failed');
        expect(notifier.value.error, 'Login failed');
        
        notifier.clearError();
        
        expect(notifier.value.status, AuthStatus.unauthenticated);
        expect(notifier.value.user, isNull);
        expect(notifier.value.error, isNull);
      });

      test('should not change state when no error present', () {
        notifier.setAuthenticated(testUser);
        final originalState = notifier.value;
        
        notifier.clearError();
        
        expect(notifier.value, equals(originalState));
      });

      test('should notify listeners when error is cleared', () {
        notifier.setUnauthenticated('Login failed');
        
        bool notified = false;
        notifier.addListener(() {
          notified = true;
        });
        
        notifier.clearError();
        
        expect(notified, isTrue);
      });
    });

    group('clearProfileData', () {
      test('should clear profile data when present', () {
        notifier.setAuthenticatedWithProfile(
          testUser,
          userRoles: testRoles,
          profileComplete: testProfileComplete,
          onboardingComplete: true,
          appAccess: 'full',
          availableRoles: testAvailableRoles,
          incompleteRoles: testIncompleteRoles,
          mode: 'student',
          viewType: 'student-complete',
          redirectTo: '/dashboard',
        );
        
        notifier.clearProfileData();
        
        expect(notifier.value.status, AuthStatus.authenticated);
        expect(notifier.value.user, testUser);
        expect(notifier.value.userRoles, isNull);
        expect(notifier.value.profileComplete, isNull);
        expect(notifier.value.onboardingComplete, isNull);
        expect(notifier.value.appAccess, isNull);
        expect(notifier.value.availableRoles, isNull);
        expect(notifier.value.incompleteRoles, isNull);
        expect(notifier.value.mode, isNull);
        expect(notifier.value.viewType, isNull);
        expect(notifier.value.redirectTo, isNull);
      });

      test('should notify listeners when profile data is cleared', () {
        notifier.setAuthenticatedWithProfile(
          testUser,
          userRoles: testRoles,
          profileComplete: testProfileComplete,
        );
        
        bool notified = false;
        notifier.addListener(() {
          notified = true;
        });
        
        notifier.clearProfileData();
        
        expect(notified, isTrue);
      });
    });

    group('convenience getters', () {
      test('isAuthenticated should return correct value', () {
        expect(notifier.isAuthenticated, isFalse);
        
        notifier.setAuthenticated(testUser);
        expect(notifier.isAuthenticated, isTrue);
        
        notifier.setUnauthenticated();
        expect(notifier.isAuthenticated, isFalse);
      });

      test('isUnauthenticated should return correct value', () {
        expect(notifier.isUnauthenticated, isFalse);
        
        notifier.setUnauthenticated();
        expect(notifier.isUnauthenticated, isTrue);
        
        notifier.setAuthenticated(testUser);
        expect(notifier.isUnauthenticated, isFalse);
      });

      test('isUnknown should return correct value', () {
        expect(notifier.isUnknown, isTrue);
        
        notifier.setAuthenticated(testUser);
        expect(notifier.isUnknown, isFalse);
        
        notifier.setUnknown();
        expect(notifier.isUnknown, isTrue);
      });

      test('currentUser should return correct value', () {
        expect(notifier.currentUser, isNull);
        
        notifier.setAuthenticated(testUser);
        expect(notifier.currentUser, testUser);
        
        notifier.setUnauthenticated();
        expect(notifier.currentUser, isNull);
      });

      test('currentError should return correct value', () {
        expect(notifier.currentError, isNull);
        
        notifier.setUnauthenticated('Login failed');
        expect(notifier.currentError, 'Login failed');
        
        notifier.clearError();
        expect(notifier.currentError, isNull);
      });

      test('currentUserRoles should return correct value', () {
        expect(notifier.currentUserRoles, isNull);
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          userRoles: testRoles,
        );
        expect(notifier.currentUserRoles, testRoles);
        
        notifier.setUnauthenticated();
        expect(notifier.currentUserRoles, isNull);
      });

      test('currentProfileComplete should return correct value', () {
        expect(notifier.currentProfileComplete, isNull);
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          profileComplete: testProfileComplete,
        );
        expect(notifier.currentProfileComplete, testProfileComplete);
        
        notifier.setUnauthenticated();
        expect(notifier.currentProfileComplete, isNull);
      });

      test('currentOnboardingComplete should return correct value', () {
        expect(notifier.currentOnboardingComplete, isNull);
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          onboardingComplete: true,
        );
        expect(notifier.currentOnboardingComplete, true);
        
        notifier.setUnauthenticated();
        expect(notifier.currentOnboardingComplete, isNull);
      });

      test('currentAppAccess should return correct value', () {
        expect(notifier.currentAppAccess, isNull);
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          appAccess: 'full',
        );
        expect(notifier.currentAppAccess, 'full');
        
        notifier.setUnauthenticated();
        expect(notifier.currentAppAccess, isNull);
      });

      test('currentAvailableRoles should return correct value', () {
        expect(notifier.currentAvailableRoles, isNull);
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          availableRoles: testAvailableRoles,
        );
        expect(notifier.currentAvailableRoles, testAvailableRoles);
        
        notifier.setUnauthenticated();
        expect(notifier.currentAvailableRoles, isNull);
      });

      test('currentIncompleteRoles should return correct value', () {
        expect(notifier.currentIncompleteRoles, isNull);
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          incompleteRoles: testIncompleteRoles,
        );
        expect(notifier.currentIncompleteRoles, testIncompleteRoles);
        
        notifier.setUnauthenticated();
        expect(notifier.currentIncompleteRoles, isNull);
      });

      test('currentMode should return correct value', () {
        expect(notifier.currentMode, isNull);
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          mode: 'student',
        );
        expect(notifier.currentMode, 'student');
        
        notifier.setUnauthenticated();
        expect(notifier.currentMode, isNull);
      });

      test('currentViewType should return correct value', () {
        expect(notifier.currentViewType, isNull);
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          viewType: 'student-complete',
        );
        expect(notifier.currentViewType, 'student-complete');
        
        notifier.setUnauthenticated();
        expect(notifier.currentViewType, isNull);
      });

      test('currentRedirectTo should return correct value', () {
        expect(notifier.currentRedirectTo, isNull);
        
        notifier.setAuthenticatedWithProfile(
          testUser,
          redirectTo: '/dashboard',
        );
        expect(notifier.currentRedirectTo, '/dashboard');
        
        notifier.setUnauthenticated();
        expect(notifier.currentRedirectTo, isNull);
      });
    });

    group('stream functionality', () {
      test('should emit states to stream when changes occur', () async {
        final states = <AuthState>[];
        final subscription = notifier.stream.listen((state) {
          states.add(state);
        });
        
        // Authenticate - this should trigger stream emission
        notifier.setAuthenticated(testUser);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(states.length, greaterThanOrEqualTo(1));
        expect(states.last.status, AuthStatus.authenticated);
        expect(states.last.user, testUser);
        
        // Update with profile data
        notifier.setAuthenticatedFromLoginResponse(testLoginResponse);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(states.length, greaterThanOrEqualTo(2));
        expect(states.last.userRoles, testRoles);
        expect(states.last.profileComplete, testProfileComplete);
        
        await subscription.cancel();
      });
    });

    group('state transitions', () {
      test('should handle complete authentication flow', () {
        final states = <AuthState>[];
        notifier.addListener(() {
          states.add(notifier.value);
        });
        
        // Start with unknown (initial state, no notification)
        expect(notifier.value.status, AuthStatus.unknown);
        
        // Authenticate
        notifier.setAuthenticated(testUser);
        expect(states.length, 1);
        expect(states.last.status, AuthStatus.authenticated);
        expect(states.last.user, testUser);
        
        // Logout
        notifier.setUnauthenticated();
        expect(states.length, 2);
        expect(states.last.status, AuthStatus.unauthenticated);
        expect(states.last.user, isNull);
        expect(states.last.userRoles, isNull);
        expect(states.last.profileComplete, isNull);
        
        // Reset to unknown
        notifier.setUnknown();
        expect(states.length, 3);
        expect(states.last.status, AuthStatus.unknown);
      });

      test('should handle authentication failure flow', () {
        final states = <AuthState>[];
        notifier.addListener(() {
          states.add(notifier.value);
        });
        
        // Fail authentication
        notifier.setUnauthenticated('Invalid credentials');
        expect(states.length, 1);
        expect(states.last.status, AuthStatus.unauthenticated);
        expect(states.last.error, 'Invalid credentials');
        
        // Clear error
        notifier.clearError();
        expect(states.length, 2);
        expect(states.last.status, AuthStatus.unauthenticated);
        expect(states.last.error, isNull);
        
        // Successful authentication
        notifier.setAuthenticated(testUser);
        expect(states.length, 3);
        expect(states.last.status, AuthStatus.authenticated);
        expect(states.last.user, testUser);
        expect(states.last.error, isNull);
      });

      test('should handle authentication with profile data flow', () {
        final states = <AuthState>[];
        notifier.addListener(() {
          states.add(notifier.value);
        });
        
        // Authenticate with login response
        notifier.setAuthenticatedFromLoginResponse(testLoginResponse);
        expect(states.length, 1);
        expect(states.last.status, AuthStatus.authenticated);
        expect(states.last.user, testUser);
        expect(states.last.userRoles, testRoles);
        expect(states.last.profileComplete, testProfileComplete);
        expect(states.last.onboardingComplete, true);
        expect(states.last.appAccess, 'full');
        
        // Update with user profile response
        notifier.setAuthenticatedFromUserProfileResponse(testUserProfileResponse);
        expect(states.length, 2);
        expect(states.last.status, AuthStatus.authenticated);
        expect(states.last.user, testUser);
        expect(states.last.userRoles, testRoles);
        expect(states.last.availableRoles, testAvailableRoles);
        expect(states.last.mode, 'student');
        expect(states.last.viewType, 'student-complete');
        
        // Update profile data
        notifier.updateProfileData(
          onboardingComplete: false,
          appAccess: 'limited',
        );
        expect(states.length, 3);
        expect(states.last.onboardingComplete, false);
        expect(states.last.appAccess, 'limited');
        
        // Clear profile data
        notifier.clearProfileData();
        expect(states.length, 4);
        expect(states.last.status, AuthStatus.authenticated);
        expect(states.last.user, testUser);
        expect(states.last.userRoles, isNull);
        expect(states.last.profileComplete, isNull);
        expect(states.last.onboardingComplete, isNull);
        expect(states.last.appAccess, isNull);
      });
    });
  });
}