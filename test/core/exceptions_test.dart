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

    group('Field-specific error methods', () {
      late ValidationException exception;

      setUp(() {
        final fieldErrors = {
          'email': ['Invalid email format', 'Email is required'],
          'password': ['Password too short'],
          'display_name': ['Display name already taken'],
          'empty_field': <String>[],
        };
        exception = ValidationException('Validation failed', fieldErrors);
      });

      test('getFieldErrors should return errors for existing field', () {
        final emailErrors = exception.getFieldErrors('email');
        expect(emailErrors, equals(['Invalid email format', 'Email is required']));
        
        final passwordErrors = exception.getFieldErrors('password');
        expect(passwordErrors, equals(['Password too short']));
      });

      test('getFieldErrors should return empty list for non-existing field', () {
        final errors = exception.getFieldErrors('non_existing_field');
        expect(errors, isEmpty);
      });

      test('getFieldErrors should return empty list for field with empty errors', () {
        final errors = exception.getFieldErrors('empty_field');
        expect(errors, isEmpty);
      });

      test('getFirstFieldError should return first error for existing field', () {
        final firstEmailError = exception.getFirstFieldError('email');
        expect(firstEmailError, equals('Invalid email format'));
        
        final firstPasswordError = exception.getFirstFieldError('password');
        expect(firstPasswordError, equals('Password too short'));
      });

      test('getFirstFieldError should return null for non-existing field', () {
        final error = exception.getFirstFieldError('non_existing_field');
        expect(error, isNull);
      });

      test('getFirstFieldError should return null for field with empty errors', () {
        final error = exception.getFirstFieldError('empty_field');
        expect(error, isNull);
      });

      test('hasFieldError should return true for fields with errors', () {
        expect(exception.hasFieldError('email'), isTrue);
        expect(exception.hasFieldError('password'), isTrue);
        expect(exception.hasFieldError('display_name'), isTrue);
      });

      test('hasFieldError should return false for fields without errors', () {
        expect(exception.hasFieldError('non_existing_field'), isFalse);
        expect(exception.hasFieldError('empty_field'), isFalse);
      });

      test('errorFields should return all field names with errors', () {
        final fields = exception.errorFields;
        expect(fields, containsAll(['email', 'password', 'display_name']));
        expect(fields, isNot(contains('empty_field')));
        expect(fields.length, equals(3)); // Excluding empty_field
      });

      test('allErrorMessages should return all error messages as flat list', () {
        final allErrors = exception.allErrorMessages;
        expect(allErrors, containsAll([
          'Invalid email format',
          'Email is required',
          'Password too short',
          'Display name already taken'
        ]));
        expect(allErrors.length, equals(4));
      });

      test('firstErrorMessage should return first error from any field', () {
        final firstError = exception.firstErrorMessage;
        expect(firstError, isNotNull);
        expect(['Invalid email format', 'Password too short', 'Display name already taken'], 
               contains(firstError));
      });

      test('firstErrorMessage should return null for exception with no errors', () {
        final emptyException = ValidationException('No errors', {});
        expect(emptyException.firstErrorMessage, isNull);
      });

      test('totalErrorCount should return total number of errors', () {
        expect(exception.totalErrorCount, equals(4));
      });

      test('totalErrorCount should return 0 for exception with no errors', () {
        final emptyException = ValidationException('No errors', {});
        expect(emptyException.totalErrorCount, equals(0));
      });

      test('detailedMessage should format field errors nicely', () {
        final detailed = exception.detailedMessage;
        expect(detailed, contains('Validation failed'));
        expect(detailed, contains('• Email: Invalid email format'));
        expect(detailed, contains('• Email: Email is required'));
        expect(detailed, contains('• Password: Password too short'));
        expect(detailed, contains('• Display Name: Display name already taken'));
      });

      test('detailedMessage should handle exception with no main message', () {
        final fieldErrors = {
          'email': ['Invalid email format'],
        };
        final noMessageException = ValidationException('', fieldErrors);
        final detailed = noMessageException.detailedMessage;
        expect(detailed, equals('• Email: Invalid email format'));
      });

      test('detailedMessage should return main message when no field errors', () {
        final noFieldsException = ValidationException('General error', {});
        expect(noFieldsException.detailedMessage, equals('General error'));
      });

      test('should format field names correctly', () {
        final fieldErrors = {
          'email_address': ['Invalid email'],
          'firstName': ['Required'],
          'last_name': ['Too short'],
          'confirmPassword': ['Does not match'],
          'phone_number': ['Invalid format'],
        };
        final exception = ValidationException('Test', fieldErrors);
        final detailed = exception.detailedMessage;
        
        expect(detailed, contains('• Email Address: Invalid email'));
        expect(detailed, contains('• First Name: Required'));
        expect(detailed, contains('• Last Name: Too short'));
        expect(detailed, contains('• Confirm Password: Does not match'));
        expect(detailed, contains('• Phone Number: Invalid format'));
      });
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