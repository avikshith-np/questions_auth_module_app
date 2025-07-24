import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/models/user.dart';

void main() {
  group('User Model Tests', () {
    group('fromJson', () {
      test('should create User from valid JSON', () {
        final json = {
          'id': '123',
          'email': 'test@example.com',
          'username': 'testuser',
          'created_at': '2023-01-01T00:00:00.000Z',
          'updated_at': '2023-01-02T00:00:00.000Z',
        };

        final user = User.fromJson(json);

        expect(user.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.username, 'testuser');
        expect(user.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
        expect(user.updatedAt, DateTime.parse('2023-01-02T00:00:00.000Z'));
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': '123',
          'email': 'test@example.com',
          'username': 'testuser',
        };

        final user = User.fromJson(json);

        expect(user.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.username, 'testuser');
        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });

      test('should handle null values gracefully', () {
        final json = {
          'id': null,
          'email': null,
          'username': null,
          'created_at': null,
          'updated_at': null,
        };

        final user = User.fromJson(json);

        expect(user.id, '');
        expect(user.email, '');
        expect(user.username, '');
        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });

      test('should handle invalid date strings', () {
        final json = {
          'id': '123',
          'email': 'test@example.com',
          'username': 'testuser',
          'created_at': 'invalid-date',
          'updated_at': 'invalid-date',
        };

        final user = User.fromJson(json);

        expect(user.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.username, 'testuser');
        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });
    });

    group('toJson', () {
      test('should convert User to JSON with all fields', () {
        final user = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2023-01-02T00:00:00.000Z'),
        );

        final json = user.toJson();

        expect(json['id'], '123');
        expect(json['email'], 'test@example.com');
        expect(json['username'], 'testuser');
        expect(json['created_at'], '2023-01-01T00:00:00.000Z');
        expect(json['updated_at'], '2023-01-02T00:00:00.000Z');
      });

      test('should convert User to JSON with null optional fields', () {
        const user = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        );

        final json = user.toJson();

        expect(json['id'], '123');
        expect(json['email'], 'test@example.com');
        expect(json['username'], 'testuser');
        expect(json['created_at'], isNull);
        expect(json['updated_at'], isNull);
      });
    });

    group('validate', () {
      test('should return empty list for valid user', () {
        const user = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        );

        final errors = user.validate();

        expect(errors, isEmpty);
      });

      test('should return error for empty id', () {
        const user = User(
          id: '',
          email: 'test@example.com',
          username: 'testuser',
        );

        final errors = user.validate();

        expect(errors, contains('User ID cannot be empty'));
      });

      test('should return error for empty email', () {
        const user = User(
          id: '123',
          email: '',
          username: 'testuser',
        );

        final errors = user.validate();

        expect(errors, contains('Email cannot be empty'));
      });

      test('should return error for invalid email format', () {
        const user = User(
          id: '123',
          email: 'invalid-email',
          username: 'testuser',
        );

        final errors = user.validate();

        expect(errors, contains('Invalid email format'));
      });

      test('should return error for empty username', () {
        const user = User(
          id: '123',
          email: 'test@example.com',
          username: '',
        );

        final errors = user.validate();

        expect(errors, contains('Username cannot be empty'));
      });

      test('should return error for short username', () {
        const user = User(
          id: '123',
          email: 'test@example.com',
          username: 'ab',
        );

        final errors = user.validate();

        expect(errors, contains('Username must be at least 3 characters long'));
      });

      test('should return multiple errors for invalid user', () {
        const user = User(
          id: '',
          email: 'invalid-email',
          username: 'ab',
        );

        final errors = user.validate();

        expect(errors.length, 3);
        expect(errors, contains('User ID cannot be empty'));
        expect(errors, contains('Invalid email format'));
        expect(errors, contains('Username must be at least 3 characters long'));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const original = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        );

        final updated = original.copyWith(
          email: 'newemail@example.com',
          username: 'newusername',
        );

        expect(updated.id, '123');
        expect(updated.email, 'newemail@example.com');
        expect(updated.username, 'newusername');
      });

      test('should keep original values when no updates provided', () {
        const original = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.email, original.email);
        expect(copy.username, original.username);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        const user1 = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        );

        const user2 = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const user1 = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        );

        const user2 = User(
          id: '456',
          email: 'test@example.com',
          username: 'testuser',
        );

        expect(user1, isNot(equals(user2)));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        const user = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
        );

        final string = user.toString();

        expect(string, contains('User('));
        expect(string, contains('id: 123'));
        expect(string, contains('email: test@example.com'));
        expect(string, contains('username: testuser'));
      });
    });

    group('JSON serialization round-trip', () {
      test('should maintain data integrity through serialization', () {
        final original = User(
          id: '123',
          email: 'test@example.com',
          username: 'testuser',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2023-01-02T00:00:00.000Z'),
        );

        final json = original.toJson();
        final deserialized = User.fromJson(json);

        expect(deserialized, equals(original));
      });
    });
  });
}