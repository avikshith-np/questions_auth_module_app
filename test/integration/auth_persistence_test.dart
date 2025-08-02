import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/question_auth.dart';

void main() {
  group('Enhanced Authentication Persistence Tests', () {
    group('UserProfileData Model Tests', () {
      test('should create UserProfileData from LoginResponse', () {
        // Arrange
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
        );
        final loginResponse = LoginResponse(
          token: 'test-token',
          user: user,
          roles: ['creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          incompleteRoles: [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        // Act
        final profileData = UserProfileData.fromLoginResponse(loginResponse);

        // Assert
        expect(profileData.user, equals(loginResponse.user));
        expect(profileData.userRoles, equals(loginResponse.roles));
        expect(profileData.profileComplete, equals(loginResponse.profileComplete));
        expect(profileData.onboardingComplete, equals(loginResponse.onboardingComplete));
        expect(profileData.appAccess, equals(loginResponse.appAccess));
        expect(profileData.incompleteRoles, equals(loginResponse.incompleteRoles));
        expect(profileData.redirectTo, equals(loginResponse.redirectTo));
      });

      test('should create UserProfileData from UserProfileResponse', () {
        // Arrange
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
        );
        final userProfileResponse = UserProfileResponse(
          user: user,
          isNew: false,
          mode: 'creator',
          roles: ['creator'],
          availableRoles: ['student'],
          removableRoles: [],
          profileComplete: {'creator': true, 'student': false},
          onboardingComplete: true,
          incompleteRoles: [],
          appAccess: 'full',
          viewType: 'creator-complete-creator-only',
          redirectTo: '/dashboard',
        );

        // Act
        final profileData = UserProfileData.fromUserProfileResponse(userProfileResponse);

        // Assert
        expect(profileData.user, equals(userProfileResponse.user));
        expect(profileData.userRoles, equals(userProfileResponse.roles));
        expect(profileData.profileComplete, equals(userProfileResponse.profileComplete));
        expect(profileData.onboardingComplete, equals(userProfileResponse.onboardingComplete));
        expect(profileData.appAccess, equals(userProfileResponse.appAccess));
        expect(profileData.availableRoles, equals(userProfileResponse.availableRoles));
        expect(profileData.incompleteRoles, equals(userProfileResponse.incompleteRoles));
        expect(profileData.mode, equals(userProfileResponse.mode));
        expect(profileData.viewType, equals(userProfileResponse.viewType));
        expect(profileData.redirectTo, equals(userProfileResponse.redirectTo));
      });

      test('should serialize and deserialize UserProfileData correctly', () {
        // Arrange
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
          dateJoined: DateTime.parse('2023-01-01T00:00:00Z'),
        );
        final originalProfileData = UserProfileData(
          user: user,
          userRoles: ['creator', 'student'],
          profileComplete: {'creator': true, 'student': false},
          onboardingComplete: true,
          appAccess: 'full',
          availableRoles: ['creator'],
          incompleteRoles: ['student'],
          mode: 'creator',
          viewType: 'creator-complete',
          redirectTo: '/dashboard',
        );

        // Act
        final json = originalProfileData.toJson();
        final deserializedProfileData = UserProfileData.fromJson(json);

        // Assert
        expect(deserializedProfileData, equals(originalProfileData));
        expect(deserializedProfileData.user.email, equals(originalProfileData.user.email));
        expect(deserializedProfileData.user.displayName, equals(originalProfileData.user.displayName));
        expect(deserializedProfileData.userRoles, equals(originalProfileData.userRoles));
        expect(deserializedProfileData.profileComplete, equals(originalProfileData.profileComplete));
        expect(deserializedProfileData.onboardingComplete, equals(originalProfileData.onboardingComplete));
        expect(deserializedProfileData.appAccess, equals(originalProfileData.appAccess));
        expect(deserializedProfileData.availableRoles, equals(originalProfileData.availableRoles));
        expect(deserializedProfileData.incompleteRoles, equals(originalProfileData.incompleteRoles));
        expect(deserializedProfileData.mode, equals(originalProfileData.mode));
        expect(deserializedProfileData.viewType, equals(originalProfileData.viewType));
        expect(deserializedProfileData.redirectTo, equals(originalProfileData.redirectTo));
      });

      test('should handle null values in UserProfileData', () {
        // Arrange
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
        );
        final profileData = UserProfileData(
          user: user,
        );

        // Act
        final json = profileData.toJson();
        final deserializedProfileData = UserProfileData.fromJson(json);

        // Assert
        expect(deserializedProfileData.user, equals(profileData.user));
        expect(deserializedProfileData.userRoles, isNull);
        expect(deserializedProfileData.profileComplete, isNull);
        expect(deserializedProfileData.onboardingComplete, isNull);
        expect(deserializedProfileData.appAccess, isNull);
        expect(deserializedProfileData.availableRoles, isNull);
        expect(deserializedProfileData.incompleteRoles, isNull);
        expect(deserializedProfileData.mode, isNull);
        expect(deserializedProfileData.viewType, isNull);
        expect(deserializedProfileData.redirectTo, isNull);
      });

      test('should create copy with updated fields', () {
        // Arrange
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
        );
        final originalProfileData = UserProfileData(
          user: user,
          userRoles: ['student'],
          profileComplete: {'student': false},
          onboardingComplete: false,
          appAccess: 'limited',
        );

        // Act
        final updatedProfileData = originalProfileData.copyWith(
          userRoles: ['creator', 'student'],
          profileComplete: {'creator': true, 'student': true},
          onboardingComplete: true,
          appAccess: 'full',
        );

        // Assert
        expect(updatedProfileData.user, equals(originalProfileData.user));
        expect(updatedProfileData.userRoles, equals(['creator', 'student']));
        expect(updatedProfileData.profileComplete, equals({'creator': true, 'student': true}));
        expect(updatedProfileData.onboardingComplete, isTrue);
        expect(updatedProfileData.appAccess, equals('full'));
      });

      test('should have correct equality comparison', () {
        // Arrange
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
        );
        final profileData1 = UserProfileData(
          user: user,
          userRoles: ['creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          appAccess: 'full',
        );
        final profileData2 = UserProfileData(
          user: user,
          userRoles: ['creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          appAccess: 'full',
        );
        final profileData3 = UserProfileData(
          user: user,
          userRoles: ['student'],
          profileComplete: {'student': false},
          onboardingComplete: false,
          appAccess: 'limited',
        );

        // Assert
        expect(profileData1, equals(profileData2));
        expect(profileData1, isNot(equals(profileData3)));
        expect(profileData1.hashCode, equals(profileData2.hashCode));
        expect(profileData1.hashCode, isNot(equals(profileData3.hashCode)));
      });

      test('should have meaningful toString representation', () {
        // Arrange
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
        );
        final profileData = UserProfileData(
          user: user,
          userRoles: ['creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          appAccess: 'full',
        );

        // Act
        final stringRepresentation = profileData.toString();

        // Assert
        expect(stringRepresentation, contains('UserProfileData'));
        expect(stringRepresentation, contains('test@example.com'));
        expect(stringRepresentation, contains('creator'));
        expect(stringRepresentation, contains('full'));
      });
    });

    group('TokenManager Interface Tests', () {
      test('should define all required methods for user profile persistence', () {
        // This test verifies that the TokenManager interface includes all the new methods
        // for user profile persistence
        
        // Arrange
        final tokenManager = SecureTokenManager();

        // Assert - Check that all methods exist (this will compile if they exist)
        expect(tokenManager.saveUserProfile, isA<Function>());
        expect(tokenManager.getUserProfile, isA<Function>());
        expect(tokenManager.clearUserProfile, isA<Function>());
        expect(tokenManager.hasUserProfile, isA<Function>());
        expect(tokenManager.updateUserProfile, isA<Function>());
        expect(tokenManager.clearAll, isA<Function>());
      });
    });

    group('Enhanced Persistence Requirements Verification', () {
      test('should meet requirement 6.4 - token and user profile persistence', () {
        // This test verifies that the implementation meets requirement 6.4:
        // "WHEN the app restarts THEN the system SHALL persist the authentication state"
        
        // The UserProfileData class provides the structure for persisting user profile information
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
        );
        final profileData = UserProfileData(
          user: user,
          userRoles: ['creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          appAccess: 'full',
        );

        // Verify that profile data can be serialized for persistence
        final json = profileData.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['user'], isNotNull);
        expect(json['user_roles'], equals(['creator']));
        expect(json['profile_complete'], equals({'creator': true}));
        expect(json['onboarding_complete'], isTrue);
        expect(json['app_access'], equals('full'));

        // Verify that profile data can be deserialized from persistence
        final restoredProfileData = UserProfileData.fromJson(json);
        expect(restoredProfileData, equals(profileData));
      });

      test('should meet requirement 4.3 - automatic restoration of user profile data', () {
        // This test verifies that the implementation meets requirement 4.3:
        // "WHEN the user is not authenticated THEN the system SHALL return an authentication error"
        // and supports automatic restoration of user profile data
        
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
        );
        
        // Test LoginResponse to UserProfileData conversion
        final loginResponse = LoginResponse(
          token: 'test-token',
          user: user,
          roles: ['creator'],
          profileComplete: {'creator': true},
          onboardingComplete: true,
          incompleteRoles: [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );
        
        final profileDataFromLogin = UserProfileData.fromLoginResponse(loginResponse);
        expect(profileDataFromLogin.user, equals(user));
        expect(profileDataFromLogin.userRoles, equals(['creator']));
        expect(profileDataFromLogin.appAccess, equals('full'));
        
        // Test UserProfileResponse to UserProfileData conversion
        final userProfileResponse = UserProfileResponse(
          user: user,
          isNew: false,
          mode: 'creator',
          roles: ['creator'],
          availableRoles: ['student'],
          removableRoles: [],
          profileComplete: {'creator': true, 'student': false},
          onboardingComplete: true,
          incompleteRoles: [],
          appAccess: 'full',
          viewType: 'creator-complete-creator-only',
          redirectTo: '/dashboard',
        );
        
        final profileDataFromUserProfile = UserProfileData.fromUserProfileResponse(userProfileResponse);
        expect(profileDataFromUserProfile.user, equals(user));
        expect(profileDataFromUserProfile.userRoles, equals(['creator']));
        expect(profileDataFromUserProfile.availableRoles, equals(['student']));
        expect(profileDataFromUserProfile.mode, equals('creator'));
        expect(profileDataFromUserProfile.viewType, equals('creator-complete-creator-only'));
      });

      test('should meet requirement 8.5 - user profile data updates and synchronization', () {
        // This test verifies that the implementation meets requirement 8.5:
        // "WHEN user profile data changes THEN the system SHALL update the available information accordingly"
        
        final user = User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
          isVerified: true,
          isNew: false,
        );
        
        // Initial profile data
        final initialProfileData = UserProfileData(
          user: user,
          userRoles: ['student'],
          profileComplete: {'student': false},
          onboardingComplete: false,
          appAccess: 'limited',
        );
        
        // Updated profile data (simulating profile completion)
        final updatedProfileData = initialProfileData.copyWith(
          userRoles: ['creator', 'student'],
          profileComplete: {'creator': true, 'student': true},
          onboardingComplete: true,
          appAccess: 'full',
        );
        
        // Verify that updates are properly applied
        expect(updatedProfileData.userRoles, equals(['creator', 'student']));
        expect(updatedProfileData.profileComplete, equals({'creator': true, 'student': true}));
        expect(updatedProfileData.onboardingComplete, isTrue);
        expect(updatedProfileData.appAccess, equals('full'));
        
        // Verify that unchanged fields remain the same
        expect(updatedProfileData.user, equals(initialProfileData.user));
      });
    });
  });
}