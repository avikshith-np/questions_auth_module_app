import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:question_auth/question_auth.dart';

import 'auth_test_utils.dart';
import 'mock_implementations.dart';

/// Example tests demonstrating how to use the authentication test utilities
/// 
/// These tests serve as documentation and examples for other developers
/// on how to properly test authentication-related functionality.
void main() {
  group('AuthTestUtils Examples', () {
    group('Creating Test Data', () {
      test('should create valid signup request', () {
        final request = AuthTestUtils.createValidSignUpRequest();
        
        expect(request.email, equals('test@example.com'));
        expect(request.username, equals('testuser'));
        expect(request.password, equals('password123'));
        expect(request.confirmPassword, equals('password123'));
        
        // Validate that the request passes validation
        final errors = request.validate();
        expect(errors, isEmpty);
      });
      
      test('should create invalid signup request for testing validation', () {
        final request = AuthTestUtils.createInvalidSignUpRequest();
        
        expect(request.email, equals('invalid-email'));
        expect(request.username, isEmpty);
        expect(request.password, equals('short'));
        expect(request.confirmPassword, equals('different'));
        
        // Validate that the request fails validation
        final errors = request.validate();
        expect(errors, isNotEmpty);
      });
      
      test('should create test user with default values', () {
        final user = AuthTestUtils.createTestUser();
        
        expect(user.id, equals('1'));
        expect(user.email, equals('test@example.com'));
        expect(user.username, equals('testuser'));
        expect(user.createdAt, isNotNull);
      });
      
      test('should create test user with custom values', () {
        final customUser = AuthTestUtils.createTestUser(
          id: '123',
          email: 'custom@example.com',
          username: 'customuser',
        );
        
        expect(customUser.id, equals('123'));
        expect(customUser.email, equals('custom@example.com'));
        expect(customUser.username, equals('customuser'));
      });
      
      test('should create successful auth response', () {
        final response = AuthTestUtils.createSuccessResponse();
        
        expect(response.success, isTrue);
        expect(response.token, equals('test-token-123'));
        expect(response.user, isNotNull);
        expect(response.message, equals('Operation successful'));
      });
      
      test('should create failed auth response', () {
        final response = AuthTestUtils.createFailureResponse(
          message: 'Custom error message',
        );
        
        expect(response.success, isFalse);
        expect(response.token, isNull);
        expect(response.user, isNull);
        expect(response.message, equals('Custom error message'));
      });
    });
    
    group('Creating Auth States', () {
      test('should create authenticated state', () {
        final state = AuthTestUtils.createAuthenticatedState();
        
        expect(state.status, equals(AuthStatus.authenticated));
        expect(state.user, isNotNull);
        expect(state.error, isNull);
      });
      
      test('should create unauthenticated state with error', () {
        final state = AuthTestUtils.createUnauthenticatedState(
          error: 'Session expired',
        );
        
        expect(state.status, equals(AuthStatus.unauthenticated));
        expect(state.user, isNull);
        expect(state.error, equals('Session expired'));
      });
      
      test('should create unknown state', () {
        final state = AuthTestUtils.createUnknownState();
        
        expect(state.status, equals(AuthStatus.unknown));
        expect(state.user, isNull);
        expect(state.error, isNull);
      });
    });
    
    group('Creating API Response Data', () {
      test('should create signup API response', () {
        final response = AuthTestUtils.createSignUpApiResponse();
        
        expect(response['success'], isTrue);
        expect(response['token'], equals('test-token-123'));
        expect(response['user'], isA<Map<String, dynamic>>());
        expect(response['message'], equals('Registration successful'));
      });
      
      test('should create login API response with custom data', () {
        final response = AuthTestUtils.createLoginApiResponse(
          token: 'custom-token',
          email: 'custom@example.com',
          message: 'Welcome back!',
        );
        
        expect(response['token'], equals('custom-token'));
        expect(response['user']['email'], equals('custom@example.com'));
        expect(response['message'], equals('Welcome back!'));
      });
      
      test('should create error API response', () {
        final response = AuthTestUtils.createErrorApiResponse(
          message: 'Validation failed',
          statusCode: 400,
          code: 'VALIDATION_ERROR',
          fieldErrors: {
            'email': ['Invalid format'],
            'password': ['Too short'],
          },
        );
        
        expect(response['success'], isFalse);
        expect(response['message'], equals('Validation failed'));
        expect(response['status_code'], equals(400));
        expect(response['code'], equals('VALIDATION_ERROR'));
        expect(response['errors'], isA<Map<String, List<String>>>());
      });
    });
    
    group('Exception Verification', () {
      test('should verify validation exception', () {
        final exception = ValidationException('Validation failed', {
          'email': ['Invalid format'],
          'password': ['Too short'],
        });
        
        AuthTestUtils.verifyValidationException(exception, {
          'email': ['Invalid format'],
          'password': ['Too short'],
        });
      });
      
      test('should verify API exception', () {
        final exception = ApiException('Not found', 404, 'NOT_FOUND');
        
        AuthTestUtils.verifyApiException(
          exception,
          404,
          'Not found',
          expectedCode: 'NOT_FOUND',
        );
      });
      
      test('should verify generic exception', () {
        final exception = NetworkException('Connection failed');
        
        AuthTestUtils.verifyException<NetworkException>(
          exception,
          'Connection failed',
        );
      });
    });
  });
  
  group('MockFactory Examples', () {
    test('should create authenticated mock auth service', () {
      final mockService = MockFactory.createAuthenticatedMockAuthService();
      
      expect(mockService.isAuthenticated, isTrue);
      expect(mockService.currentUser, isNotNull);
      expect(mockService.currentAuthState.status, equals(AuthStatus.authenticated));
    });
    
    test('should create unauthenticated mock auth service', () {
      final mockService = MockFactory.createUnauthenticatedMockAuthService(
        error: 'Session expired',
      );
      
      expect(mockService.isAuthenticated, isFalse);
      expect(mockService.currentUser, isNull);
      expect(mockService.currentAuthState.error, equals('Session expired'));
    });
    
    test('should create successful mock repository', () async {
      final mockRepo = MockFactory.createSuccessfulMockRepository();
      
      final signUpResult = await mockRepo.signUp(
        AuthTestUtils.createValidSignUpRequest(),
      );
      expect(signUpResult.success, isTrue);
      
      final loginResult = await mockRepo.login(
        AuthTestUtils.createValidLoginRequest(),
      );
      expect(loginResult.success, isTrue);
      
      final user = await mockRepo.getCurrentUser();
      expect(user, isNotNull);
    });
    
    test('should create validation error mock repository', () async {
      final mockRepo = MockFactory.createValidationErrorMockRepository();
      
      expect(
        () => mockRepo.signUp(AuthTestUtils.createInvalidSignUpRequest()),
        throwsA(isA<ValidationException>()),
      );
      
      expect(
        () => mockRepo.login(AuthTestUtils.createInvalidLoginRequest()),
        throwsA(isA<ValidationException>()),
      );
    });
    
    test('should create mock token manager with token', () async {
      final mockTokenManager = MockFactory.createTokenMockTokenManager(
        token: 'test-token-456',
      );
      
      final token = await mockTokenManager.getToken();
      expect(token, equals('test-token-456'));
      
      final hasToken = await mockTokenManager.hasValidToken();
      expect(hasToken, isTrue);
    });
    
    test('should create empty mock token manager', () async {
      final mockTokenManager = MockFactory.createEmptyMockTokenManager();
      
      final token = await mockTokenManager.getToken();
      expect(token, isNull);
      
      final hasToken = await mockTokenManager.hasValidToken();
      expect(hasToken, isFalse);
    });
  });
  
  group('Mock Service State Management Examples', () {
    late MockAuthService mockService;
    
    setUp(() {
      mockService = MockFactory.createMockAuthService();
    });
    
    tearDown(() {
      mockService.dispose();
    });
    
    test('should simulate authentication state changes', () async {
      // Start with unknown state
      expect(mockService.currentAuthState.status, equals(AuthStatus.unknown));
      
      // Simulate authentication
      final user = AuthTestUtils.createTestUser();
      mockService.simulateAuthentication(user);
      
      expect(mockService.isAuthenticated, isTrue);
      expect(mockService.currentUser, equals(user));
      
      // Simulate logout
      mockService.simulateLogout();
      
      expect(mockService.isAuthenticated, isFalse);
      expect(mockService.currentUser, isNull);
    });
    
    test('should emit state changes through stream', () async {
      final states = <AuthStatus>[];
      
      mockService.authStateStream.listen((state) {
        states.add(state.status);
      });
      
      // Simulate authentication
      mockService.simulateAuthentication(AuthTestUtils.createTestUser());
      await Future.delayed(Duration.zero); // Allow stream to emit
      
      // Simulate logout
      mockService.simulateLogout();
      await Future.delayed(Duration.zero); // Allow stream to emit
      
      expect(states, contains(AuthStatus.authenticated));
      expect(states, contains(AuthStatus.unauthenticated));
    });
  });
  
  group('Error Mock Examples', () {
    test('should create network error mock API client', () async {
      final mockClient = NetworkErrorMockApiClient();
      
      expect(
        () => mockClient.post('test', {}),
        throwsA(isA<NetworkException>()),
      );
      
      expect(
        () => mockClient.get('test'),
        throwsA(isA<NetworkException>()),
      );
    });
    
    test('should create API error mock API client', () async {
      final mockClient = ApiErrorMockApiClient(
        statusCode: 401,
        message: 'Unauthorized',
        code: 'UNAUTHORIZED',
      );
      
      try {
        await mockClient.post('test', {});
        fail('Expected ApiException');
      } catch (e) {
        AuthTestUtils.verifyApiException(
          e as ApiException,
          401,
          'Unauthorized',
          expectedCode: 'UNAUTHORIZED',
        );
      }
    });
    
    test('should create token error mock token manager', () async {
      final mockTokenManager = TokenErrorMockTokenManager();
      
      expect(
        () => mockTokenManager.saveToken('token'),
        throwsA(isA<TokenException>()),
      );
      
      expect(
        () => mockTokenManager.getToken(),
        throwsA(isA<TokenException>()),
      );
      
      expect(
        () => mockTokenManager.clearToken(),
        throwsA(isA<TokenException>()),
      );
    });
  });
  
  group('Stream Testing Examples', () {
    test('should wait for specific stream value', () async {
      final controller = StreamController<AuthState>();
      
      // Start waiting for authenticated state
      final future = AuthTestUtils.waitForStreamValue(
        controller.stream,
        (state) => state.status == AuthStatus.authenticated,
        timeout: const Duration(seconds: 1),
      );
      
      // Emit some states
      controller.add(AuthTestUtils.createUnknownState());
      controller.add(AuthTestUtils.createUnauthenticatedState());
      controller.add(AuthTestUtils.createAuthenticatedState());
      
      // Should complete with authenticated state
      final result = await future;
      expect(result.status, equals(AuthStatus.authenticated));
      
      await controller.close();
    });
    
    test('should timeout when expected value is not emitted', () async {
      final controller = StreamController<AuthState>();
      
      // Start waiting for authenticated state with short timeout
      final future = AuthTestUtils.waitForStreamValue(
        controller.stream,
        (state) => state.status == AuthStatus.authenticated,
        timeout: const Duration(milliseconds: 100),
      );
      
      // Emit only unauthenticated state
      controller.add(AuthTestUtils.createUnauthenticatedState());
      
      // Should timeout
      expect(
        () => future,
        throwsA(isA<Exception>()),
      );
      
      await controller.close();
    });
  });
  
  group('Widget Testing Examples', () {
    testWidgets('should create test widget environment', (tester) async {
      final testWidget = Text('Test Widget');
      
      await WidgetTestHelper.pumpAuthWidget(
        tester,
        testWidget,
        configureQuestionAuth: true,
      );
      
      expect(find.text('Test Widget'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
    
    testWidgets('should create basic auth widget wrapper', (tester) async {
      final testWidget = AuthTestWidget(
        child: Text('Auth Test Widget'),
        configureQuestionAuth: false, // Don't configure to avoid state issues
      );
      
      await tester.pumpWidget(testWidget);
      
      expect(find.text('Auth Test Widget'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
    
    testWidgets('should create auth state widget wrapper', (tester) async {
      final testWidget = AuthStateTestWidget(
        child: Text('State Test Widget'),
        initialState: AuthTestUtils.createUnknownState(),
      );
      
      await tester.pumpWidget(testWidget);
      
      expect(find.text('State Test Widget'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}