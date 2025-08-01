import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/models/user.dart';

void main() {
  group('User Model Tests', () {
    group('fromJson', () {
      test('should create User from valid JSON with all fields', () {
        final json = {
          'email': 'test@example.com',
          'display_name': 'Test User',
          'is_active': true,
          'email_verified': true,
          'is_verified': true,
          'is_new': false,
          'date_joined': '2023-01-01T00:00:00.000Z',
        };

        final user = User.fromJson(json);

        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.isActive, true);
        expect(user.emailVerified, true);
        expect(user.isVerified, true);
        expect(user.isNew, false);
        expect(user.dateJoined, DateTime.parse('2023-01-01T00:00:00.000Z'));
      });

      test('should create User from minimal JSON with defaults', () {
        final json = {
          'email': 'test@example.com',
          'display_name': 'Test User',
        };

        final user = User.fromJson(json);

        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.isActive, true);
        expect(user.emailVerified, false);
        expect(user.isVerified, false);
        expect(user.isNew, false);
        expect(user.dateJoined, isNull);
      });

      test('should handle null values gracefully', () {
        final json = {
          'email': null,
          'display_name': null,
          'is_active': null,
          'email_verified': null,
          'is_verified': null,
          'is_new': null,
          'date_joined': null,
        };

        final user = User.fromJson(json);

        expect(user.email, '');
        expect(user.displayName, '');
        expect(user.isActive, true);
        expect(user.emailVerified, false);
        expect(user.isVerified, false);
        expect(user.isNew, false);
        expect(user.dateJoined, isNull);
      });

      test('should handle invalid date strings', () {
        final json = {
          'email': 'test@example.com',
          'display_name': 'Test User',
          'date_joined': 'invalid-date',
        };

        final user = User.fromJson(json);

        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.dateJoined, isNull);
      });
    });

    group('toJson', () {
      test('should convert User to JSON with all fields', () {
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
          dateJoined: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final json = user.toJson();

        expect(json['email'], 'test@example.com');
        expect(json['display_name'], 'Test User');
        expect(json['is_active'], true);
        expect(json['email_verified'], true);
        expect(json['is_verified'], true);
        expect(json['is_new'], false);
        expect(json['date_joined'], '2023-01-01T00:00:00.000Z');
      });

      test('should convert User to JSON without date_joined when null', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'Test User',
        );

        final json = user.toJson();

        expect(json['email'], 'test@example.com');
        expect(json['display_name'], 'Test User');
        expect(json['is_active'], true);
        expect(json['email_verified'], false);
        expect(json['is_verified'], false);
        expect(json['is_new'], false);
        expect(json.containsKey('date_joined'), false);
      });
    });

    group('validate', () {
      test('should return empty list for valid user', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'Test User',
        );

        final errors = user.validate();

        expect(errors, isEmpty);
      });

      test('should return error for empty email', () {
        const user = User(
          email: '',
          displayName: 'Test User',
        );

        final errors = user.validate();

        expect(errors, contains('Email cannot be empty'));
      });

      test('should return error for invalid email format', () {
        const user = User(
          email: 'invalid-email',
          displayName: 'Test User',
        );

        final errors = user.validate();

        expect(errors, contains('Invalid email format'));
      });

      test('should return error for empty display name', () {
        const user = User(
          email: 'test@example.com',
          displayName: '',
        );

        final errors = user.validate();

        expect(errors, contains('Display name cannot be empty'));
      });

      test('should return error for short display name', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'A',
        );

        final errors = user.validate();

        expect(errors, contains('Display name must be at least 2 characters long'));
      });

      test('should return multiple errors for invalid user', () {
        const user = User(
          email: 'invalid-email',
          displayName: 'A',
        );

        final errors = user.validate();

        expect(errors.length, 2);
        expect(errors, contains('Invalid email format'));
        expect(errors, contains('Display name must be at least 2 characters long'));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const original = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: false,
        );

        final updated = original.copyWith(
          email: 'newemail@example.com',
          displayName: 'New User',
          emailVerified: true,
        );

        expect(updated.email, 'newemail@example.com');
        expect(updated.displayName, 'New User');
        expect(updated.isActive, true);
        expect(updated.emailVerified, true);
      });

      test('should keep original values when no updates provided', () {
        const original = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: false,
          emailVerified: true,
        );

        final copy = original.copyWith();

        expect(copy.email, original.email);
        expect(copy.displayName, original.displayName);
        expect(copy.isActive, original.isActive);
        expect(copy.emailVerified, original.emailVerified);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        const user1 = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: false,
        );

        const user2 = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: false,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const user1 = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
        );

        const user2 = User(
          email: 'different@example.com',
          displayName: 'Test User',
          isActive: true,
        );

        expect(user1, isNot(equals(user2)));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        const user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: false,
        );

        final string = user.toString();

        expect(string, contains('User('));
        expect(string, contains('email: test@example.com'));
        expect(string, contains('displayName: Test User'));
        expect(string, contains('isActive: true'));
        expect(string, contains('emailVerified: false'));
      });
    });

    group('JSON serialization round-trip', () {
      test('should maintain data integrity through serialization', () {
        final original = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: false,
          isNew: true,
          dateJoined: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final json = original.toJson();
        final deserialized = User.fromJson(json);

        expect(deserialized, equals(original));
      });

      test('should handle round-trip without optional date field', () {
        const original = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: false,
          emailVerified: true,
        );

        final json = original.toJson();
        final deserialized = User.fromJson(json);

        expect(deserialized, equals(original));
      });
    });
  });
}