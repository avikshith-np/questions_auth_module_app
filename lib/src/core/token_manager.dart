import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/auth_response.dart';

/// User profile data for persistence
class UserProfileData {
  final User user;
  final List<String>? userRoles;
  final Map<String, bool>? profileComplete;
  final bool? onboardingComplete;
  final String? appAccess;
  final List<String>? availableRoles;
  final List<String>? incompleteRoles;
  final String? mode;
  final String? viewType;
  final String? redirectTo;

  const UserProfileData({
    required this.user,
    this.userRoles,
    this.profileComplete,
    this.onboardingComplete,
    this.appAccess,
    this.availableRoles,
    this.incompleteRoles,
    this.mode,
    this.viewType,
    this.redirectTo,
  });

  /// Creates UserProfileData from LoginResponse
  factory UserProfileData.fromLoginResponse(LoginResponse loginResponse) {
    return UserProfileData(
      user: loginResponse.user,
      userRoles: loginResponse.roles,
      profileComplete: loginResponse.profileComplete,
      onboardingComplete: loginResponse.onboardingComplete,
      appAccess: loginResponse.appAccess,
      incompleteRoles: loginResponse.incompleteRoles,
      redirectTo: loginResponse.redirectTo,
    );
  }

  /// Creates UserProfileData from UserProfileResponse
  factory UserProfileData.fromUserProfileResponse(UserProfileResponse profileResponse) {
    return UserProfileData(
      user: profileResponse.user,
      userRoles: profileResponse.roles,
      profileComplete: profileResponse.profileComplete,
      onboardingComplete: profileResponse.onboardingComplete,
      appAccess: profileResponse.appAccess,
      availableRoles: profileResponse.availableRoles,
      incompleteRoles: profileResponse.incompleteRoles,
      mode: profileResponse.mode,
      viewType: profileResponse.viewType,
      redirectTo: profileResponse.redirectTo,
    );
  }

  /// Creates UserProfileData from JSON
  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      userRoles: json['user_roles'] != null 
          ? List<String>.from(json['user_roles'] as List)
          : null,
      profileComplete: json['profile_complete'] != null
          ? Map<String, bool>.from(json['profile_complete'] as Map)
          : null,
      onboardingComplete: json['onboarding_complete'] as bool?,
      appAccess: json['app_access'] as String?,
      availableRoles: json['available_roles'] != null
          ? List<String>.from(json['available_roles'] as List)
          : null,
      incompleteRoles: json['incomplete_roles'] != null
          ? List<String>.from(json['incomplete_roles'] as List)
          : null,
      mode: json['mode'] as String?,
      viewType: json['view_type'] as String?,
      redirectTo: json['redirect_to'] as String?,
    );
  }

  /// Converts UserProfileData to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      if (userRoles != null) 'user_roles': userRoles,
      if (profileComplete != null) 'profile_complete': profileComplete,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (appAccess != null) 'app_access': appAccess,
      if (availableRoles != null) 'available_roles': availableRoles,
      if (incompleteRoles != null) 'incomplete_roles': incompleteRoles,
      if (mode != null) 'mode': mode,
      if (viewType != null) 'view_type': viewType,
      if (redirectTo != null) 'redirect_to': redirectTo,
    };
  }

  /// Creates a copy with updated fields
  UserProfileData copyWith({
    User? user,
    List<String>? userRoles,
    Map<String, bool>? profileComplete,
    bool? onboardingComplete,
    String? appAccess,
    List<String>? availableRoles,
    List<String>? incompleteRoles,
    String? mode,
    String? viewType,
    String? redirectTo,
  }) {
    return UserProfileData(
      user: user ?? this.user,
      userRoles: userRoles ?? this.userRoles,
      profileComplete: profileComplete ?? this.profileComplete,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      appAccess: appAccess ?? this.appAccess,
      availableRoles: availableRoles ?? this.availableRoles,
      incompleteRoles: incompleteRoles ?? this.incompleteRoles,
      mode: mode ?? this.mode,
      viewType: viewType ?? this.viewType,
      redirectTo: redirectTo ?? this.redirectTo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileData &&
        other.user == user &&
        _listEquals(other.userRoles, userRoles) &&
        _mapEquals(other.profileComplete, profileComplete) &&
        other.onboardingComplete == onboardingComplete &&
        other.appAccess == appAccess &&
        _listEquals(other.availableRoles, availableRoles) &&
        _listEquals(other.incompleteRoles, incompleteRoles) &&
        other.mode == mode &&
        other.viewType == viewType &&
        other.redirectTo == redirectTo;
  }

  @override
  int get hashCode => Object.hash(
    user,
    userRoles != null ? Object.hashAll(userRoles!) : null,
    profileComplete != null ? Object.hashAll(profileComplete!.entries.map((e) => Object.hash(e.key, e.value))) : null,
    onboardingComplete,
    appAccess,
    availableRoles != null ? Object.hashAll(availableRoles!) : null,
    incompleteRoles != null ? Object.hashAll(incompleteRoles!) : null,
    mode,
    viewType,
    redirectTo,
  );

  /// Helper method to compare lists
  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Helper method to compare maps
  bool _mapEquals(Map<String, bool>? a, Map<String, bool>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'UserProfileData(user: $user, userRoles: $userRoles, profileComplete: $profileComplete, onboardingComplete: $onboardingComplete, appAccess: $appAccess, availableRoles: $availableRoles, incompleteRoles: $incompleteRoles, mode: $mode, viewType: $viewType, redirectTo: $redirectTo)';
  }
}

