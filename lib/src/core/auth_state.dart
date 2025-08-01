import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/auth_response.dart';

/// Authentication status enumeration
enum AuthStatus {
  /// Authentication status is unknown (initial state)
  unknown,
  
  /// User is authenticated
  authenticated,
  
  /// User is not authenticated
  unauthenticated,
}

/// Represents the current authentication state
class AuthState {
  /// The current authentication status
  final AuthStatus status;
  
  /// The authenticated user (null if not authenticated)
  final User? user;
  
  /// Error message if authentication failed
  final String? error;
  
  /// User roles (null if not authenticated or not available)
  final List<String>? userRoles;
  
  /// Profile completion status for different roles (null if not authenticated)
  final Map<String, bool>? profileComplete;
  
  /// Whether onboarding is complete (null if not authenticated)
  final bool? onboardingComplete;
  
  /// App access level (null if not authenticated)
  final String? appAccess;
  
  /// Available roles for the user (null if not authenticated)
  final List<String>? availableRoles;
  
  /// Incomplete roles for the user (null if not authenticated)
  final List<String>? incompleteRoles;
  
  /// User mode (null if not authenticated)
  final String? mode;
  
  /// View type for the user (null if not authenticated)
  final String? viewType;
  
  /// Redirect URL for navigation (null if not authenticated)
  final String? redirectTo;

  const AuthState({
    required this.status,
    this.user,
    this.error,
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

  /// Creates an unknown authentication state
  const AuthState.unknown() : this(status: AuthStatus.unknown);

  /// Creates an authenticated state with user and optional profile data
  const AuthState.authenticated(
    User user, {
    List<String>? userRoles,
    Map<String, bool>? profileComplete,
    bool? onboardingComplete,
    String? appAccess,
    List<String>? availableRoles,
    List<String>? incompleteRoles,
    String? mode,
    String? viewType,
    String? redirectTo,
  }) : this(
    status: AuthStatus.authenticated,
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

  /// Creates an authenticated state from LoginResponse
  AuthState.fromLoginResponse(LoginResponse loginResponse) : this(
    status: AuthStatus.authenticated,
    user: loginResponse.user,
    userRoles: loginResponse.roles,
    profileComplete: loginResponse.profileComplete,
    onboardingComplete: loginResponse.onboardingComplete,
    appAccess: loginResponse.appAccess,
    incompleteRoles: loginResponse.incompleteRoles,
    redirectTo: loginResponse.redirectTo,
  );

  /// Creates an authenticated state from UserProfileResponse
  AuthState.fromUserProfileResponse(UserProfileResponse profileResponse) : this(
    status: AuthStatus.authenticated,
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

  /// Creates an unauthenticated state with optional error
  const AuthState.unauthenticated([String? error]) : this(
    status: AuthStatus.unauthenticated,
    error: error,
  );

  /// Creates a copy of this AuthState with updated fields
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    List<String>? userRoles,
    Map<String, bool>? profileComplete,
    bool? onboardingComplete,
    String? appAccess,
    List<String>? availableRoles,
    List<String>? incompleteRoles,
    String? mode,
    String? viewType,
    String? redirectTo,
    bool clearError = false,
    bool clearProfileData = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      userRoles: clearProfileData ? null : (userRoles ?? this.userRoles),
      profileComplete: clearProfileData ? null : (profileComplete ?? this.profileComplete),
      onboardingComplete: clearProfileData ? null : (onboardingComplete ?? this.onboardingComplete),
      appAccess: clearProfileData ? null : (appAccess ?? this.appAccess),
      availableRoles: clearProfileData ? null : (availableRoles ?? this.availableRoles),
      incompleteRoles: clearProfileData ? null : (incompleteRoles ?? this.incompleteRoles),
      mode: clearProfileData ? null : (mode ?? this.mode),
      viewType: clearProfileData ? null : (viewType ?? this.viewType),
      redirectTo: clearProfileData ? null : (redirectTo ?? this.redirectTo),
    );
  }

  /// Whether the user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Whether the user is unauthenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Whether the authentication status is unknown
  bool get isUnknown => status == AuthStatus.unknown;

  /// Whether the user has a specific role
  bool hasRole(String role) {
    return userRoles?.contains(role) ?? false;
  }

  /// Whether the profile is complete for a specific role
  bool isProfileCompleteForRole(String role) {
    return profileComplete?[role] ?? false;
  }

  /// Whether the user has full app access
  bool get hasFullAppAccess => appAccess == 'full';

  /// Whether the user has any incomplete roles
  bool get hasIncompleteRoles => incompleteRoles?.isNotEmpty ?? false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.error == error &&
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
  int get hashCode => Object.hash(
    status,
    user,
    error,
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

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, error: $error, userRoles: $userRoles, profileComplete: $profileComplete, onboardingComplete: $onboardingComplete, appAccess: $appAccess, availableRoles: $availableRoles, incompleteRoles: $incompleteRoles, mode: $mode, viewType: $viewType, redirectTo: $redirectTo)';
  }
}

/// Notifier for authentication state changes
class AuthStateNotifier extends ValueNotifier<AuthState> {
  late final StreamController<AuthState> _streamController;
  
