import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _pinKey = 'user_pin';
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _encryptionKey = 'encryption_key';
  static const _authAttemptsKey = 'auth_attempts';
  static const _lockoutTimeKey = 'lockout_time';

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Set up PIN
  Future<bool> setPin(String pin) async {
    try {
      final hashedPin = _hashPin(pin);
      await _storage.write(key: _pinKey, value: hashedPin);
      await _storage.write(key: _authAttemptsKey, value: '0');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verify PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final lockoutTime = await _storage.read(key: _lockoutTimeKey);
      if (lockoutTime != null) {
        final lockoutEndTime = DateTime.parse(lockoutTime);
        if (DateTime.now().isBefore(lockoutEndTime)) {
          return false; // Still in lockout period
        } else {
          // Reset lockout
          await _storage.delete(key: _lockoutTimeKey);
          await _storage.write(key: _authAttemptsKey, value: '0');
        }
      }

      final storedPin = await _storage.read(key: _pinKey);
      if (storedPin == null) return false;

      final hashedPin = _hashPin(pin);
      if (storedPin == hashedPin) {
        await _storage.write(key: _authAttemptsKey, value: '0');
        return true;
      } else {
        final attempts = int.tryParse(await _storage.read(key: _authAttemptsKey) ?? '0') ?? 0;
        final newAttempts = attempts + 1;
        await _storage.write(key: _authAttemptsKey, value: newAttempts.toString());

        // Lock out after 5 failed attempts for 5 minutes
        if (newAttempts >= 5) {
          final lockoutEndTime = DateTime.now().add(const Duration(minutes: 5));
          await _storage.write(key: _lockoutTimeKey, value: lockoutEndTime.toIso8601String());
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final isBiometricEnabled = await _storage.read(key: _biometricEnabledKey);
      if (isBiometricEnabled != 'true') return false;

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your health data',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Enable biometric authentication
  Future<bool> enableBiometrics() async {
    try {
      final available = await isBiometricAvailable();
      if (!available) return false;

      // First authenticate with current method
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await _storage.write(key: _biometricEnabledKey, value: 'true');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Disable biometric authentication
  Future<bool> disableBiometrics() async {
    try {
      await _storage.write(key: _biometricEnabledKey, value: 'false');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if biometrics is enabled
  Future<bool> isBiometricsEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  // Check if PIN is set
  Future<bool> isPinSet() async {
    try {
      final pin = await _storage.read(key: _pinKey);
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Change PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      if (!await verifyPin(oldPin)) return false;
      return await setPin(newPin);
    } catch (e) {
      return false;
    }
  }

  // Get remaining lockout time
  Future<Duration?> getLockoutTimeRemaining() async {
    try {
      final lockoutTime = await _storage.read(key: _lockoutTimeKey);
      if (lockoutTime == null) return null;

      final lockoutEndTime = DateTime.parse(lockoutTime);
      final remaining = lockoutEndTime.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      return null;
    }
  }

  // Get failed authentication attempts
  Future<int> getFailedAttempts() async {
    try {
      final attempts = await _storage.read(key: _authAttemptsKey);
      return int.tryParse(attempts ?? '0') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Reset authentication attempts (for testing or manual reset)
  Future<bool> resetAuthAttempts() async {
    try {
      await _storage.write(key: _authAttemptsKey, value: '0');
      await _storage.delete(key: _lockoutTimeKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Hash PIN using SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Encrypt data
  Future<String?> encryptData(String data) async {
    try {
      final key = await _getOrCreateEncryptionKey();
      if (key == null) return null;

      // Simple XOR encryption for demonstration
      // In production, use proper AES encryption
      final keyBytes = utf8.encode(key);
      final dataBytes = utf8.encode(data);
      final encrypted = <int>[];

      for (int i = 0; i < dataBytes.length; i++) {
        encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64.encode(encrypted);
    } catch (e) {
      return null;
    }
  }

  // Decrypt data
  Future<String?> decryptData(String encryptedData) async {
    try {
      final key = await _getOrCreateEncryptionKey();
      if (key == null) return null;

      final keyBytes = utf8.encode(key);
      final encrypted = base64.decode(encryptedData);
      final decrypted = <int>[];

      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      return null;
    }
  }

  // Get or create encryption key
  Future<String?> _getOrCreateEncryptionKey() async {
    try {
      String? key = await _storage.read(key: _encryptionKey);
      if (key == null) {
        // Generate a random key
        final random = Uint8List(32);
        for (int i = 0; i < 32; i++) {
          random[i] = (DateTime.now().millisecondsSinceEpoch + i) % 256;
        }
        key = base64.encode(random);
        await _storage.write(key: _encryptionKey, value: key);
      }
      return key;
    } catch (e) {
      return null;
    }
  }

  // Securely store data
  Future<bool> secureWrite(String key, String value) async {
    try {
      final encrypted = await encryptData(value);
      if (encrypted == null) return false;
      await _storage.write(key: key, value: encrypted);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Securely read data
  Future<String?> secureRead(String key) async {
    try {
      final encrypted = await _storage.read(key: key);
      if (encrypted == null) return null;
      return await decryptData(encrypted);
    } catch (e) {
      return null;
    }
  }

  // Securely delete data
  Future<bool> secureDelete(String key) async {
    try {
      await _storage.delete(key: key);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear all secure data (for logout/reset)
  Future<bool> clearAllData() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }
}