/// Abstract interface for managing authentication tokens and user profile data
abstract class TokenManager {
  /// Save an authentication token securely
  Future<void> saveToken(String token);
  
  /// Retrieve the stored authentication token
  /// Returns null if no token is stored
  Future<String?> getToken();
  
  /// Clear the stored authentication token
  Future<void> clearToken();
  
  /// Check if a valid token exists
  /// Returns true if a token is stored, false otherwise
  Future<bool> hasValidToken();
  
  /// Check if the stored token is expired
  /// Returns true if token is expired or invalid, false if valid
  Future<bool> isTokenExpired();
  
  /// Get token expiration timestamp
  /// Returns null if no token or token doesn't have expiration info
  Future<DateTime?> getTokenExpiration();

  /// Save user profile data securely
  Future<void> saveUserProfile(UserProfileData profileData);

  /// Retrieve the stored user profile data
  /// Returns null if no profile data is stored
  Future<UserProfileData?> getUserProfile();

  /// Clear the stored user profile data
  Future<void> clearUserProfile();

  /// Check if user profile data exists
  /// Returns true if profile data is stored, false otherwise
  Future<bool> hasUserProfile();

  /// Update specific fields in the stored user profile data
  Future<void> updateUserProfile({
    User? user,
    List<String>? userRoles,
    Map<String, bool>? profileComplete,
    bool? onboardingComplete,
    String? appAccess,
    List<String>? availableRoles,
    List<String>? incompleteRoles,
    String? mode,
    String? viewType,
    String? redirectTo,
  });

  /// Clear all stored authentication data (token and profile)
  Future<void> clearAll();
}

