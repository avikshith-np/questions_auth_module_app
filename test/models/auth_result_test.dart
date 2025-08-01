import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/models/auth_result.dart';
import 'package:question_auth/src/models/user.dart';
import 'package:question_auth/src/models/auth_response.dart';

void main() {
  group('AuthResult Tests', () {
    group('factory constructors', () {
      test('should create successful AuthResult', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'testuser',
        );

        final result = AuthResult.success(user: user);

        expect(result.success, true);
        expect(result.user, user);
        expect(result.error, isNull);
        expect(result.fieldErrors, isNull);
        expect(result.loginData, isNull);
        expect(result.signUpData, isNull);
      });

      test('should create successful AuthResult without user', () {
        final result = AuthResult.success();

        expect(result.success, true);
        expect(result.user, isNull);
        expect(result.error, isNull);
        expect(result.fieldErrors, isNull);
      });

      test('should create failure AuthResult with general error', () {
        final result = AuthResult.failure(error: 'Authentication failed');

        expect(result.success, false);
        expect(result.user, isNull);
        expect(result.error, 'Authentication failed');
        expect(result.fieldErrors, isNull);
      });

      test('should create failure AuthResult with field errors', () {
        final fieldErrors = {
          'email': ['Invalid email format'],
          'password': ['Password too short'],
        };

        final result = AuthResult.failure(
          error: 'Validation failed',
          fieldErrors: fieldErrors,
        );

        expect(result.success, false);
        expect(result.user, isNull);
        expect(result.error, 'Validation failed');
        expect(result.fieldErrors, fieldErrors);
      });
    });

    group('fromAuthResponse', () {
      test('should create success result from successful JSON response', () {
        final jsonResponse = {
          'success': true,
          'token': 'abc123',
          'user': {
            'email': 'test@example.com',
            'display_name': 'testuser',
          },
        };

        final result = AuthResult.fromAuthResponse(jsonResponse);

        expect(result.success, true);
        expect(result.user, isNotNull);
        expect(result.user!.email, 'test@example.com');
        expect(result.user!.displayName, 'testuser');
        expect(result.error, isNull);
        expect(result.fieldErrors, isNull);
      });

      test('should create success result from JSON with token but no explicit success', () {
        final jsonResponse = {
          'token': 'abc123',
          'user': {
            'email': 'test@example.com',
            'display_name': 'testuser',
          },
        };

        final result = AuthResult.fromAuthResponse(jsonResponse);

        expect(result.success, true);
        expect(result.user, isNotNull);
      });

      test('should create failure result from error JSON response', () {
        final jsonResponse = {
          'success': false,
          'message': 'Authentication failed',
          'errors': {
            'email': ['Invalid email'],
            'password': ['Password required'],
          },
        };

        final result = AuthResult.fromAuthResponse(jsonResponse);

        expect(result.success, false);
        expect(result.user, isNull);
        expect(result.error, 'Authentication failed');
        expect(result.fieldErrors, isNotNull);
        expect(result.fieldErrors!['email'], ['Invalid email']);
        expect(result.fieldErrors!['password'], ['Password required']);
      });

      test('should handle null response', () {
        final result = AuthResult.fromAuthResponse(null);

        expect(result.success, false);
        expect(result.error, 'Invalid response format');
      });

      test('should handle invalid response format', () {
        final result = AuthResult.fromAuthResponse('invalid');

        expect(result.success, false);
        expect(result.error, 'Invalid response format');
      });

      test('should parse errors in different formats', () {
        final jsonResponse = {
          'success': false,
          'errors': ['General error 1', 'General error 2'],
        };

        final result = AuthResult.fromAuthResponse(jsonResponse);

        expect(result.success, false);
        expect(result.fieldErrors!['general'], ['General error 1', 'General error 2']);
      });
    });

    group('helper methods', () {
      test('hasFieldErrors should return true when field errors exist', () {
        final result = AuthResult.failure(
          fieldErrors: {'email': ['Invalid email']},
        );

        expect(result.hasFieldErrors, true);
      });

      test('hasFieldErrors should return false when no field errors', () {
        final result = AuthResult.failure(error: 'General error');

        expect(result.hasFieldErrors, false);
      });

      test('hasError should return true when general error exists', () {
        final result = AuthResult.failure(error: 'General error');

        expect(result.hasError, true);
      });

      test('hasError should return false when no general error', () {
        final result = AuthResult.failure(
          fieldErrors: {'email': ['Invalid email']},
        );

        expect(result.hasError, false);
      });

      test('hasAnyErrors should return true when any errors exist', () {
        final result1 = AuthResult.failure(error: 'General error');
        final result2 = AuthResult.failure(
          fieldErrors: {'email': ['Invalid email']},
        );

        expect(result1.hasAnyErrors, true);
        expect(result2.hasAnyErrors, true);
      });

      test('hasAnyErrors should return false when no errors', () {
        final result = AuthResult.success();

        expect(result.hasAnyErrors, false);
      });

      test('allErrorMessages should return all error messages', () {
        final result = AuthResult.failure(
          error: 'General error',
          fieldErrors: {
            'email': ['Email error 1', 'Email error 2'],
            'password': ['Password error'],
          },
        );

        final allErrors = result.allErrorMessages;

        expect(allErrors.length, 4);
        expect(allErrors, contains('General error'));
        expect(allErrors, contains('Email error 1'));
        expect(allErrors, contains('Email error 2'));
        expect(allErrors, contains('Password error'));
      });

      test('firstErrorMessage should prioritize general error', () {
        final result = AuthResult.failure(
          error: 'General error',
          fieldErrors: {'email': ['Email error']},
        );

        expect(result.firstErrorMessage, 'General error');
      });

      test('firstErrorMessage should return first field error if no general error', () {
        final result = AuthResult.failure(
          fieldErrors: {
            'email': ['Email error'],
            'password': ['Password error'],
          },
        );

        expect(result.firstErrorMessage, 'Email error');
      });

      test('firstErrorMessage should return null if no errors', () {
        final result = AuthResult.success();

        expect(result.firstErrorMessage, isNull);
      });

      test('getFieldErrors should return errors for specific field', () {
        final result = AuthResult.failure(
          fieldErrors: {
            'email': ['Email error 1', 'Email error 2'],
            'password': ['Password error'],
          },
        );

        expect(result.getFieldErrors('email'), ['Email error 1', 'Email error 2']);
        expect(result.getFieldErrors('password'), ['Password error']);
        expect(result.getFieldErrors('username'), isNull);
      });

      test('getFirstFieldError should return first error for specific field', () {
        final result = AuthResult.failure(
          fieldErrors: {
            'email': ['Email error 1', 'Email error 2'],
            'password': ['Password error'],
          },
        );

        expect(result.getFirstFieldError('email'), 'Email error 1');
        expect(result.getFirstFieldError('password'), 'Password error');
        expect(result.getFirstFieldError('username'), isNull);
      });
    });

    group('JSON serialization', () {
      test('should convert AuthResult to JSON', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'testuser',
        );

        final result = AuthResult(
          success: true,
          user: user,
          error: 'Some error',
          fieldErrors: {'field': ['error']},
        );

        final json = result.toJson();

        expect(json['success'], true);
        expect(json['user'], user.toJson());
        expect(json['error'], 'Some error');
        expect(json['fieldErrors'], {'field': ['error']});
      });

      test('should create AuthResult from JSON', () {
        final json = {
          'success': true,
          'user': {
            'email': 'test@example.com',
            'display_name': 'testuser',
          },
          'error': 'Some error',
          'fieldErrors': {
            'field': ['error1', 'error2'],
          },
        };

        final result = AuthResult.fromJson(json);

        expect(result.success, true);
        expect(result.user, isNotNull);
        expect(result.user!.email, 'test@example.com');
        expect(result.user!.displayName, 'testuser');
        expect(result.error, 'Some error');
        expect(result.fieldErrors!['field'], ['error1', 'error2']);
      });

      test('should handle null values in JSON', () {
        final json = {
          'success': false,
          'user': null,
          'error': null,
          'fieldErrors': null,
        };

        final result = AuthResult.fromJson(json);

        expect(result.success, false);
        expect(result.user, isNull);
        expect(result.error, isNull);
        expect(result.fieldErrors, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = AuthResult.success();
        final updated = original.copyWith(
          success: false,
          error: 'New error',
        );

        expect(updated.success, false);
        expect(updated.error, 'New error');
        expect(updated.user, original.user);
        expect(updated.fieldErrors, original.fieldErrors);
      });

      test('should keep original values when no updates provided', () {
        final original = AuthResult.failure(error: 'Original error');
        final copy = original.copyWith();

        expect(copy.success, original.success);
        expect(copy.error, original.error);
        expect(copy.user, original.user);
        expect(copy.fieldErrors, original.fieldErrors);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        final result1 = AuthResult.success();
        final result2 = AuthResult.success();

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final result1 = AuthResult.success();
        final result2 = AuthResult.failure(error: 'Error');

        expect(result1, isNot(equals(result2)));
      });

      test('should handle field errors equality correctly', () {
        final fieldErrors = {'field': ['error']};
        final result1 = AuthResult.failure(fieldErrors: fieldErrors);
        final result2 = AuthResult.failure(fieldErrors: {'field': ['error']});

        expect(result1, equals(result2));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        final result = AuthResult.failure(error: 'Test error');
        final string = result.toString();

        expect(string, contains('AuthResult('));
        expect(string, contains('success: false'));
        expect(string, contains('error: Test error'));
      });
    });

    group('enhanced functionality with new API data', () {
      test('should create AuthResult with LoginResponse data', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'testuser',
        );

        final loginResponse = LoginResponse(
          token: 'test-token',
          user: user,
          roles: ['Creator', 'Student'],
          profileComplete: {'creator': true, 'student': false},
          onboardingComplete: true,
          incompleteRoles: ['student'],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        final result = AuthResult.success(
          user: user,
          token: 'test-token',
          loginData: loginResponse,
        );

        expect(result.success, true);
        expect(result.user, user);
        expect(result.token, 'test-token');
        expect(result.loginData, loginResponse);
        expect(result.hasRichUserData, true);
        expect(result.hasSignUpData, false);
      });

      test('should create AuthResult with SignUpResponse data', () {
        final signUpData = SignUpData(
          email: 'test@example.com',
          verificationTokenExpiresIn: '10 minutes',
        );

        final signUpResponse = SignUpResponse(
          detail: 'Registration successful!',
          data: signUpData,
        );

        final result = AuthResult.success(signUpData: signUpResponse);

        expect(result.success, true);
        expect(result.signUpData, signUpResponse);
        expect(result.hasSignUpData, true);
        expect(result.hasRichUserData, false);
      });

      test('should provide access to user profile data from loginData', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'testuser',
        );

        final loginResponse = LoginResponse(
          token: 'test-token',
          user: user,
          roles: ['Creator', 'Student'],
          profileComplete: {'creator': true, 'student': false},
          onboardingComplete: true,
          incompleteRoles: ['student'],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        final result = AuthResult.success(loginData: loginResponse);

        expect(result.userRoles, ['Creator', 'Student']);
        expect(result.profileComplete, {'creator': true, 'student': false});
        expect(result.onboardingComplete, true);
        expect(result.incompleteRoles, ['student']);
        expect(result.appAccess, 'full');
        expect(result.redirectTo, '/dashboard');
      });

      test('should return null for profile data when no loginData', () {
        final result = AuthResult.success();

        expect(result.userRoles, isNull);
        expect(result.profileComplete, isNull);
        expect(result.onboardingComplete, isNull);
        expect(result.incompleteRoles, isNull);
        expect(result.appAccess, isNull);
        expect(result.redirectTo, isNull);
      });

      test('should handle JSON serialization with new fields', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'testuser',
        );

        final loginResponse = LoginResponse(
          token: 'test-token',
          user: user,
          roles: ['Creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          incompleteRoles: [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        final result = AuthResult.success(
          user: user,
          token: 'test-token',
          loginData: loginResponse,
        );

        final json = result.toJson();

        expect(json['success'], true);
        expect(json['user'], user.toJson());
        expect(json['token'], 'test-token');
        expect(json['loginData'], loginResponse.toJson());
        expect(json['signUpData'], isNull);
      });

      test('should create AuthResult from JSON with new fields', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'testuser',
        );

        final loginResponseJson = {
          'token': 'test-token',
          'user': user.toJson(),
          'roles': ['Creator'],
          'profile_complete': {'creator': true},
          'onboarding_complete': true,
          'incomplete_roles': <String>[],
          'app_access': 'full',
          'redirect_to': '/dashboard',
        };

        final json = {
          'success': true,
          'user': user.toJson(),
          'token': 'test-token',
          'loginData': loginResponseJson,
          'signUpData': null,
        };

        final result = AuthResult.fromJson(json);

        expect(result.success, true);
        expect(result.user, isNotNull);
        expect(result.token, 'test-token');
        expect(result.loginData, isNotNull);
        expect(result.loginData!.token, 'test-token');
        expect(result.loginData!.roles, ['Creator']);
        expect(result.signUpData, isNull);
      });

      test('should handle copyWith with new fields', () {
        final original = AuthResult.success();
        
        const user = User(
          email: 'test@example.com',
          displayName: 'testuser',
        );

        final loginResponse = LoginResponse(
          token: 'new-token',
          user: user,
          roles: ['Creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          incompleteRoles: [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        final updated = original.copyWith(
          token: 'new-token',
          loginData: loginResponse,
        );

        expect(updated.token, 'new-token');
        expect(updated.loginData, loginResponse);
        expect(updated.success, original.success);
      });

      test('should handle equality with new fields', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'testuser',
        );

        final loginResponse = LoginResponse(
          token: 'test-token',
          user: user,
          roles: ['Creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          incompleteRoles: [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        final result1 = AuthResult.success(
          user: user,
          token: 'test-token',
          loginData: loginResponse,
        );

        final result2 = AuthResult.success(
          user: user,
          token: 'test-token',
          loginData: loginResponse,
        );

        final result3 = AuthResult.success(
          user: user,
          token: 'different-token',
          loginData: loginResponse,
        );

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
        expect(result1, isNot(equals(result3)));
      });

      test('should include new fields in toString', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'testuser',
        );

        final loginResponse = LoginResponse(
          token: 'test-token',
          user: user,
          roles: ['Creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          incompleteRoles: [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        final result = AuthResult.success(
          user: user,
          token: 'test-token',
          loginData: loginResponse,
        );

        final string = result.toString();

        expect(string, contains('AuthResult('));
        expect(string, contains('success: true'));
        expect(string, contains('token: [PRESENT]'));
        expect(string, contains('loginData: '));
        expect(string, contains('signUpData: null'));
      });
    });
  });
}