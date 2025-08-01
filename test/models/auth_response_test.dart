import 'package:flutter_test/flutter_test.dart';
import 'package:question_auth/src/models/auth_response.dart';
import 'package:question_auth/src/models/user.dart';

void main() {
  group('SignUpData Tests', () {
    group('fromJson', () {
      test('should create SignUpData from valid JSON', () {
        final json = {
          'email': 'test@example.com',
          'verification_token_expires_in': '10 minutes',
        };

        final signUpData = SignUpData.fromJson(json);

        expect(signUpData.email, 'test@example.com');
        expect(signUpData.verificationTokenExpiresIn, '10 minutes');
      });

      test('should handle null values gracefully', () {
        final json = {
          'email': null,
          'verification_token_expires_in': null,
        };

        final signUpData = SignUpData.fromJson(json);

        expect(signUpData.email, '');
        expect(signUpData.verificationTokenExpiresIn, '');
      });
    });

    group('toJson', () {
      test('should convert SignUpData to JSON', () {
        const signUpData = SignUpData(
          email: 'test@example.com',
          verificationTokenExpiresIn: '10 minutes',
        );

        final json = signUpData.toJson();

        expect(json['email'], 'test@example.com');
        expect(json['verification_token_expires_in'], '10 minutes');
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        const data1 = SignUpData(
          email: 'test@example.com',
          verificationTokenExpiresIn: '10 minutes',
        );

        const data2 = SignUpData(
          email: 'test@example.com',
          verificationTokenExpiresIn: '10 minutes',
        );

        expect(data1, equals(data2));
        expect(data1.hashCode, equals(data2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const data1 = SignUpData(
          email: 'test@example.com',
          verificationTokenExpiresIn: '10 minutes',
        );

        const data2 = SignUpData(
          email: 'different@example.com',
          verificationTokenExpiresIn: '10 minutes',
        );

        expect(data1, isNot(equals(data2)));
      });
    });
  });

  group('SignUpResponse Tests', () {
    group('fromJson', () {
      test('should create SignUpResponse from valid JSON with data', () {
        final json = {
          'detail': 'Registration successful! Please check your email to verify your account.',
          'data': {
            'email': 'test@example.com',
            'verification_token_expires_in': '10 minutes',
          },
        };

        final response = SignUpResponse.fromJson(json);

        expect(response.detail, 'Registration successful! Please check your email to verify your account.');
        expect(response.data, isNotNull);
        expect(response.data!.email, 'test@example.com');
        expect(response.data!.verificationTokenExpiresIn, '10 minutes');
      });

      test('should create SignUpResponse from JSON without data', () {
        final json = {
          'detail': 'Registration successful!',
        };

        final response = SignUpResponse.fromJson(json);

        expect(response.detail, 'Registration successful!');
        expect(response.data, isNull);
      });
    });

    group('toJson', () {
      test('should convert SignUpResponse to JSON with data', () {
        const response = SignUpResponse(
          detail: 'Registration successful!',
          data: SignUpData(
            email: 'test@example.com',
            verificationTokenExpiresIn: '10 minutes',
          ),
        );

        final json = response.toJson();

        expect(json['detail'], 'Registration successful!');
        expect(json['data'], isNotNull);
        expect(json['data']['email'], 'test@example.com');
      });

      test('should convert SignUpResponse to JSON without data', () {
        const response = SignUpResponse(detail: 'Registration successful!');

        final json = response.toJson();

        expect(json['detail'], 'Registration successful!');
        expect(json.containsKey('data'), false);
      });
    });
  });

  group('LoginResponse Tests', () {
    group('fromJson', () {
      test('should create LoginResponse from valid JSON', () {
        final json = {
          'token': 'test-token-123',
          'user': {
            'email': 'test@example.com',
            'display_name': 'Test User',
            'is_verified': true,
            'is_new': false,
          },
          'roles': ['Creator'],
          'profile_complete': {
            'student': false,
            'creator': true,
          },
          'onboarding_complete': true,
          'incomplete_roles': [],
          'app_access': 'full',
          'redirect_to': '/dashboard',
        };

        final response = LoginResponse.fromJson(json);

        expect(response.token, 'test-token-123');
        expect(response.user.email, 'test@example.com');
        expect(response.user.displayName, 'Test User');
        expect(response.roles, ['Creator']);
        expect(response.profileComplete['student'], false);
        expect(response.profileComplete['creator'], true);
        expect(response.onboardingComplete, true);
        expect(response.incompleteRoles, isEmpty);
        expect(response.appAccess, 'full');
        expect(response.redirectTo, '/dashboard');
      });

      test('should handle missing optional fields with defaults', () {
        final json = {
          'token': 'test-token-123',
          'user': {
            'email': 'test@example.com',
            'display_name': 'Test User',
          },
        };

        final response = LoginResponse.fromJson(json);

        expect(response.token, 'test-token-123');
        expect(response.roles, isEmpty);
        expect(response.profileComplete, isEmpty);
        expect(response.onboardingComplete, false);
        expect(response.incompleteRoles, isEmpty);
        expect(response.appAccess, '');
        expect(response.redirectTo, '');
      });
    });

    group('toJson', () {
      test('should convert LoginResponse to JSON', () {
        final response = LoginResponse(
          token: 'test-token-123',
          user: const User(
            email: 'test@example.com',
            displayName: 'Test User',
          ),
          roles: const ['Creator'],
          profileComplete: const {'creator': true},
          onboardingComplete: true,
          incompleteRoles: const [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        final json = response.toJson();

        expect(json['token'], 'test-token-123');
        expect(json['user']['email'], 'test@example.com');
        expect(json['roles'], ['Creator']);
        expect(json['profile_complete']['creator'], true);
        expect(json['onboarding_complete'], true);
        expect(json['app_access'], 'full');
        expect(json['redirect_to'], '/dashboard');
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        final response1 = LoginResponse(
          token: 'test-token-123',
          user: const User(email: 'test@example.com', displayName: 'Test User'),
          roles: const ['Creator'],
          profileComplete: const {'creator': true},
          onboardingComplete: true,
          incompleteRoles: const [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        final response2 = LoginResponse(
          token: 'test-token-123',
          user: const User(email: 'test@example.com', displayName: 'Test User'),
          roles: const ['Creator'],
          profileComplete: const {'creator': true},
          onboardingComplete: true,
          incompleteRoles: const [],
          appAccess: 'full',
          redirectTo: '/dashboard',
        );

        expect(response1, equals(response2));
        expect(response1.hashCode, equals(response2.hashCode));
      });
    });
  });

  group('UserProfileResponse Tests', () {
    group('fromJson', () {
      test('should create UserProfileResponse from valid JSON', () {
        final json = {
          'user': {
            'email': 'test@example.com',
            'display_name': 'Test User',
            'is_active': true,
            'email_verified': true,
          },
          'is_new': false,
          'mode': 'student',
          'roles': ['student', 'creator'],
          'available_roles': ['creator'],
          'removable_roles': [],
          'profile_complete': {
            'student': true,
            'creator': false,
          },
          'onboarding_complete': true,
          'incomplete_roles': ['creator'],
          'app_access': 'full',
          'viewType': 'student-complete-student-only',
          'redirect_to': '/onboarding/profile',
        };

        final response = UserProfileResponse.fromJson(json);

        expect(response.user.email, 'test@example.com');
        expect(response.user.displayName, 'Test User');
        expect(response.isNew, false);
        expect(response.mode, 'student');
        expect(response.roles, ['student', 'creator']);
        expect(response.availableRoles, ['creator']);
        expect(response.removableRoles, isEmpty);
        expect(response.profileComplete['student'], true);
        expect(response.profileComplete['creator'], false);
        expect(response.onboardingComplete, true);
        expect(response.incompleteRoles, ['creator']);
        expect(response.appAccess, 'full');
        expect(response.viewType, 'student-complete-student-only');
        expect(response.redirectTo, '/onboarding/profile');
      });

      test('should handle missing optional fields with defaults', () {
        final json = {
          'user': {
            'email': 'test@example.com',
            'display_name': 'Test User',
          },
        };

        final response = UserProfileResponse.fromJson(json);

        expect(response.user.email, 'test@example.com');
        expect(response.isNew, false);
        expect(response.mode, '');
        expect(response.roles, isEmpty);
        expect(response.availableRoles, isEmpty);
        expect(response.removableRoles, isEmpty);
        expect(response.profileComplete, isEmpty);
        expect(response.onboardingComplete, false);
        expect(response.incompleteRoles, isEmpty);
        expect(response.appAccess, '');
        expect(response.viewType, '');
        expect(response.redirectTo, '');
      });
    });

    group('toJson', () {
      test('should convert UserProfileResponse to JSON', () {
        final response = UserProfileResponse(
          user: const User(
            email: 'test@example.com',
            displayName: 'Test User',
          ),
          isNew: false,
          mode: 'student',
          roles: const ['student'],
          availableRoles: const ['creator'],
          removableRoles: const [],
          profileComplete: const {'student': true},
          onboardingComplete: true,
          incompleteRoles: const [],
          appAccess: 'full',
          viewType: 'student-complete',
          redirectTo: '/dashboard',
        );

        final json = response.toJson();

        expect(json['user']['email'], 'test@example.com');
        expect(json['is_new'], false);
        expect(json['mode'], 'student');
        expect(json['roles'], ['student']);
        expect(json['available_roles'], ['creator']);
        expect(json['profile_complete']['student'], true);
        expect(json['onboarding_complete'], true);
        expect(json['app_access'], 'full');
        expect(json['viewType'], 'student-complete');
        expect(json['redirect_to'], '/dashboard');
      });
    });
  });

  group('LogoutResponse Tests', () {
    group('fromJson', () {
      test('should create LogoutResponse from valid JSON', () {
        final json = {
          'detail': 'Logged out successfully.',
        };

        final response = LogoutResponse.fromJson(json);

        expect(response.detail, 'Logged out successfully.');
      });

      test('should handle null detail gracefully', () {
        final json = {
          'detail': null,
        };

        final response = LogoutResponse.fromJson(json);

        expect(response.detail, '');
      });
    });

    group('toJson', () {
      test('should convert LogoutResponse to JSON', () {
        const response = LogoutResponse(detail: 'Logged out successfully.');

        final json = response.toJson();

        expect(json['detail'], 'Logged out successfully.');
      });
    });

    group('equality and hashCode', () {
      test('should be equal when detail matches', () {
        const response1 = LogoutResponse(detail: 'Logged out successfully.');
        const response2 = LogoutResponse(detail: 'Logged out successfully.');

        expect(response1, equals(response2));
        expect(response1.hashCode, equals(response2.hashCode));
      });

      test('should not be equal when detail differs', () {
        const response1 = LogoutResponse(detail: 'Logged out successfully.');
        const response2 = LogoutResponse(detail: 'Different message.');

        expect(response1, isNot(equals(response2)));
      });
    });
  });

  group('JSON serialization round-trip tests', () {
    test('SignUpResponse should maintain data integrity through serialization', () {
      const original = SignUpResponse(
        detail: 'Registration successful!',
        data: SignUpData(
          email: 'test@example.com',
          verificationTokenExpiresIn: '10 minutes',
        ),
      );

      final json = original.toJson();
      final deserialized = SignUpResponse.fromJson(json);

      expect(deserialized, equals(original));
    });

    test('LoginResponse should maintain data integrity through serialization', () {
      final original = LoginResponse(
        token: 'test-token-123',
        user: const User(
          email: 'test@example.com',
          displayName: 'Test User',
          isVerified: true,
        ),
        roles: const ['Creator'],
        profileComplete: const {'creator': true},
        onboardingComplete: true,
        incompleteRoles: const [],
        appAccess: 'full',
        redirectTo: '/dashboard',
      );

      final json = original.toJson();
      final deserialized = LoginResponse.fromJson(json);

      expect(deserialized, equals(original));
    });

    test('UserProfileResponse should maintain data integrity through serialization', () {
      final original = UserProfileResponse(
        user: const User(
          email: 'test@example.com',
          displayName: 'Test User',
          isActive: true,
          emailVerified: true,
        ),
        isNew: false,
        mode: 'student',
        roles: const ['student', 'creator'],
        availableRoles: const ['creator'],
        removableRoles: const [],
        profileComplete: const {'student': true, 'creator': false},
        onboardingComplete: true,
        incompleteRoles: const ['creator'],
        appAccess: 'full',
        viewType: 'student-complete',
        redirectTo: '/dashboard',
      );

      final json = original.toJson();
      final deserialized = UserProfileResponse.fromJson(json);

      expect(deserialized, equals(original));
    });

    test('LogoutResponse should maintain data integrity through serialization', () {
      const original = LogoutResponse(detail: 'Logged out successfully.');

      final json = original.toJson();
      final deserialized = LogoutResponse.fromJson(json);

      expect(deserialized, equals(original));
    });
  });
}