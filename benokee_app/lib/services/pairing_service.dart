import 'dart:math';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class PairingService {
  static final PairingService _instance = PairingService._internal();
  factory PairingService() => _instance;
  PairingService._internal();

  final StorageService _storage = StorageService();
  final Random _random = Random();

  /// Generate a 6-digit pairing code
  String generateCode() {
    return (100000 + _random.nextInt(900000)).toString();
  }

  /// Generate and store pairing code for a contact
  Future<String> generatePairingCode(String contactEmail) async {
    final code = generateCode();
    await _storage.setPairingCode(contactEmail, code);
    debugPrint('Generated pairing code $code for $contactEmail');
    return code;
  }

  /// Validate pairing code (for contact onboarding)
  /// This checks if the code exists in any user's contact list
  /// In a real implementation, this would be done via Firebase Functions
  Future<bool> validateCode(String code, String contactEmail) async {
    // For now, we'll use a simple approach:
    // Store the code in the contact's storage and mark as validated
    // The actual linking will happen when the user's app checks for valid codes
    // This is a simplified version - in production, use Firebase Functions
    
    // Store the code for later validation
    await _storage.setPairingCode(contactEmail, code);
    
    // For now, accept any 6-digit code (in production, validate against user's contacts)
    // TODO: Implement proper validation via Firebase Functions
    if (code.length == 6 && code.contains(RegExp(r'^[0-9]+$'))) {
      return true;
    }
    return false;
  }

  /// Link contact to user (called from user's app when contact validates code)
  Future<bool> linkContactToUser(String contactEmail, String userEmail, String userName, String userFcmToken) async {
    // This would normally be done via Firebase Functions
    // For now, we'll store it locally
    await _storage.addLinkedUser(userEmail, userName, userFcmToken);
    return true;
  }

  /// Get pairing code for a contact
  Future<String?> getPairingCode(String contactEmail) async {
    return await _storage.getPairingCode(contactEmail);
  }

  /// Clear pairing code after successful pairing
  Future<void> clearPairingCode(String contactEmail) async {
    await _storage.removePairingCode(contactEmail);
  }
}
