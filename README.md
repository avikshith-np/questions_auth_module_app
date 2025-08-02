# QuestionAuth

A comprehensive Flutter authentication package that provides a modular authentication solution for Flutter applications. This package handles user registration, login, profile management, and logout functionality through a REST API, making it easy to integrate secure authentication into your Flutter projects.

## Features

- ✅ **User Registration**: Complete signup flow with client-side validation
- ✅ **User Authentication**: Secure login with automatic token management
- ✅ **Profile Management**: Retrieve and manage user profiles
- ✅ **Secure Token Storage**: Automatic token storage using `flutter_secure_storage`
- ✅ **Reactive State Management**: Real-time authentication state updates via streams
- ✅ **Comprehensive Error Handling**: Structured error responses with field-level validation
- ✅ **Network Resilience**: Built-in timeout handling and retry mechanisms
- ✅ **Testing Support**: Complete mock implementations and test utilities
- ✅ **Persistence**: Automatic authentication state restoration on app restart
- ✅ **Type Safety**: Full Dart type safety with comprehensive documentation

## Installation

### 1. Add to pubspec.yaml

Add `question_auth` to your Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  question_auth:
    path: ../question_auth  # For local development
    # git:
    #   url: https://github.com/your-org/question_auth.git
    #   ref: main
  flutter:
    sdk: flutter
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Platform Setup

#### Android
No additional setup required.

#### iOS
No additional setup required.

## Quick Start

### 1. Configure the Package

In your app's `main.dart`, configure QuestionAuth with your API endpoint:

```dart
import 'package:flutter/material.dart';
import 'package:question_auth/question_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure QuestionAuth with your API endpoint
  QuestionAuth.instance.configure(
    baseUrl: 'https://your-api.com/api/v1/',
  );
  
  // Initialize authentication state
  await QuestionAuth.instance.initialize();
  
  runApp(MyApp());
}
```

### 2. Set Up Authentication State Management