/// Implementation of TokenManager using flutter_secure_storage
class SecureTokenManager implements TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _tokenMetadataKey = 'auth_token_metadata';
  static const String _userProfileKey = 'user_profile_data';
  
  final FlutterSecureStorage _storage;
  
  /// Creates a SecureTokenManager with optional custom storage
  /// If no storage is provided, uses default FlutterSecureStorage
  SecureTokenManager({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();
  
  @override
  Future<void> saveToken(String token) async {
    if (token.isEmpty) {
      throw ArgumentError('Token cannot be empty');
    }
    
    try {
      await _storage.write(key: _tokenKey, value: token);
      
      // Store token metadata with timestamp
      final metadata = {
        'savedAt': DateTime.now().toIso8601String(),
        'expiresAt': _extractTokenExpiration(token)?.toIso8601String(),
      };
      await _storage.write(key: _tokenMetadataKey, value: jsonEncode(metadata));
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }
  
  @override
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      throw Exception('Failed to retrieve token: $e');
    }
  }
  
  @override
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _tokenMetadataKey);
    } catch (e) {
      throw Exception('Failed to clear token: $e');
    }
  }

  @override
  Future<void> saveUserProfile(UserProfileData profileData) async {
    try {
      final profileJson = jsonEncode(profileData.toJson());
      await _storage.write(key: _userProfileKey, value: profileJson);
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  @override
  Future<UserProfileData?> getUserProfile() async {
    try {
      final profileJson = await _storage.read(key: _userProfileKey);
      if (profileJson == null) return null;
      
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserProfileData.fromJson(profileMap);
    } catch (e) {
      throw Exception('Failed to retrieve user profile: $e');
    }
  }

  @override
  Future<void> clearUserProfile() async {
    try {
      await _storage.delete(key: _userProfileKey);
    } catch (e) {
      throw Exception('Failed to clear user profile: $e');
    }
  }

  @override
  Future<bool> hasUserProfile() async {
    try {
      final profileJson = await _storage.read(key: _userProfileKey);
      return profileJson != null && profileJson.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateUserProfile({
    User? user,
    List<String>? userRoles,
    Map<String, bool>? profileComplete,
    bool? onboardingComplete,
    String? appAccess,
    List<String>? availableRoles,
    List<String>? incompleteRoles,
    String? mode,
    String? viewType,
    String? redirectTo,
  }) async {
    try {
      final currentProfile = await getUserProfile();
      if (currentProfile == null) {
        throw Exception('No user profile data to update');
      }

      final updatedProfile = currentProfile.copyWith(
        user: user,
        userRoles: userRoles,
        profileComplete: profileComplete,
        onboardingComplete: onboardingComplete,
        appAccess: appAccess,
        availableRoles: availableRoles,
        incompleteRoles: incompleteRoles,
        mode: mode,
        viewType: viewType,
        redirectTo: redirectTo,
      );

      await saveUserProfile(updatedProfile);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await Future.wait([
        clearToken(),
        clearUserProfile(),
      ]);
    } catch (e) {
      throw Exception('Failed to clear all authentication data: $e');
    }
  }
  
  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      
      // Check if token is expired
      final isExpired = await isTokenExpired();
      return !isExpired;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> isTokenExpired() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return true;
      }
      
      final expiration = await getTokenExpiration();
      if (expiration == null) {
        // If we can't determine expiration, consider token valid
        // but check if it's been stored for more than 24 hours as fallback
        final metadata = await _getTokenMetadata();
        if (metadata != null && metadata['savedAt'] != null) {
          final savedAt = DateTime.parse(metadata['savedAt']);
          final daysSinceSaved = DateTime.now().difference(savedAt).inDays;
          return daysSinceSaved > 1; // Consider expired after 1 day as fallback
        }
        return false;
      }
      
      return DateTime.now().isAfter(expiration);
    } catch (e) {
      // If we can't determine expiration status, assume expired for security
      return true;
    }
  }
  
  @override
  Future<DateTime?> getTokenExpiration() async {
    try {
      final metadata = await _getTokenMetadata();
      if (metadata != null && metadata['expiresAt'] != null) {
        return DateTime.parse(metadata['expiresAt']);
      }
      
      // Try to extract from token itself
      final token = await getToken();
      if (token != null) {
        return _extractTokenExpiration(token);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Get token metadata from storage
  Future<Map<String, dynamic>?> _getTokenMetadata() async {
    try {
      final metadataJson = await _storage.read(key: _tokenMetadataKey);
      if (metadataJson != null) {
        return jsonDecode(metadataJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Extract expiration from JWT token
  /// This is a basic implementation that tries to decode JWT payload
  DateTime? _extractTokenExpiration(String token) {
    try {
      // Basic JWT token format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      
      // Decode payload (base64)
      final payload = parts[1];
      // Add padding if needed
      final normalizedPayload = payload.padRight(
        (payload.length + 3) ~/ 4 * 4,
        '=',
      );
      
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedPayload = utf8.decode(decodedBytes);
      final payloadMap = jsonDecode(decodedPayload) as Map<String, dynamic>;
      
      // Check for 'exp' claim (expiration time in seconds since epoch)
      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      
      return null;
    } catch (e) {
      // If we can't decode the token, return null
      return null;
    }
  }
}