  /// Creates an AuthStateNotifier with unknown initial state
  AuthStateNotifier() : super(const AuthState.unknown()) {
    _streamController = StreamController<AuthState>.broadcast();
    // Add initial state to stream
    _streamController.add(value);
    // Listen to value changes and add to stream
    addListener(() {
      _streamController.add(value);
    });
  }
  
  /// Stream of authentication state changes
  Stream<AuthState> get stream => _streamController.stream;

  /// Sets the authentication state to authenticated with user
  void setAuthenticated(User user) {
    value = AuthState.authenticated(user);
  }

  /// Sets the authentication state to authenticated with user and profile data
  void setAuthenticatedWithProfile(
    User user, {
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
    value = AuthState.authenticated(
      user,
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
  }

  /// Sets the authentication state from LoginResponse
  void setAuthenticatedFromLoginResponse(LoginResponse loginResponse) {
    value = AuthState.fromLoginResponse(loginResponse);
  }

  /// Sets the authentication state from UserProfileResponse
  void setAuthenticatedFromUserProfileResponse(UserProfileResponse profileResponse) {
    value = AuthState.fromUserProfileResponse(profileResponse);
  }

  /// Updates the current authenticated state with new profile data
  void updateProfileData({
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
    if (value.isAuthenticated) {
      value = value.copyWith(
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
    }
  }

  /// Sets the authentication state to unauthenticated with optional error
  void setUnauthenticated([String? error]) {
    value = AuthState.unauthenticated(error);
  }

  /// Sets the authentication state to unknown
  void setUnknown() {
    value = const AuthState.unknown();
  }

  /// Clears any error in the current state
  void clearError() {
    if (value.error != null) {
      value = value.copyWith(clearError: true);
    }
  }

  /// Clears profile data from the current state
  void clearProfileData() {
    value = value.copyWith(clearProfileData: true);
  }

  /// Whether the user is currently authenticated
  bool get isAuthenticated => value.isAuthenticated;

  /// Whether the user is currently unauthenticated
  bool get isUnauthenticated => value.isUnauthenticated;

  /// Whether the authentication status is unknown
  bool get isUnknown => value.isUnknown;

  /// The current authenticated user (null if not authenticated)
  User? get currentUser => value.user;

  /// The current error message (null if no error)
  String? get currentError => value.error;

  /// The current user roles (null if not authenticated)
  List<String>? get currentUserRoles => value.userRoles;

  /// The current profile completion status (null if not authenticated)
  Map<String, bool>? get currentProfileComplete => value.profileComplete;

  /// Whether onboarding is complete (null if not authenticated)
  bool? get currentOnboardingComplete => value.onboardingComplete;

  /// The current app access level (null if not authenticated)
  String? get currentAppAccess => value.appAccess;

  /// The current available roles (null if not authenticated)
  List<String>? get currentAvailableRoles => value.availableRoles;

  /// The current incomplete roles (null if not authenticated)
  List<String>? get currentIncompleteRoles => value.incompleteRoles;

  /// The current user mode (null if not authenticated)
  String? get currentMode => value.mode;

  /// The current view type (null if not authenticated)
  String? get currentViewType => value.viewType;

  /// The current redirect URL (null if not authenticated)
  String? get currentRedirectTo => value.redirectTo;
  
  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}