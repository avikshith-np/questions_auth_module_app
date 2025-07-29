import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/services/question_auth.dart';
import '../../lib/src/models/auth_request.dart';
import '../../lib/src/core/auth_state.dart';

void main() {
  group('QuestionAuth', () {
    setUp(() {
      // Reset singleton before each test
      QuestionAuth.reset();
    });
    
    tearDown(() {
      // Reset singleton after each test
      QuestionAuth.reset();
    });
    
    group('Singleton Pattern', () {
      test('should return the same instance', () {
        final instance1 = QuestionAuth.instance;
        final instance2 = QuestionAuth.instance;
        
        expect(instance1, same(instance2));
      });
      
      test('should reset instance when reset() is called', () {
        final instance1 = QuestionAuth.instance;
        QuestionAuth.reset();
        final instance2 = QuestionAuth.instance;
        
        expect(instance1, isNot(same(instance2)));
      });
    });
    
    group('Configuration', () {
      test('should configure with required baseUrl', () {
        expect(() {
          QuestionAuth.instance.configure(
            baseUrl: 'https://api.example.com',
          );
        }, returnsNormally);
      });
      
      test('should configure with all optional parameters', () {
        expect(() {
          QuestionAuth.instance.configure(
            baseUrl: 'https://api.example.com',
            apiVersion: 'v2',
            timeout: const Duration(seconds: 60),
            enableLogging: true,
            defaultHeaders: {'Custom-Header': 'value'},
          );
        }, returnsNormally);
      });
      
      test('should use default values for optional parameters', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        // Configuration should succeed with defaults - test by accessing a property
        expect(() => QuestionAuth.instance.isAuthenticated, returnsNormally);
      });
    });
    
    group('State Validation', () {
      test('should throw StateError when not configured', () {
        expect(
          () => QuestionAuth.instance.signUp(
            const SignUpRequest(
              email: 'test@example.com',
              username: 'testuser',
              password: 'password123',
              confirmPassword: 'password123',
            ),
          ),
          throwsA(isA<StateError>()),
        );
      });
      
      test('should throw StateError with descriptive message', () {
        expect(
          () => QuestionAuth.instance.login(
            const LoginRequest(
              email: 'test@example.com',
              password: 'password123',
            ),
          ),
          throwsA(
            predicate((e) => 
              e is StateError && 
              e.message.contains('QuestionAuth must be configured')
            ),
          ),
        );
      });
    });
    
    group('Authentication Methods', () {
      test('should call initialize on auth service when configured', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        // Test that the method returns a Future (doesn't throw synchronously)
        final future = QuestionAuth.instance.initialize();
        expect(future, isA<Future>());
      });
      
      test('should handle signUp request when configured', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        final request = const SignUpRequest(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          confirmPassword: 'password123',
        );
        
        // Test that the method returns a Future (doesn't throw synchronously)
        final future = QuestionAuth.instance.signUp(request);
        expect(future, isA<Future>());
      });
      
      test('should handle login request when configured', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        final request = const LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        // Test that the method returns a Future (doesn't throw synchronously)
        final future = QuestionAuth.instance.login(request);
        expect(future, isA<Future>());
      });
      
      test('should handle getCurrentUser request when configured', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        // Test that the method exists and is callable (basic interface test)
        expect(QuestionAuth.instance.getCurrentUser, isA<Function>());
      });
      
      test('should handle logout request when configured', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        // Test that the method returns a Future (doesn't throw synchronously)
        final future = QuestionAuth.instance.logout();
        expect(future, isA<Future>());
      });
    });
    
    group('State Access', () {
      test('should return false for isAuthenticated when not configured', () {
        expect(QuestionAuth.instance.isAuthenticated, isFalse);
      });
      
      test('should return null for currentUser when not configured', () {
        expect(QuestionAuth.instance.currentUser, isNull);
      });
      
      test('should return unknown state when not configured', () {
        final state = QuestionAuth.instance.currentAuthState;
        expect(state.status, equals(AuthStatus.unknown));
      });
      
      test('should access authStateStream when configured', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        final stream = QuestionAuth.instance.authStateStream;
        expect(stream, isA<Stream<AuthState>>());
      });
      
      test('should access isAuthenticated when configured', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        final isAuth = QuestionAuth.instance.isAuthenticated;
        expect(isAuth, isA<bool>());
      });
      
      test('should access currentUser when configured', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        final user = QuestionAuth.instance.currentUser;
        expect(user, isNull); // Should be null initially
      });
      
      test('should access currentAuthState when configured', () {
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        final state = QuestionAuth.instance.currentAuthState;
        expect(state, isA<AuthState>());
      });
    });
    
    group('AuthConfig', () {
      test('should create config with required parameters', () {
        const config = AuthConfig(baseUrl: 'https://api.example.com');
        
        expect(config.baseUrl, equals('https://api.example.com'));
        expect(config.apiVersion, equals('v1'));
        expect(config.timeout, equals(const Duration(seconds: 30)));
        expect(config.enableLogging, isFalse);
        expect(config.defaultHeaders, isEmpty);
      });
      
      test('should create config with all parameters', () {
        const config = AuthConfig(
          baseUrl: 'https://api.example.com',
          apiVersion: 'v2',
          timeout: Duration(seconds: 60),
          enableLogging: true,
          defaultHeaders: {'Custom-Header': 'value'},
        );
        
        expect(config.baseUrl, equals('https://api.example.com'));
        expect(config.apiVersion, equals('v2'));
        expect(config.timeout, equals(const Duration(seconds: 60)));
        expect(config.enableLogging, isTrue);
        expect(config.defaultHeaders, equals({'Custom-Header': 'value'}));
      });
    });
    
    group('Error Handling', () {
      test('should throw StateError for authStateStream when not configured', () {
        expect(
          () => QuestionAuth.instance.authStateStream,
          throwsA(isA<StateError>()),
        );
      });
      
      test('should throw StateError for initialize when not configured', () {
        expect(
          () => QuestionAuth.instance.initialize(),
          throwsA(isA<StateError>()),
        );
      });
      
      test('should throw StateError for getCurrentUser when not configured', () {
        expect(
          () => QuestionAuth.instance.getCurrentUser(),
          throwsA(isA<StateError>()),
        );
      });
      
      test('should throw StateError for logout when not configured', () {
        expect(
          () => QuestionAuth.instance.logout(),
          throwsA(isA<StateError>()),
        );
      });
    });
    
    group('Integration', () {
      test('should maintain state across multiple calls', () {
        // Configure once
        QuestionAuth.instance.configure(
          baseUrl: 'https://api.example.com',
        );
        
        // Multiple calls should work without reconfiguration
        final isAuth1 = QuestionAuth.instance.isAuthenticated;
        final user1 = QuestionAuth.instance.currentUser;
        final state1 = QuestionAuth.instance.currentAuthState;
        
        expect(isAuth1, isA<bool>());
        expect(user1, isNull);
        expect(state1, isA<AuthState>());
      });
      
      test('should handle reconfiguration', () {
        // Initial configuration
        QuestionAuth.instance.configure(
          baseUrl: 'https://api1.example.com',
        );
        
        // Reconfigure with different settings
        QuestionAuth.instance.configure(
          baseUrl: 'https://api2.example.com',
          apiVersion: 'v2',
        );
        
        // Should still work after reconfiguration
        final isAuth = QuestionAuth.instance.isAuthenticated;
        expect(isAuth, isA<bool>());
      });
    });
  });
}