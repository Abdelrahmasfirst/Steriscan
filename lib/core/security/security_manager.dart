import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityManager {
  static late Encrypter _encrypter;
  static late IV _iv;
  static const String _keyStorageKey = 'app_encryption_key';
  static const String _keyIVStorage = 'app_iv_key';
  static const String _saltKey = 'app_salt';
  
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Génération ou récupération de la clé
      String? storedKey = prefs.getString(_keyStorageKey);
      if (storedKey == null) {
        storedKey = _generateSecureKey();
        await prefs.setString(_keyStorageKey, storedKey);
      }
      
      // Génération ou récupération de l'IV
      String? storedIV = prefs.getString(_keyIVStorage);
      if (storedIV == null) {
        _iv = IV.fromSecureRandom(16);
        await prefs.setString(_keyIVStorage, _iv.base64);
      } else {
        _iv = IV.fromBase64(storedIV);
      }
      
      final key = Key.fromBase64(storedKey);
      _encrypter = Encrypter(AES(key));
      
    } catch (e) {
      debugPrint('Erreur initialisation sécurité: $e');
      rethrow;
    }
  }
  
  static String _generateSecureKey() {
    final secureRandom = List<int>.generate(32, (i) => 
      DateTime.now().millisecondsSinceEpoch.hashCode + i);
    return base64Encode(secureRandom);
  }
  
  static String encryptData(String data) {
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      debugPrint('Erreur chiffrement: $e');
      throw SecurityException('Erreur lors du chiffrement des données');
    }
  }
  
  static String decryptData(String encryptedData) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      debugPrint('Erreur déchiffrement: $e');
      throw SecurityException('Erreur lors du déchiffrement des données');
    }
  }
  
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static String generateSalt() {
    final bytes = List<int>.generate(16, (i) => 
      DateTime.now().millisecondsSinceEpoch.hashCode + i);
    return base64Encode(bytes);
  }
  
  static bool validateInput(String input) {
    // Validation contre injection SQL et XSS
    if (input.isEmpty || input.length > 1000) {
      return false;
    }
    
    final dangerousPatterns = [
      r"<script",
      r"javascript:",
      r"SELECT.*FROM",
      r"INSERT.*INTO",
      r"UPDATE.*SET",
      r"DELETE.*FROM",
      r"DROP.*TABLE",
      r"UNION.*SELECT",
      r"--",
      r"/*",
      r"*/",
      r"xp_",
      r"sp_",
    ];
    
    final inputLower = input.toLowerCase();
    for (final pattern in dangerousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(inputLower)) {
        return false;
      }
    }
    return true;
  }
  
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>"\']'), '')
        .replaceAll(RegExp(r'(javascript:|data:)', caseSensitive: false), '')
        .replaceAll(RegExp(r'(--|\*|;)'), '')
        .trim();
  }
  
  static bool validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email);
  }
  
  static bool validatePhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone);
  }
  
  static String generateSecureToken() {
    final bytes = List<int>.generate(32, (i) => 
      DateTime.now().millisecondsSinceEpoch.hashCode + i);
    return base64Encode(bytes);
  }
  
  static Future<bool> validateIntegrity(String data, String hash) async {
    try {
      final computedHash = sha256.convert(utf8.encode(data)).toString();
      return computedHash == hash;
    } catch (e) {
      debugPrint('Erreur validation intégrité: $e');
      return false;
    }
  }
  
  static String computeHash(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }
  
  static Future<void> secureDelete(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      debugPrint('Erreur suppression sécurisée: $e');
    }
  }
  
  static Future<void> clearSecurityData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStorageKey);
      await prefs.remove(_keyIVStorage);
      await prefs.remove(_saltKey);
    } catch (e) {
      debugPrint('Erreur nettoyage données sécurité: $e');
    }
  }
}

class SecurityException implements Exception {
  final String message;
  
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}