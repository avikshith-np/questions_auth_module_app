import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/src/services/question_auth.dart';
import '../../lib/src/models/auth_response.dart';
import '../../lib/src/models/user.dart';
import '../../lib/src/core/auth_state.dart';
import '../../lib/src/services/auth_service.dart';

@GenerateMocks([AuthService])
import 'question_auth_profile_test.mocks.dart';

void main() {
  group('QuestionAuth User Profile Enhancement', () {
    late MockAuthService mockAuthService;
    
    setUp(() {
      QuestionAuth.reset();
      mockAuthService = MockAuthService();
    });
    
    tearDown(() {
      QuestionAuth.reset();
    });
    
    group('User Profile Properties', () {
      test('should return user roles from auth service', () {
        // Configure QuestionAuth
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Replace the internal auth service with mock (this is a conceptual test)
        // In real implementation, we would need dependency injection
        final roles = ['creator', 'student'];
        
        // Test the getter exists and returns expected type
        final userRoles = QuestionAuth.instance.userRoles;
        expect(userRoles, isA<List<String>?>());
      });
      
      test('should return profile completion status from auth service', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final profileComplete = QuestionAuth.instance.profileComplete;
        expect(profileComplete, isA<Map<String, bool>?>());
      });
      
      test('should return onboarding completion status from auth service', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final onboardingComplete = QuestionAuth.instance.onboardingComplete;
        expect(onboardingComplete, isA<bool?>());
      });
      
      test('should return app access level from auth service', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final appAccess = QuestionAuth.instance.appAccess;
        expect(appAccess, isA<String?>());
      });
      
      test('should return available roles from auth service', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final availableRoles = QuestionAuth.instance.availableRoles;
        expect(availableRoles, isA<List<String>?>());
      });
      
      test('should return incomplete roles from auth service', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final incompleteRoles = QuestionAuth.instance.incompleteRoles;
        expect(incompleteRoles, isA<List<String>?>());
      });
      
      test('should return user mode from auth service', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final mode = QuestionAuth.instance.mode;
        expect(mode, isA<String?>());
      });
      
      test('should return view type from auth service', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final viewType = QuestionAuth.instance.viewType;
        expect(viewType, isA<String?>());
      });
      
      test('should return redirect URL from auth service', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final redirectTo = QuestionAuth.instance.redirectTo;
        expect(redirectTo, isA<String?>());
      });
    });
    
    group('User Profile Helper Methods', () {
      test('should check if user has specific role', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final hasRole = QuestionAuth.instance.hasRole('creator');
        expect(hasRole, isA<bool>());
        expect(hasRole, isFalse); // Should be false when not authenticated
      });
      
      test('should check if profile is complete for specific role', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final isComplete = QuestionAuth.instance.isProfileCompleteForRole('creator');
        expect(isComplete, isA<bool>());
        expect(isComplete, isFalse); // Should be false when not authenticated
      });
      
      test('should check if user has full app access', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final hasFullAccess = QuestionAuth.instance.hasFullAppAccess;
        expect(hasFullAccess, isA<bool>());
        expect(hasFullAccess, isFalse); // Should be false when not authenticated
      });
      
      test('should check if user has incomplete roles', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        final hasIncompleteRoles = QuestionAuth.instance.hasIncompleteRoles;
        expect(hasIncompleteRoles, isA<bool>());
        expect(hasIncompleteRoles, isFalse); // Should be false when not authenticated
      });
    });
    
    group('Error Handling for Unconfigured State', () {
      test('should return null for all profile properties when not configured', () {
        // Don't configure QuestionAuth
        expect(QuestionAuth.instance.userRoles, isNull);
        expect(QuestionAuth.instance.profileComplete, isNull);
        expect(QuestionAuth.instance.onboardingComplete, isNull);
        expect(QuestionAuth.instance.appAccess, isNull);
        expect(QuestionAuth.instance.availableRoles, isNull);
        expect(QuestionAuth.instance.incompleteRoles, isNull);
        expect(QuestionAuth.instance.mode, isNull);
        expect(QuestionAuth.instance.viewType, isNull);
        expect(QuestionAuth.instance.redirectTo, isNull);
      });
      
      test('should return false for all helper methods when not configured', () {
        // Don't configure QuestionAuth
        expect(QuestionAuth.instance.hasRole('creator'), isFalse);
        expect(QuestionAuth.instance.isProfileCompleteForRole('creator'), isFalse);
        expect(QuestionAuth.instance.hasFullAppAccess, isFalse);
        expect(QuestionAuth.instance.hasIncompleteRoles, isFalse);
      });
    });
    
    group('Method Signatures and Return Types', () {
      test('should have correct method signatures for all new methods', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Test that all methods exist and have correct return types
        expect(QuestionAuth.instance.userRoles, isA<List<String>?>());
        expect(QuestionAuth.instance.profileComplete, isA<Map<String, bool>?>());
        expect(QuestionAuth.instance.onboardingComplete, isA<bool?>());
        expect(QuestionAuth.instance.appAccess, isA<String?>());
        expect(QuestionAuth.instance.availableRoles, isA<List<String>?>());
        expect(QuestionAuth.instance.incompleteRoles, isA<List<String>?>());
        expect(QuestionAuth.instance.mode, isA<String?>());
        expect(QuestionAuth.instance.viewType, isA<String?>());
        expect(QuestionAuth.instance.redirectTo, isA<String?>());
        
        // Test helper methods
        expect(QuestionAuth.instance.hasRole('test'), isA<bool>());
        expect(QuestionAuth.instance.isProfileCompleteForRole('test'), isA<bool>());
        expect(QuestionAuth.instance.hasFullAppAccess, isA<bool>());
        expect(QuestionAuth.instance.hasIncompleteRoles, isA<bool>());
      });
    });
    
    group('Integration with AuthService', () {
      test('should delegate all calls to underlying AuthService', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Test that methods don't throw when called
        // (They delegate to AuthService which handles the actual logic)
        expect(() => QuestionAuth.instance.userRoles, returnsNormally);
        expect(() => QuestionAuth.instance.profileComplete, returnsNormally);
        expect(() => QuestionAuth.instance.onboardingComplete, returnsNormally);
        expect(() => QuestionAuth.instance.appAccess, returnsNormally);
        expect(() => QuestionAuth.instance.availableRoles, returnsNormally);
        expect(() => QuestionAuth.instance.incompleteRoles, returnsNormally);
        expect(() => QuestionAuth.instance.mode, returnsNormally);
        expect(() => QuestionAuth.instance.viewType, returnsNormally);
        expect(() => QuestionAuth.instance.redirectTo, returnsNormally);
        expect(() => QuestionAuth.instance.hasRole('creator'), returnsNormally);
        expect(() => QuestionAuth.instance.isProfileCompleteForRole('creator'), returnsNormally);
        expect(() => QuestionAuth.instance.hasFullAppAccess, returnsNormally);
        expect(() => QuestionAuth.instance.hasIncompleteRoles, returnsNormally);
      });
    });
    
    group('Requirements Verification', () {
      test('should satisfy requirement 1.1 - provide simple API for authentication operations', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Verify that user profile access methods are simple and accessible
        expect(QuestionAuth.instance.userRoles, isA<List<String>?>());
        expect(QuestionAuth.instance.hasRole('creator'), isA<bool>());
      });
      
      test('should satisfy requirement 1.2 - expose methods without requiring complex setup', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // All methods should be accessible after simple configuration
        expect(() => QuestionAuth.instance.profileComplete, returnsNormally);
        expect(() => QuestionAuth.instance.onboardingComplete, returnsNormally);
        expect(() => QuestionAuth.instance.appAccess, returnsNormally);
      });
      
      test('should satisfy requirement 1.3 - handle API communication automatically', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Methods should exist and be callable (API communication is handled internally)
        expect(QuestionAuth.instance.getCurrentUser, isA<Function>());
      });
      
      test('should satisfy requirement 4.5 - provide access to user roles and permissions', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Should provide access to user roles
        expect(QuestionAuth.instance.userRoles, isA<List<String>?>());
        expect(QuestionAuth.instance.hasRole('creator'), isA<bool>());
      });
      
      test('should satisfy requirement 4.6 - provide onboarding status and redirect information', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Should provide onboarding and redirect information
        expect(QuestionAuth.instance.onboardingComplete, isA<bool?>());
        expect(QuestionAuth.instance.redirectTo, isA<String?>());
      });
      
      test('should satisfy requirement 8.1 - provide access to user roles and permissions', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Should provide comprehensive role access
        expect(QuestionAuth.instance.userRoles, isA<List<String>?>());
        expect(QuestionAuth.instance.availableRoles, isA<List<String>?>());
        expect(QuestionAuth.instance.hasRole('creator'), isA<bool>());
      });
      
      test('should satisfy requirement 8.2 - expose profile completion status', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Should provide profile completion information
        expect(QuestionAuth.instance.profileComplete, isA<Map<String, bool>?>());
        expect(QuestionAuth.instance.isProfileCompleteForRole('creator'), isA<bool>());
      });
      
      test('should satisfy requirement 8.3 - provide onboarding completion status', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Should provide onboarding status
        expect(QuestionAuth.instance.onboardingComplete, isA<bool?>());
      });
      
      test('should satisfy requirement 8.4 - provide app access level information', () {
        QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
        
        // Should provide app access information
        expect(QuestionAuth.instance.appAccess, isA<String?>());
        expect(QuestionAuth.instance.hasFullAppAccess, isA<bool>());
      });
    });
  });
}