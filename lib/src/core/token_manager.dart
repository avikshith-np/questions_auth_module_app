import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract interface for managing authentication tokens
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
}

/// Implementation of TokenManager using flutter_secure_storage
class SecureTokenManager implements TokenManager {
  static const String _tokenKey = 'auth_token';
  
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
    } catch (e) {
      throw Exception('Failed to clear token: $e');
    }
  }
  
  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}