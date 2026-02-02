import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyIsOnboarded = 'is_onboarded';
  static const String _keyEmergencyNumber = 'emergency_number';
  static const String _keyUserName = 'user_name';
  static const String _keyCheckTime = 'check_time';
  static const String _keyCheckInterval = 'check_interval';
  static const String _keyReminderInterval = 'reminder_interval';
  static const String _keyNotificationText = 'notification_text';
  static const String _keyEmergencyContacts = 'emergency_contacts';
  static const String _keyLogs = 'check_logs';
  static const String _keyLastCheckIn = 'last_check_in';
  static const String _keyLastSMSSent = 'last_sms_sent';
  static const String _keyEmailMode = 'email_mode'; // 'always' or 'only_missed'
  static const String _keyTextSize = 'text_size'; // 'small', 'normal', 'large', 'extra_large'
  static const String _keyHapticFeedback = 'haptic_feedback'; // true/false
  static const String _keySimpleMode = 'simple_mode'; // true/false
  static const String _keyFCMToken = 'fcm_token';
  static const String _keyUserRole = 'user_role'; // 'user' or 'contact'
  static const String _keySMTPConfigured = 'smtp_configured'; // true/false
  static const String _keyPairingCodes = 'pairing_codes'; // Map of email -> code
  static const String _keyLinkedUsers = 'linked_users'; // For contacts: list of linked user emails
  static const String _keyContactNotificationSound = 'contact_notification_sound'; // true/false
  static const String _keyContactNotificationVibration = 'contact_notification_vibration'; // true/false
  static const String _keyLastOnboardingEmail = 'last_onboarding_email';
  static const String _keyLastOnboardingContactName = 'last_onboarding_contact_name';
  static const String _keyLastOnboardingUserName = 'last_onboarding_user_name';

  // Onboarding
  Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsOnboarded, value);
  }

  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsOnboarded) ?? false;
  }

  // User data - email address for emergency contact
  Future<void> setEmergencyNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setString(_keyEmergencyNumber, number);
    // Force a commit to ensure data is saved
    if (!success) {
      // Retry once if save failed
      await prefs.setString(_keyEmergencyNumber, number);
    }
  }

  Future<String?> getEmergencyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmergencyNumber);
  }


  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  // Settings
  Future<void> setCheckTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCheckTime, '${time.hour}:${time.minute}');
  }

  Future<TimeOfDay> getCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_keyCheckTime) ?? '9:0';
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> setCheckInterval(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCheckInterval, hours);
  }

  Future<int> getCheckInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCheckInterval) ?? 24; // Default: every day (24 hours)
  }


  Future<void> setReminderInterval(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderInterval, hours);
  }

  Future<int> getReminderInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyReminderInterval) ?? 1;
  }

  Future<void> setNotificationText(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotificationText, text);
  }

  Future<String> getNotificationText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNotificationText) ?? 'Ik ben oké';
  }

  // Emergency contacts (now supports dynamic values for fcmToken)
  Future<void> setEmergencyContacts(List<Map<String, dynamic>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmergencyContacts, jsonEncode(contacts));
  }

  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsString = prefs.getString(_keyEmergencyContacts);
    if (contactsString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(contactsString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // FCM Token
  Future<void> setFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFCMToken, token);
  }

  Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFCMToken);
  }

  // User role: 'user' (normal user with check-in) or 'contact' (only receives notifications)
  Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
  }

  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole) ?? 'user'; // Default: normal user
  }

  Future<bool> isContactMode() async {
    return await getUserRole() == 'contact';
  }

  // Logs
  Future<void> addCheckInLog() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    final logs = await getCheckInLogs();
    logs.insert(0, {'date': now, 'time': now});
    // Keep only last 10
    if (logs.length > 10) {
      logs.removeRange(10, logs.length);
    }
    await prefs.setString(_keyLogs, jsonEncode(logs));
    await prefs.setString(_keyLastCheckIn, now);
  }

  Future<List<Map<String, String>>> getCheckInLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsString = prefs.getString(_keyLogs);
    if (logsString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(logsString);
      return decoded.map((e) => Map<String, String>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLogs);
  }

  Future<DateTime?> getLastCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckInString = prefs.getString(_keyLastCheckIn);
    if (lastCheckInString == null) return null;
    try {
      return DateTime.parse(lastCheckInString);
    } catch (e) {
      return null;
    }
  }

  Future<void> setLastSMSSent(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSMSSent, dateTime.toIso8601String());
  }

  Future<DateTime?> getLastSMSSent() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSMSString = prefs.getString(_keyLastSMSSent);
    if (lastSMSString == null) return null;
    try {
      return DateTime.parse(lastSMSString);
    } catch (e) {
      return null;
    }
  }

  // Email mode: 'always' = send email on every check-in, 'only_missed' = only when missed
  Future<void> setEmailMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmailMode, mode);
  }

  Future<String> getEmailMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmailMode) ?? 'only_missed'; // Default: only when missed
  }

  // Text size: 'small', 'normal', 'large', 'extra_large'
  Future<void> setTextSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTextSize, size);
  }

  Future<String> getTextSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTextSize) ?? 'normal';
  }

  // Haptic feedback
  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHapticFeedback, enabled);
  }

  Future<bool> getHapticFeedbackEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHapticFeedback) ?? true; // Default: enabled
  }

  // Simple mode
  Future<void> setSimpleMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySimpleMode, enabled);
  }

  Future<bool> getSimpleMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySimpleMode) ?? true; // Default: simple mode enabled
  }

  // SMTP Configuration
  Future<void> setSMTPConfigured(bool configured) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySMTPConfigured, configured);
  }

  Future<bool> isSMTPConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySMTPConfigured) ?? false;
  }

  // Pairing codes for linking contacts
  Future<void> setPairingCode(String email, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final codesString = prefs.getString(_keyPairingCodes);
    Map<String, String> codes = {};
    if (codesString != null) {
      try {
        codes = Map<String, String>.from(jsonDecode(codesString));
      } catch (e) {
        codes = {};
      }
    }
    codes[email.toLowerCase()] = code;
    await prefs.setString(_keyPairingCodes, jsonEncode(codes));
  }

  Future<String?> getPairingCode(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final codesString = prefs.getString(_keyPairingCodes);
    if (codesString == null) return null;
    try {
      final codes = Map<String, String>.from(jsonDecode(codesString));
      return codes[email.toLowerCase()];
    } catch (e) {
      return null;
    }
  }

  Future<void> removePairingCode(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final codesString = prefs.getString(_keyPairingCodes);
    if (codesString == null) return;
    try {
      final codes = Map<String, String>.from(jsonDecode(codesString));
      codes.remove(email.toLowerCase());
      await prefs.setString(_keyPairingCodes, jsonEncode(codes));
    } catch (e) {
      // Ignore
    }
  }

  // Linked users (for contacts)
  Future<void> addLinkedUser(String userEmail, String userName, String userFcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    final linkedString = prefs.getString(_keyLinkedUsers);
    List<Map<String, dynamic>> linked = [];
    if (linkedString != null) {
      try {
        linked = (jsonDecode(linkedString) as List).map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (e) {
        linked = [];
      }
    }
    
    // Remove if already exists
    linked.removeWhere((u) => u['email']?.toLowerCase() == userEmail.toLowerCase());
    
    // Add new
    linked.add({
      'email': userEmail,
      'name': userName,
      'fcmToken': userFcmToken,
      'linkedAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_keyLinkedUsers, jsonEncode(linked));
  }

  Future<List<Map<String, dynamic>>> getLinkedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final linkedString = prefs.getString(_keyLinkedUsers);
    if (linkedString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(linkedString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> removeLinkedUser(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final linkedString = prefs.getString(_keyLinkedUsers);
    if (linkedString == null) return;
    try {
      final linked = (jsonDecode(linkedString) as List).map((e) => Map<String, dynamic>.from(e)).toList();
      linked.removeWhere((u) => u['email']?.toLowerCase() == userEmail.toLowerCase());
      await prefs.setString(_keyLinkedUsers, jsonEncode(linked));
    } catch (e) {
      // Ignore
    }
  }

  // Contact notification preferences
  Future<void> setContactNotificationSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyContactNotificationSound, enabled);
  }

  Future<bool> getContactNotificationSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyContactNotificationSound) ?? true; // Default: enabled
  }

  Future<void> setContactNotificationVibration(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyContactNotificationVibration, enabled);
  }

  Future<bool> getContactNotificationVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyContactNotificationVibration) ?? true; // Default: enabled
  }

  // Last onboarding data (for remembering entered values)
  Future<void> setLastOnboardingEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastOnboardingEmail, email);
  }

  Future<String?> getLastOnboardingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastOnboardingEmail);
  }

  Future<void> setLastOnboardingContactName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastOnboardingContactName, name);
  }

  Future<String?> getLastOnboardingContactName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastOnboardingContactName);
  }

  Future<void> setLastOnboardingUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastOnboardingUserName, name);
  }

  Future<String?> getLastOnboardingUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastOnboardingUserName);
  }
}
