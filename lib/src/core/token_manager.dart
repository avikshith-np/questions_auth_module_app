import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

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
  
  /// Check if the stored token is expired
  /// Returns true if token is expired or invalid, false if valid
  Future<bool> isTokenExpired();
  
  /// Get token expiration timestamp
  /// Returns null if no token or token doesn't have expiration info
  Future<DateTime?> getTokenExpiration();
}

/// Implementation of TokenManager using flutter_secure_storage
class SecureTokenManager implements TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _tokenMetadataKey = 'auth_token_metadata';
  
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