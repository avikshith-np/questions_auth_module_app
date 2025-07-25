import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/core/auth_state.dart';
import 'package:question_auth/src/models/user.dart';

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
      id: '1',
      email: 'test@example.com',
      username: 'testuser',
    );

    group('constructors', () {
      test('should create state with required status', () {
        const state = AuthState(status: AuthStatus.unknown);
        
        expect(state.status, AuthStatus.unknown);
        expect(state.user, isNull);
        expect(state.error, isNull);
      });

      test('should create state with user and error', () {
        const state = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
        );
        
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(state.error, 'test error');
      });

      test('unknown() should create unknown state', () {
        const state = AuthState.unknown();
        
        expect(state.status, AuthStatus.unknown);
        expect(state.user, isNull);
        expect(state.error, isNull);
      });

      test('authenticated() should create authenticated state with user', () {
        const state = AuthState.authenticated(testUser);
        
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(state.error, isNull);
      });

      test('unauthenticated() should create unauthenticated state', () {
        const state = AuthState.unauthenticated();
        
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
        expect(state.error, isNull);
      });

      test('unauthenticated() should create unauthenticated state with error', () {
        const state = AuthState.unauthenticated('Login failed');
        
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
        expect(state.error, 'Login failed');
      });
    });

    group('copyWith', () {
      test('should create copy with updated status', () {
        const original = AuthState.unknown();
        final updated = original.copyWith(status: AuthStatus.authenticated);
        
        expect(updated.status, AuthStatus.authenticated);
        expect(updated.user, isNull);
        expect(updated.error, isNull);
      });

      test('should create copy with updated user', () {
        const original = AuthState.unknown();
        final updated = original.copyWith(user: testUser);
        
        expect(updated.status, AuthStatus.unknown);
        expect(updated.user, testUser);
        expect(updated.error, isNull);
      });

      test('should create copy with updated error', () {
        const original = AuthState.unknown();
        final updated = original.copyWith(error: 'test error');
        
        expect(updated.status, AuthStatus.unknown);
        expect(updated.user, isNull);
        expect(updated.error, 'test error');
      });

      test('should create copy with all fields updated', () {
        const original = AuthState.unknown();
        final updated = original.copyWith(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
        );
        
        expect(updated.status, AuthStatus.authenticated);
        expect(updated.user, testUser);
        expect(updated.error, 'test error');
      });

      test('should preserve original values when not specified', () {
        const original = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'original error',
        );
        final updated = original.copyWith(status: AuthStatus.unauthenticated);
        
        expect(updated.status, AuthStatus.unauthenticated);
        expect(updated.user, testUser);
        expect(updated.error, 'original error');
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
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        const state1 = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
        );
        const state2 = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
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
          id: '2',
          email: 'test2@example.com',
          username: 'testuser2',
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
    });

    group('toString', () {
      test('should return string representation', () {
        const state = AuthState(
          status: AuthStatus.authenticated,
          user: testUser,
          error: 'test error',
        );
        
        final result = state.toString();
        expect(result, contains('AuthState'));
        expect(result, contains('authenticated'));
        expect(result, contains('test error'));
      });
    });
  });

  group('AuthStateNotifier', () {
    late AuthStateNotifier notifier;
    const testUser = User(
      id: '1',
      email: 'test@example.com',
      username: 'testuser',
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
      });
    });

    group('setAuthenticated', () {
      test('should set authenticated state with user', () {
        notifier.setAuthenticated(testUser);
        
        expect(notifier.value.status, AuthStatus.authenticated);
        expect(notifier.value.user, testUser);
        expect(notifier.value.error, isNull);
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
    });
  });
}