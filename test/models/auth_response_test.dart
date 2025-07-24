import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/models/auth_response.dart';
import 'package:question_auth/src/models/user.dart';

void main() {
  group('AuthResponse Tests', () {
    group('fromJson', () {
      test('should create AuthResponse from successful JSON with token and user', () {
        final json = {
          'token': 'abc123',
          'user': {
            'id': '1',
            'email': 'test@example.com',
            'username': 'testuser',
          },
          'success': true,
          'message': 'Login successful',
        };

        final response = AuthResponse.fromJson(json);

        expect(response.token, 'abc123');
        expect(response.user, isNotNull);
        expect(response.user!.id, '1');
        expect(response.user!.email, 'test@example.com');
        expect(response.user!.username, 'testuser');
        expect(response.success, true);
        expect(response.message, 'Login successful');
        expect(response.errors, isNull);
      });

      test('should create AuthResponse from JSON with token but no explicit success', () {
        final json = {
          'token': 'abc123',
          'user': {
            'id': '1',
            'email': 'test@example.com',
            'username': 'testuser',
          },
        };

        final response = AuthResponse.fromJson(json);

        expect(response.token, 'abc123');
        expect(response.success, true); // Should be true because token exists
        expect(response.isSuccess, true);
      });

      test('should create AuthResponse from error JSON with field errors', () {
        final json = {
          'success': false,
          'message': 'Validation failed',
          'errors': {
            'email': ['Invalid email format'],
            'password': ['Password too short', 'Password must contain numbers'],
          },
        };

        final response = AuthResponse.fromJson(json);

        expect(response.token, isNull);
        expect(response.user, isNull);
        expect(response.success, false);
        expect(response.message, 'Validation failed');
        expect(response.errors, isNotNull);
        expect(response.errors!['email'], ['Invalid email format']);
        expect(response.errors!['password'], ['Password too short', 'Password must contain numbers']);
      });

      test('should handle errors as list format', () {
        final json = {
          'success': false,
          'errors': ['General error 1', 'General error 2'],
        };

        final response = AuthResponse.fromJson(json);

        expect(response.success, false);
        expect(response.errors, isNotNull);
        expect(response.errors!['general'], ['General error 1', 'General error 2']);
      });

      test('should handle errors as string format', () {
        final json = {
          'success': false,
          'errors': 'Single error message',
        };

        final response = AuthResponse.fromJson(json);

        expect(response.success, false);
        expect(response.errors, isNotNull);
        expect(response.errors!['general'], ['Single error message']);
      });

      test('should handle mixed error value types', () {
        final json = {
          'success': false,
          'errors': {
            'email': 'Single string error',
            'password': ['List error 1', 'List error 2'],
            'username': 123, // Non-string value
          },
        };

        final response = AuthResponse.fromJson(json);

        expect(response.errors!['email'], ['Single string error']);
        expect(response.errors!['password'], ['List error 1', 'List error 2']);
        expect(response.errors!['username'], ['123']);
      });

      test('should handle null and missing fields gracefully', () {
        final json = <String, dynamic>{};

        final response = AuthResponse.fromJson(json);

        expect(response.token, isNull);
        expect(response.user, isNull);
        expect(response.success, false);
        expect(response.message, isNull);
        expect(response.errors, isNull);
      });
    });

    group('toJson', () {
      test('should convert AuthResponse to JSON', () {
        final user = User(
          id: '1',
          email: 'test@example.com',
          username: 'testuser',
        );

        final response = AuthResponse(
          token: 'abc123',
          user: user,
          success: true,
          message: 'Success',
          errors: {'field': ['error']},
        );

        final json = response.toJson();

        expect(json['token'], 'abc123');
        expect(json['user'], user.toJson());
        expect(json['success'], true);
        expect(json['message'], 'Success');
        expect(json['errors'], {'field': ['error']});
      });
    });

    group('factory constructors', () {
      test('should create success response', () {
        const user = User(
          id: '1',
          email: 'test@example.com',
          username: 'testuser',
        );

        final response = AuthResponse.success(
          token: 'abc123',
          user: user,
          message: 'Login successful',
        );

        expect(response.token, 'abc123');
        expect(response.user, user);
        expect(response.success, true);
        expect(response.message, 'Login successful');
        expect(response.errors, isNull);
      });

      test('should create error response', () {
        final errors = {
          'email': ['Invalid email'],
        };

        final response = AuthResponse.error(
          message: 'Validation failed',
          errors: errors,
        );

        expect(response.token, isNull);
        expect(response.user, isNull);
        expect(response.success, false);
        expect(response.message, 'Validation failed');
        expect(response.errors, errors);
      });
    });

    group('helper methods', () {
      test('isSuccess should return true for successful response with token', () {
        final response = AuthResponse.success(token: 'abc123');
        expect(response.isSuccess, true);
      });

      test('isSuccess should return false for successful response without token', () {
        final response = AuthResponse.success();
        expect(response.isSuccess, false);
      });

      test('isSuccess should return false for error response', () {
        final response = AuthResponse.error();
        expect(response.isSuccess, false);
      });

      test('hasErrors should return true when errors exist', () {
        final response = AuthResponse.error(errors: {'field': ['error']});
        expect(response.hasErrors, true);
      });

      test('hasErrors should return false when no errors', () {
        final response = AuthResponse.success();
        expect(response.hasErrors, false);
      });

      test('allErrorMessages should return flat list of all errors', () {
        final response = AuthResponse.error(
          errors: {
            'email': ['Invalid email', 'Email required'],
            'password': ['Password too short'],
          },
        );

        final allErrors = response.allErrorMessages;
        expect(allErrors.length, 3);
        expect(allErrors, contains('Invalid email'));
        expect(allErrors, contains('Email required'));
        expect(allErrors, contains('Password too short'));
      });

      test('firstErrorMessage should return message if present', () {
        final response = AuthResponse.error(
          message: 'General error',
          errors: {'field': ['Field error']},
        );

        expect(response.firstErrorMessage, 'General error');
      });

      test('firstErrorMessage should return first field error if no message', () {
        final response = AuthResponse.error(
          errors: {'email': ['Email error'], 'password': ['Password error']},
        );

        expect(response.firstErrorMessage, 'Email error');
      });

      test('firstErrorMessage should return null if no errors', () {
        final response = AuthResponse.success();
        expect(response.firstErrorMessage, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = AuthResponse.success(token: 'abc123');
        final updated = original.copyWith(message: 'Updated message');

        expect(updated.token, 'abc123');
        expect(updated.success, true);
        expect(updated.message, 'Updated message');
      });

      test('should keep original values when no updates provided', () {
        final original = AuthResponse.success(token: 'abc123', message: 'Original');
        final copy = original.copyWith();

        expect(copy.token, original.token);
        expect(copy.success, original.success);
        expect(copy.message, original.message);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        final response1 = AuthResponse.success(token: 'abc123');
        final response2 = AuthResponse.success(token: 'abc123');

        expect(response1, equals(response2));
        expect(response1.hashCode, equals(response2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final response1 = AuthResponse.success(token: 'abc123');
        final response2 = AuthResponse.success(token: 'def456');

        expect(response1, isNot(equals(response2)));
      });

      test('should handle error map equality correctly', () {
        final errors = {'field': ['error']};
        final response1 = AuthResponse.error(errors: errors);
        final response2 = AuthResponse.error(errors: {'field': ['error']});

        expect(response1, equals(response2));
      });
    });

    group('toString', () {
      test('should hide token value in string representation', () {
        final response = AuthResponse.success(token: 'secret123');
        final string = response.toString();

        expect(string, contains('AuthResponse('));
        expect(string, contains('token: [PRESENT]'));
        expect(string, isNot(contains('secret123')));
      });

      test('should show null token in string representation', () {
        final response = AuthResponse.error();
        final string = response.toString();

        expect(string, contains('token: null'));
      });
    });
  });
}