Create an `AuthWrapper` to handle authentication state changes:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: QuestionAuth.instance.authStateStream,
      builder: (context, snapshot) {
        final authState = snapshot.data ?? const AuthState.unknown();
        
        switch (authState.status) {
          case AuthStatus.authenticated:
            return HomeScreen(user: authState.user!);
          case AuthStatus.unauthenticated:
            return LoginScreen();
          case AuthStatus.unknown:
          default:
            return const SplashScreen();
        }
      },
    );
  }
}
```

## Usage Examples

### User Registration with New API

```dart
import 'package:question_auth/question_auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, List<String>>? _fieldErrors;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _fieldErrors = null;
    });

    try {
      final result = await QuestionAuth.instance.signUp(
        SignUpRequest(
          email: _emailController.text.trim(),
          displayName: _displayNameController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );

      if (result.success) {
        // Registration successful
        print('Registration successful!');
        
        // Access signup response data
        if (result.signUpData != null) {
          final signUpResponse = result.signUpData!;
          print('Message: ${signUpResponse.detail}');
          
          if (signUpResponse.data != null) {
            print('Verification email sent to: ${signUpResponse.data!.email}');
            print('Token expires in: ${signUpResponse.data!.verificationTokenExpiresIn}');
          }
        }
        
        // Show success message and navigate to verification screen
        _showSuccessDialog();
      } else {
        setState(() {
          _errorMessage = result.error;
          _fieldErrors = result.fieldErrors;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: const Text('Please check your email to verify your account.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _fieldErrors?['email']?.first,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                errorText: _fieldErrors?['display_name']?.first,
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _fieldErrors?['password']?.first,
              ),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: _fieldErrors?['confirm_password']?.first,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### User Login with Rich Profile Data

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await QuestionAuth.instance.login(
        LoginRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (result.success) {
        print('Welcome back, ${result.user?.displayName}!');
        
        // Access rich login data
        if (result.loginData != null) {
          final loginData = result.loginData!;
          print('User roles: ${loginData.roles}');
          print('Profile completion: ${loginData.profileComplete}');
          print('Onboarding complete: ${loginData.onboardingComplete}');
          print('App access: ${loginData.appAccess}');
          print('Redirect to: ${loginData.redirectTo}');
          
          // Handle specific scenarios
          if (!loginData.onboardingComplete) {
            _navigateToOnboarding(loginData.redirectTo);
          } else if (loginData.incompleteRoles.isNotEmpty) {
            _showProfileCompletionPrompt(loginData.incompleteRoles);
          }
        }
        
        // Navigation handled by AuthWrapper
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Login failed';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToOnboarding(String redirectTo) {
    // Navigate to onboarding flow
    print('Navigating to onboarding: $redirectTo');
  }

  void _showProfileCompletionPrompt(List<String> incompleteRoles) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Your Profile'),
        content: Text('Please complete your profile for: ${incompleteRoles.join(', ')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to profile completion
            },
            child: const Text('Complete Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Enhanced Profile Management with User Profile Data

```dart
class ProfileScreen extends StatefulWidget {
  final User user;
  
  const ProfileScreen({Key? key, required this.user}) : super(key: key);
  
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileResponse? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProfile = await QuestionAuth.instance.getCurrentUser();
      setState(() {
        _userProfile = userProfile;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.message}';
      });
    } on NetworkException catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await QuestionAuth.instance.logout();
    // Navigation handled by AuthWrapper
  }

  Widget _buildProfileSection(String title, Widget content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadUserProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic User Information
                      _buildProfileSection(
                        'Basic Information',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Display Name: ${_userProfile!.user.displayName}'),
                            Text('Email: ${_userProfile!.user.email}'),
                            Text('Email Verified: ${_userProfile!.user.emailVerified ? 'Yes' : 'No'}'),
                            Text('Account Active: ${_userProfile!.user.isActive ? 'Yes' : 'No'}'),
                            if (_userProfile!.user.dateJoined != null)
                              Text('Member since: ${_userProfile!.user.dateJoined!.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                      ),

                      // User Status
                      _buildProfileSection(
                        'Account Status',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('New User: ${_userProfile!.isNew ? 'Yes' : 'No'}'),
                            Text('Current Mode: ${_userProfile!.mode}'),
                            Text('App Access: ${_userProfile!.appAccess}'),
                            Text('View Type: ${_userProfile!.viewType}'),
                            Text('Onboarding Complete: ${_userProfile!.onboardingComplete ? 'Yes' : 'No'}'),
                          ],
                        ),
                      ),

                      // User Roles
                      _buildProfileSection(
                        'Roles & Permissions',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Roles: ${_userProfile!.roles.join(', ')}'),
                            Text('Available Roles: ${_userProfile!.availableRoles.join(', ')}'),
                            Text('Removable Roles: ${_userProfile!.removableRoles.join(', ')}'),
                            if (_userProfile!.incompleteRoles.isNotEmpty)
                              Text(
                                'Incomplete Roles: ${_userProfile!.incompleteRoles.join(', ')}',
                                style: const TextStyle(color: Colors.orange),
                              ),
                          ],
                        ),
                      ),

                      // Profile Completion Status
                      _buildProfileSection(
                        'Profile Completion',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _userProfile!.profileComplete.entries.map((entry) {
                            return Row(
                              children: [
                                Icon(
                                  entry.value ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: entry.value ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text('${entry.key}: ${entry.value ? 'Complete' : 'Incomplete'}'),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                      // Quick Actions
                      _buildProfileSection(
                        'Quick Actions',
                        Column(
                          children: [
                            if (!_userProfile!.onboardingComplete)
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to onboarding
                                  print('Navigate to: ${_userProfile!.redirectTo}');
                                },
                                child: const Text('Complete Onboarding'),
                              ),
                            if (_userProfile!.incompleteRoles.isNotEmpty)
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to profile completion
                                  print('Complete roles: ${_userProfile!.incompleteRoles}');
                                },
                                child: const Text('Complete Profile'),
                              ),
                            ElevatedButton(
                              onPressed: _loadUserProfile,
                              child: const Text('Refresh Profile'),
                            ),
                          ],
                        ),
                      ),

                      // Quick Access to Profile Data
                      _buildProfileSection(
                        'Quick Access (from QuestionAuth)',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User Roles: ${QuestionAuth.instance.userRoles}'),
                            Text('Profile Complete: ${QuestionAuth.instance.profileComplete}'),
                            Text('Onboarding Complete: ${QuestionAuth.instance.onboardingComplete}'),
                            Text('App Access: ${QuestionAuth.instance.appAccess}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
```

### User Profile Data Access

The package provides easy access to rich user profile data through multiple approaches:

#### Direct Access from QuestionAuth Instance

```dart
class UserProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Quick access to user profile information
    if (!QuestionAuth.instance.isAuthenticated) {
      return const Text('Not authenticated');
    }

    final user = QuestionAuth.instance.currentUser;
    final roles = QuestionAuth.instance.userRoles;
    final profileComplete = QuestionAuth.instance.profileComplete;
    final onboardingComplete = QuestionAuth.instance.onboardingComplete;
    final appAccess = QuestionAuth.instance.appAccess;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, ${user?.displayName ?? 'User'}!'),
        
        // Show role-specific content
        if (roles?.contains('creator') == true)
          const CreatorDashboard(),
        if (roles?.contains('student') == true)
          const StudentDashboard(),
        
        // Show profile completion status
        if (profileComplete != null)
          ...profileComplete.entries.map((entry) => 
            Text('${entry.key}: ${entry.value ? 'Complete' : 'Incomplete'}')),
        
        // Show onboarding status
        if (onboardingComplete == false)
          const OnboardingPrompt(),
        
        // Show app access level
        Text('Access Level: $appAccess'),
      ],
    );
  }
}

class CreatorDashboard extends StatelessWidget {
  const CreatorDashboard({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Creator Dashboard'),
            ElevatedButton(
              onPressed: () => print('Create content'),
              child: const Text('Create Content'),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Student Dashboard'),
            ElevatedButton(
              onPressed: () => print('View courses'),
              child: const Text('View Courses'),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPrompt extends StatelessWidget {
  const OnboardingPrompt({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Complete your onboarding to access all features'),
            ElevatedButton(
              onPressed: () => print('Start onboarding'),
              child: const Text('Complete Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Detailed Profile Data Access

```dart
class DetailedProfileScreen extends StatefulWidget {
  @override
  _DetailedProfileScreenState createState() => _DetailedProfileScreenState();
}

class _DetailedProfileScreenState extends State<DetailedProfileScreen> {
  UserProfileResponse? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await QuestionAuth.instance.getCurrentUser();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profile == null) {
      return const Center(child: Text('Failed to load profile'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information
          _buildSection('User Information', [
            'Display Name: ${_profile!.user.displayName}',
            'Email: ${_profile!.user.email}',
            'Email Verified: ${_profile!.user.emailVerified}',
            'Account Active: ${_profile!.user.isActive}',
            'New User: ${_profile!.isNew}',
          ]),

          // Role Information
          _buildSection('Roles & Permissions', [
            'Current Roles: ${_profile!.roles.join(', ')}',
            'Available Roles: ${_profile!.availableRoles.join(', ')}',
            'Removable Roles: ${_profile!.removableRoles.join(', ')}',
            'Incomplete Roles: ${_profile!.incompleteRoles.join(', ')}',
          ]),

          // Profile Status
          _buildSection('Profile Status', [
            'Current Mode: ${_profile!.mode}',
            'App Access: ${_profile!.appAccess}',
            'View Type: ${_profile!.viewType}',
            'Onboarding Complete: ${_profile!.onboardingComplete}',
            'Redirect To: ${_profile!.redirectTo}',
          ]),

          // Profile Completion
          _buildSection('Profile Completion', 
            _profile!.profileComplete.entries.map((entry) => 
              '${entry.key}: ${entry.value ? 'Complete' : 'Incomplete'}'
            ).toList()
          ),

          // Actions based on profile data
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(item),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final List<Widget> buttons = [];

    // Add buttons based on profile status
    if (!_profile!.onboardingComplete) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _navigateToOnboarding(),
          child: const Text('Complete Onboarding'),
        ),
      );
    }

    if (_profile!.incompleteRoles.isNotEmpty) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _completeProfile(),
          child: Text('Complete ${_profile!.incompleteRoles.join(', ')} Profile'),
        ),
      );
    }

    if (_profile!.availableRoles.isNotEmpty) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _addRole(),
          child: Text('Add Role: ${_profile!.availableRoles.join(', ')}'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons.map((button) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: button,
      )).toList(),
    );
  }

  void _navigateToOnboarding() {
    print('Navigate to onboarding: ${_profile!.redirectTo}');
    // Implement navigation logic
  }

  void _completeProfile() {
    print('Complete profile for roles: ${_profile!.incompleteRoles}');
    // Implement profile completion logic
  }

  void _addRole() {
    print('Add roles: ${_profile!.availableRoles}');
    // Implement role addition logic
  }
}
```

### Authentication State Monitoring with Profile Data

```dart
class AuthStateMonitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: QuestionAuth.instance.authStateStream,
      builder: (context, snapshot) {
        final authState = snapshot.data ?? const AuthState.unknown();
        
        return Container(
          padding: const EdgeInsets.all(8.0),
          color: _getStatusColor(authState.status),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getStatusIcon(authState.status)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Status: ${authState.status.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (authState.user != null)
                          Text('User: ${authState.user!.displayName}'),
                        if (authState.error != null)
                          Text(
                            'Error: ${authState.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Show profile data when authenticated
              if (authState.status == AuthStatus.authenticated && 
                  authState.userProfileData != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      Text(
                        'Profile Data:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Roles: ${authState.userProfileData!.roles.join(', ')}'),
                      Text('App Access: ${authState.userProfileData!.appAccess}'),
                      Text('Onboarding: ${authState.userProfileData!.onboardingComplete ? 'Complete' : 'Incomplete'}'),
                      
                      // Show profile completion status
                      if (authState.userProfileData!.profileComplete.isNotEmpty)
                        Text('Profile Complete: ${authState.userProfileData!.profileComplete}'),
                      
                      // Show incomplete roles if any
                      if (authState.userProfileData!.incompleteRoles.isNotEmpty)
                        Text(
                          'Incomplete: ${authState.userProfileData!.incompleteRoles.join(', ')}',
                          style: const TextStyle(color: Colors.orange),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        return Colors.green.shade100;
      case AuthStatus.unauthenticated:
        return Colors.red.shade100;
      case AuthStatus.unknown:
        return Colors.grey.shade100;
    }
  }

  IconData _getStatusIcon(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        return Icons.check_circle;
      case AuthStatus.unauthenticated:
        return Icons.error;
      case AuthStatus.unknown:
        return Icons.help;
    }
  }
}
```

## Advanced Configuration

### Custom Configuration Options

```dart
QuestionAuth.instance.configure(
  baseUrl: 'https://your-api.com/api/v1/',
  apiVersion: 'v2',                    // Default: 'v1'
  timeout: const Duration(seconds: 45), // Default: 30 seconds
  enableLogging: true,                 // Default: false
  defaultHeaders: {
    'X-Client-Version': '1.0.0',
    'Accept': 'application/json',
    'X-Platform': 'flutter',
  },
);
```

### Dependency Injection (Advanced Usage)

For advanced use cases, you can use the service interfaces directly:

```dart
import 'package:question_auth/question_auth.dart';

class MyAuthService {
  final AuthService _authService;
  
  MyAuthService(this._authService);
  
  Future<bool> quickLogin(String email, String password) async {
    final result = await _authService.login(
      LoginRequest(email: email, password: password),
    );
    return result.success;
  }
}

// Usage with dependency injection
final tokenManager = SecureTokenManager();
final apiClient = HttpApiClient(baseUrl: 'https://api.example.com');
final repository = AuthRepositoryImpl(
  apiClient: apiClient,
  tokenManager: tokenManager,
);
final authService = AuthServiceImpl(repository: repository);

final myAuthService = MyAuthService(authService);
```

## Error Handling

The package provides comprehensive error handling with specific exception types:

```dart
try {
  final result = await QuestionAuth.instance.login(loginRequest);
  if (result.success) {
    // Handle success
    print('Login successful: ${result.user?.username}');
  } else {
    // Handle authentication failure
    print('Login failed: ${result.error}');
    
    // Handle field-specific errors
    result.fieldErrors?.forEach((field, errors) {
      print('$field: ${errors.join(', ')}');
    });
  }
} on ValidationException catch (e) {
  // Client-side validation errors
  print('Validation error: ${e.message}');
  e.fieldErrors.forEach((field, errors) {
    print('$field: ${errors.join(', ')}');
  });
} on ApiException catch (e) {
  // Server-side API errors
  print('API error (${e.statusCode}): ${e.message}');
} on NetworkException catch (e) {
  // Network connectivity issues
  print('Network error: ${e.message}');
} on TokenException catch (e) {
  // Token-related errors
  print('Token error: ${e.message}');
} catch (e) {
  // Unexpected errors
  print('Unexpected error: $e');
}
```

### Exception Types

- **`ValidationException`**: Client-side validation errors with field details
- **`ApiException`**: Server-side errors with HTTP status codes
- **`NetworkException`**: Network connectivity issues
- **`TokenException`**: Token-related errors (expired, invalid, etc.)
- **`AuthException`**: Base authentication exception

## Testing

The package includes comprehensive testing utilities for easy testing in your app:

### Basic Testing Setup

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:question_auth/question_auth.dart';

void main() {
  group('Authentication Tests', () {
    setUp(() {
      QuestionAuth.reset(); // Reset singleton for testing
    });

    test('should handle login success', () async {
      // Configure QuestionAuth for testing
      QuestionAuth.instance.configure(
        baseUrl: 'https://test-api.com/api/v1/',
      );

      // Test your authentication logic
      final loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(loginRequest.isValid, isTrue);
    });
  });
}
```

### Widget Testing

```dart
testWidgets('should show login screen when unauthenticated', (tester) async {
  QuestionAuth.reset();
  QuestionAuth.instance.configure(baseUrl: 'https://test-api.com/api/v1/');

  await tester.pumpWidget(
    MaterialApp(
      home: AuthWrapper(),
    ),
  );

  // Test your authentication UI
  expect(find.byType(LoginScreen), findsOneWidget);
});
```

### Mock Testing

```dart
import 'package:question_auth/question_auth.dart';

// Create mock implementations for testing
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('Mock Authentication Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    test('should handle mock login', () async {
      // Setup mock behavior
      when(mockAuthService.login(any))
          .thenAnswer((_) async => AuthResult.success(
            user: User(
              id: '1',
              email: 'test@example.com',
              username: 'testuser',
            ),
          ));

      // Test with mock
      final result = await mockAuthService.login(
        LoginRequest(email: 'test@example.com', password: 'password'),
      );

      expect(result.success, isTrue);
      expect(result.user?.username, equals('testuser'));
    });
  });
}
```

## API Reference

### Core Classes

#### QuestionAuth
Main singleton entry point for the authentication package.

```dart
// Configuration
QuestionAuth.instance.configure(baseUrl: 'https://api.example.com');
await QuestionAuth.instance.initialize();

// Authentication methods
Future<AuthResult> signUp(SignUpRequest request);
Future<AuthResult> login(LoginRequest request);
Future<User> getCurrentUser();
Future<void> logout();

// State access
Stream<AuthState> get authStateStream;
bool get isAuthenticated;
User? get currentUser;
AuthState get currentAuthState;
```

#### AuthState
Represents the current authentication state.

```dart
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
}
```

#### User
User model representing authenticated user data.

```dart
class User {
  final String id;
  final String email;
  final String username;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### Request Models

#### SignUpRequest
```dart
class SignUpRequest {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  
  // Validation
  bool get isValid;
  List<String> validate();
  Map<String, List<String>> validateFields();
}
```

#### LoginRequest
```dart
class LoginRequest {
  final String email;
  final String password;
  
  // Validation
  bool get isValid;
  List<String> validate();
  Map<String, List<String>> validateFields();
}
```

### Response Models

#### AuthResult
```dart
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
}
```

## API Requirements

Your backend API should implement the following endpoints:

### POST /accounts/signup/
```json
// Request
{
  "email": "user@example.com",
  "username": "username",
  "password": "password123",
  "confirm_password": "password123"
}

// Success Response (201)
{
  "success": true,
  "message": "User created successfully",
  "token": "jwt_token_here",
  "user": {
    "id": "1",
    "email": "user@example.com",
    "username": "username",
    "created_at": "2023-01-01T00:00:00Z",
    "updated_at": "2023-01-01T00:00:00Z"
  }
}

// Error Response (400)
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Email already exists"],
    "username": ["Username is required"]
  }
}
```

### POST /accounts/login/
```json
// Request
{
  "email": "user@example.com",
  "password": "password123"
}

