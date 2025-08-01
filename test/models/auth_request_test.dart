import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/models/auth_request.dart';

void main() {
  group('SignUpRequest Tests', () {
    group('toJson', () {
      test('should convert SignUpRequest to JSON', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final json = request.toJson();

        expect(json['email'], 'test@example.com');
        expect(json['display_name'], 'Test User');
        expect(json['password'], 'password123');
        expect(json['confirm_password'], 'password123');
      });
    });

    group('validate', () {
      test('should return empty list for valid signup request', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, isEmpty);
      });

      test('should return true for isValid when request is valid', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        expect(request.isValid, isTrue);
      });

      test('should return false for isValid when request is invalid', () {
        const request = SignUpRequest(
          email: 'invalid-email',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        expect(request.isValid, isFalse);
      });

      test('should return error for empty email', () {
        const request = SignUpRequest(
          email: '',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Email is required'));
      });

      test('should return error for invalid email format', () {
        const request = SignUpRequest(
          email: 'invalid-email',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Please enter a valid email address'));
      });

      test('should return error for empty display name', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: '',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Display name is required'));
      });

      test('should return error for short display name', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'A',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Display name must be at least 2 characters long'));
      });

      test('should return error for long display name', () {
        final request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'A' * 51, // 51 characters
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, contains('Display name must be less than 50 characters'));
      });

      test('should accept valid display name with spaces and special characters', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'John Doe Jr.',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final errors = request.validate();

        expect(errors, isEmpty);
      });

      test('should return error for empty password', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: '',
          confirmPassword: '',
        );

        final errors = request.validate();

        expect(errors, contains('Password is required'));
      });

      test('should return error for short password', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: '1234567',
          confirmPassword: '1234567',
        );

        final errors = request.validate();

        expect(errors, contains('Password must be at least 8 characters long'));
      });

      test('should return error for long password', () {
        final longPassword = 'a' * 129; // 129 characters
        final request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: longPassword,
          confirmPassword: longPassword,
        );

        final errors = request.validate();

        expect(errors, contains('Password must be less than 128 characters'));
      });

      test('should return error for password without letters', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: '12345678',
          confirmPassword: '12345678',
        );

        final errors = request.validate();

        expect(errors, contains('Password must contain at least one letter and one number'));
      });

      test('should return error for password without numbers', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'abcdefgh',
          confirmPassword: 'abcdefgh',
        );

        final errors = request.validate();

        expect(errors, contains('Password must contain at least one letter and one number'));
      });

      test('should return error for empty confirm password', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: '',
        );

        final errors = request.validate();

        expect(errors, contains('Please confirm your password'));
      });

      test('should return error for mismatched passwords', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password456',
        );

        final errors = request.validate();

        expect(errors, contains('Passwords do not match'));
      });

      test('should return multiple errors for invalid request', () {
        const request = SignUpRequest(
          email: 'invalid-email',
          displayName: 'A',
          password: '123',
          confirmPassword: '456',
        );

        final errors = request.validate();

        expect(errors.length, 5); // Updated to expect 5 errors due to password strength validation
        expect(errors, contains('Please enter a valid email address'));
        expect(errors, contains('Display name must be at least 2 characters long'));
        expect(errors, contains('Password must be at least 8 characters long'));
        expect(errors, contains('Password must contain at least one letter and one number'));
        expect(errors, contains('Passwords do not match'));
      });
    });

    group('validateFields', () {
      test('should return empty map for valid signup request', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors, isEmpty);
      });

      test('should return field-specific errors for invalid email', () {
        const request = SignUpRequest(
          email: 'invalid-email',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors['email'], contains('Please enter a valid email address'));
        expect(fieldErrors['displayName'], isNull);
        expect(fieldErrors['password'], isNull);
        expect(fieldErrors['confirmPassword'], isNull);
      });

      test('should return field-specific errors for invalid display name', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'A',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors['email'], isNull);
        expect(fieldErrors['displayName'], contains('Display name must be at least 2 characters long'));
        expect(fieldErrors['password'], isNull);
        expect(fieldErrors['confirmPassword'], isNull);
      });

      test('should return field-specific errors for invalid password', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: '123',
          confirmPassword: '123',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors['email'], isNull);
        expect(fieldErrors['displayName'], isNull);
        expect(fieldErrors['password'], isNotNull);
        expect(fieldErrors['password'], contains('Password must be at least 8 characters long'));
        expect(fieldErrors['confirmPassword'], isNull);
      });

      test('should return field-specific errors for mismatched passwords', () {
        const request = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password456',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors['email'], isNull);
        expect(fieldErrors['displayName'], isNull);
        expect(fieldErrors['password'], isNull);
        expect(fieldErrors['confirmPassword'], contains('Passwords do not match'));
      });

      test('should return multiple field errors for completely invalid request', () {
        const request = SignUpRequest(
          email: 'invalid-email',
          displayName: 'A',
          password: '123',
          confirmPassword: '456',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors['email'], contains('Please enter a valid email address'));
        expect(fieldErrors['displayName'], contains('Display name must be at least 2 characters long'));
        expect(fieldErrors['password'], isNotNull);
        expect(fieldErrors['password']!.length, greaterThan(1)); // Multiple password errors
        expect(fieldErrors['confirmPassword'], contains('Passwords do not match'));
      });

      test('should handle email with whitespace', () {
        const request = SignUpRequest(
          email: '  test@example.com  ',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors, isEmpty); // Should be valid after trimming
      });

      test('should validate complex email formats', () {
        const request = SignUpRequest(
          email: 'user.name+tag@example-domain.co.uk',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors['email'], isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const original = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final updated = original.copyWith(
          email: 'newemail@example.com',
          displayName: 'New User',
        );

        expect(updated.email, 'newemail@example.com');
        expect(updated.displayName, 'New User');
        expect(updated.password, 'password123');
        expect(updated.confirmPassword, 'password123');
      });

      test('should keep original values when no updates provided', () {
        const original = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final copy = original.copyWith();

        expect(copy.email, original.email);
        expect(copy.displayName, original.displayName);
        expect(copy.password, original.password);
        expect(copy.confirmPassword, original.confirmPassword);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        const request1 = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        const request2 = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const request1 = SignUpRequest(
          email: 'test@example.com',
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        const request2 = SignUpRequest(
          email: 'different@example.com',
          displayName: 'Test User',
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
          displayName: 'Test User',
          password: 'password123',
          confirmPassword: 'password123',
        );

        final string = request.toString();

        expect(string, contains('SignUpRequest('));
        expect(string, contains('email: test@example.com'));
        expect(string, contains('displayName: Test User'));
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

      test('should return true for isValid when request is valid', () {
        const request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(request.isValid, isTrue);
      });

      test('should return false for isValid when request is invalid', () {
        const request = LoginRequest(
          email: 'invalid-email',
          password: 'password123',
        );

        expect(request.isValid, isFalse);
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

    group('validateFields', () {
      test('should return empty map for valid login request', () {
        const request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors, isEmpty);
      });

      test('should return field-specific errors for invalid email', () {
        const request = LoginRequest(
          email: 'invalid-email',
          password: 'password123',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors['email'], contains('Please enter a valid email address'));
        expect(fieldErrors['password'], isNull);
      });

      test('should return field-specific errors for empty password', () {
        const request = LoginRequest(
          email: 'test@example.com',
          password: '',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors['email'], isNull);
        expect(fieldErrors['password'], contains('Password is required'));
      });

      test('should return multiple field errors for invalid request', () {
        const request = LoginRequest(
          email: 'invalid-email',
          password: '',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors['email'], contains('Please enter a valid email address'));
        expect(fieldErrors['password'], contains('Password is required'));
      });

      test('should handle email with whitespace', () {
        const request = LoginRequest(
          email: '  test@example.com  ',
          password: 'password123',
        );

        final fieldErrors = request.validateFields();

        expect(fieldErrors, isEmpty); // Should be valid after trimming
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