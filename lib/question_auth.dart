/// A Flutter authentication package that provides modular authentication
/// solution for Flutter applications.
/// 
/// This package handles user registration, login, profile management, and
/// logout functionality through a REST API, allowing it to be easily
/// integrated into multiple Flutter projects.

// Core exports
export 'src/core/auth_state.dart';
export 'src/core/exceptions.dart';
export 'src/core/token_manager.dart';

// Model exports
export 'src/models/user.dart';
export 'src/models/auth_request.dart';
export 'src/models/auth_response.dart';
export 'src/models/auth_result.dart';

// Service exports
export 'src/services/auth_service.dart';
export 'src/services/question_auth.dart';

// Repository exports (interfaces only)
export 'src/repositories/auth_repository.dart';