// Success Response (200)
{
  "success": true,
  "message": "Login successful",
  "token": "jwt_token_here",
  "user": {
    "id": "1",
    "email": "user@example.com",
    "username": "username",
    "created_at": "2023-01-01T00:00:00Z",
    "updated_at": "2023-01-01T00:00:00Z"
  }
}
```

### GET /accounts/me/
```json
// Headers: Authorization: Bearer jwt_token_here

// Success Response (200)
{
  "id": "1",
  "email": "user@example.com",
  "username": "username",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z"
}
```

### POST /logout/
```json
// Headers: Authorization: Bearer jwt_token_here

// Success Response (200)
{
  "success": true,
  "message": "Logout successful"
}
```

## Troubleshooting

### Common Issues

1. **Configuration Error**: Make sure to call `QuestionAuth.instance.configure()` before using any authentication methods.

2. **Network Timeouts**: Adjust the timeout configuration if you're experiencing network issues:
   ```dart
   QuestionAuth.instance.configure(
     baseUrl: 'https://your-api.com/api/v1/',
     timeout: const Duration(seconds: 60),
   );
   ```

3. **Token Persistence Issues**: The package uses `flutter_secure_storage` which requires platform-specific setup for some advanced configurations.

4. **State Not Updating**: Make sure you're listening to `authStateStream` for reactive updates.

### Debug Mode

Enable logging to debug issues:

```dart
QuestionAuth.instance.configure(
  baseUrl: 'https://your-api.com/api/v1/',
  enableLogging: true,
);
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions, issues, or feature requests, please:

1. Check the [documentation](https://pub.dev/packages/question_auth)
2. Search [existing issues](https://github.com/your-org/question_auth/issues)
3. Create a [new issue](https://github.com/your-org/question_auth/issues/new) if needed

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.