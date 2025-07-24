import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/core/exceptions.dart';

void main() {
  group('AuthException', () {
    test('should create exception with message only', () {
      const exception = _TestAuthException('Test message');
      
      expect(exception.message, equals('Test message'));
      expect(exception.code, isNull);
      expect(exception.toString(), equals('AuthException: Test message'));
    });
    
    test('should create exception with message and code', () {
      const exception = _TestAuthException('Test message', 'TEST_CODE');
      
      expect(exception.message, equals('Test message'));
      expect(exception.code, equals('TEST_CODE'));
      expect(exception.toString(), equals('AuthException: Test message (Code: TEST_CODE)'));
    });
  });

  group('NetworkException', () {
    test('should create network exception with correct properties', () {
      const exception = NetworkException('Connection failed');
      
      expect(exception.message, equals('Connection failed'));
      expect(exception.code, equals('NETWORK_ERROR'));
      expect(exception.toString(), equals('NetworkException: Connection failed'));
    });
    
    test('should be instance of AuthException', () {
      const exception = NetworkException('Connection failed');
      
      expect(exception, isA<AuthException>());
    });
  });

  group('ValidationException', () {
    test('should create validation exception with field errors', () {
      final fieldErrors = {
        'email': ['Invalid email format'],
        'password': ['Password too short', 'Password must contain numbers']
      };
      final exception = ValidationException('Validation failed', fieldErrors);
      
      expect(exception.message, equals('Validation failed'));
      expect(exception.code, equals('VALIDATION_ERROR'));
      expect(exception.fieldErrors, equals(fieldErrors));
      expect(exception.toString(), equals('ValidationException: Validation failed'));
    });
    
    test('should create validation exception with empty field errors', () {
      final exception = ValidationException('Validation failed', {});
      
      expect(exception.message, equals('Validation failed'));
      expect(exception.fieldErrors, isEmpty);
    });
    
    test('should be instance of AuthException', () {
      final exception = ValidationException('Validation failed', {});
      
      expect(exception, isA<AuthException>());
    });
  });

  group('ApiException', () {
    test('should create API exception with status code only', () {
      const exception = ApiException('Server error', 500);
      
      expect(exception.message, equals('Server error'));
      expect(exception.statusCode, equals(500));
      expect(exception.code, isNull);
      expect(exception.toString(), equals('ApiException: Server error (Status: 500)'));
    });
    
    test('should create API exception with status code and error code', () {
      const exception = ApiException('Unauthorized', 401, 'AUTH_REQUIRED');
      
      expect(exception.message, equals('Unauthorized'));
      expect(exception.statusCode, equals(401));
      expect(exception.code, equals('AUTH_REQUIRED'));
      expect(exception.toString(), equals('ApiException: Unauthorized (Status: 401) (Code: AUTH_REQUIRED)'));
    });
    
    test('should be instance of AuthException', () {
      const exception = ApiException('Server error', 500);
      
      expect(exception, isA<AuthException>());
    });
  });

  group('TokenException', () {
    test('should create token exception with correct properties', () {
      const exception = TokenException('Token expired');
      
      expect(exception.message, equals('Token expired'));
      expect(exception.code, equals('TOKEN_ERROR'));
      expect(exception.toString(), equals('TokenException: Token expired'));
    });
    
    test('should be instance of AuthException', () {
      const exception = TokenException('Token expired');
      
      expect(exception, isA<AuthException>());
    });
  });

  group('Exception handling scenarios', () {
    test('should handle network timeout scenario', () {
      const exception = NetworkException('Request timeout after 30 seconds');
      
      expect(exception.message, contains('timeout'));
      expect(exception.code, equals('NETWORK_ERROR'));
    });
    
    test('should handle multiple validation errors', () {
      final fieldErrors = {
        'email': ['Required field', 'Invalid format'],
        'password': ['Too short'],
        'confirmPassword': ['Does not match password']
      };
      final exception = ValidationException('Multiple validation errors', fieldErrors);
      
      expect(exception.fieldErrors.length, equals(3));
      expect(exception.fieldErrors['email']?.length, equals(2));
      expect(exception.fieldErrors['password']?.length, equals(1));
      expect(exception.fieldErrors['confirmPassword']?.length, equals(1));
    });
    
    test('should handle different HTTP status codes', () {
      const badRequest = ApiException('Bad request', 400);
      const unauthorized = ApiException('Unauthorized', 401);
      const forbidden = ApiException('Forbidden', 403);
      const notFound = ApiException('Not found', 404);
      const serverError = ApiException('Internal server error', 500);
      
      expect(badRequest.statusCode, equals(400));
      expect(unauthorized.statusCode, equals(401));
      expect(forbidden.statusCode, equals(403));
      expect(notFound.statusCode, equals(404));
      expect(serverError.statusCode, equals(500));
    });
    
    test('should handle token-related scenarios', () {
      const expiredToken = TokenException('Token has expired');
      const invalidToken = TokenException('Invalid token format');
      const missingToken = TokenException('No token found');
      
      expect(expiredToken.message, contains('expired'));
      expect(invalidToken.message, contains('Invalid'));
      expect(missingToken.message, contains('No token'));
    });
  });
}

// Test implementation of AuthException for testing abstract class
class _TestAuthException extends AuthException {
  const _TestAuthException(String message, [String? code]) : super(message, code);
}