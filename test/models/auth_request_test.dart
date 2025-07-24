import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/models/auth_request.dart';

void main() {
  group('SignUpRequest Tests', () {
    group('toJson', () {
      test('should convert SignUpRequest to JSON', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final json = request.toJson();

        expect(json['email'], 'test@example.com');
        expect(json['username'], 'testuser');
        expect(json['password'], 'password123');
        expect(json['confirm_password'], 'password123');
      });
    });

    group('validate', () {
      test('should return empty list for valid signup request', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, isEmpty);
      });

      test('should return error for empty email', () {
        const request = SignUpRequest(
          email: '',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Email is required'));
      });

      test('should return error for invalid email format', () {
        const request = SignUpRequest(
          email: 'invalid-email',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Please enter a valid email address'));
      });

      test('should return error for empty username', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: '',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Username is required'));
      });

      test('should return error for short username', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'ab',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Username must be at least 3 characters long'));
      });

      test('should return error for long username', () {
        final request = SignUpRequest(
          email: 'test@example.com',
          username: 'a' * 31, // 31 characters
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Username must be less than 30 characters'));
      });

      test('should return error for invalid username characters', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'test-user!',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Username can only contain letters, numbers, and underscores'));
      });

      test('should accept valid username with underscores and numbers', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'test_user_123',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, isEmpty);
      });

      test('should return error for empty password', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: '',
          confirmPassword: '',
        );

        final errors = request.validate();

        expect(errors, contains('Password is required'));
      });

      test('should return error for short password', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: '1234567',
          confirmPassword: '1234567',
        );

        final errors = request.validate();

        expect(errors, contains('Password must be at least 8 characters long'));
      });

      test('should return error for empty confirm password', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: '',
        );

        final errors = request.validate();

        expect(errors, contains('Please confirm your password'));
      });

      test('should return error for mismatched passwords', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password456',
        );

        final errors = request.validate();

        expect(errors, contains('Passwords do not match'));
      });

      test('should return multiple errors for invalid request', () {
        const request = SignUpRequest(
          email: 'invalid-email',
          username: 'ab',
          password: '123',
          confirmPassword: '456',
        );

        final errors = request.validate();

        expect(errors.length, 4);
        expect(errors, contains('Please enter a valid email address'));
        expect(errors, contains('Username must be at least 3 characters long'));
        expect(errors, contains('Password must be at least 8 characters long'));
        expect(errors, contains('Passwords do not match'));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const original = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final updated = original.copyWith(
          email: 'newemail@example.com',
          username: 'newuser',
        );

        expect(updated.email, 'newemail@example.com');
        expect(updated.username, 'newuser');
        expect(updated.password, 'password123');
        expect(updated.confirmPassword, 'password123');
      });

      test('should keep original values when no updates provided', () {
        const original = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final copy = original.copyWith();

        expect(copy.email, original.email);
        expect(copy.username, original.username);
        expect(copy.password, original.password);
        expect(copy.confirmPassword, original.confirmPassword);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        const request1 = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        const request2 = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const request1 = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        const request2 = SignUpRequest(
          email: 'different@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        expect(request1, isNot(equals(request2)));
      });
    });

    group('toString', () {
      test('should hide password in string representation', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final string = request.toString();

        expect(string, contains('SignUpRequest('));
        expect(string, contains('email: test@example.com'));
        expect(string, contains('username: testuser'));
        expect(string, contains('password: [HIDDEN]'));
        expect(string, contains('confirmPassword: [HIDDEN]'));
        expect(string, isNot(contains('password123')));
      });
    });
  });

  group('LoginRequest Tests', () {
    group('toJson', () {
      test('should convert LoginRequest to JSON', () {
        const request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        final json = request.toJson();

        expect(json['email'], 'test@example.com');
        expect(json['password'], 'password123');
      });
    });

    group('validate', () {
      test('should return empty list for valid login request', () {
        const request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        final errors = request.validate();

        expect(errors, isEmpty);
      });

      test('should return error for empty email', () {
        const request = LoginRequest(
          email: '',
          password: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Email is required'));
      });

      test('should return error for invalid email format', () {
        const request = LoginRequest(
          email: 'invalid-email',
          password: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Please enter a valid email address'));
      });

      test('should return error for empty password', () {
        const request = LoginRequest(
          email: 'test@example.com',
          password: '',
        );

        final errors = request.validate();

        expect(errors, contains('Password is required'));
      });

      test('should return multiple errors for invalid request', () {
        const request = LoginRequest(
          email: 'invalid-email',
          password: '',
        );

        final errors = request.validate();

        expect(errors.length, 2);
        expect(errors, contains('Please enter a valid email address'));
        expect(errors, contains('Password is required'));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const original = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        final updated = original.copyWith(
          email: 'newemail@example.com',
        );

        expect(updated.email, 'newemail@example.com');
        expect(updated.password, 'password123');
      });

      test('should keep original values when no updates provided', () {
        const original = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        final copy = original.copyWith();

        expect(copy.email, original.email);
        expect(copy.password, original.password);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        const request1 = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        const request2 = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const request1 = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        const request2 = LoginRequest(
          email: 'different@example.com',
          password: 'password123',
        );

        expect(request1, isNot(equals(request2)));
      });
    });

    group('toString', () {
      test('should hide password in string representation', () {
        const request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        final string = request.toString();

        expect(string, contains('LoginRequest('));
        expect(string, contains('email: test@example.com'));
        expect(string, contains('password: [HIDDEN]'));
        expect(string, isNot(contains('password123')));
      });
    });
  });
}