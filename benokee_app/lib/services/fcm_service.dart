import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StorageService _storage = StorageService();
  
  String? _fcmToken;
  bool _initialized = false;

  /// Initialize FCM and get token
  Future<String?> initialize() async {
    if (_initialized && _fcmToken != null) {
      return _fcmToken;
    }

    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        
        if (_fcmToken != null) {
          await _storage.setFCMToken(_fcmToken!);
          _initialized = true;
          debugPrint('FCM Token: $_fcmToken');
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _storage.setFCMToken(newToken);
          debugPrint('FCM Token refreshed: $newToken');
        });
      } else {
        debugPrint('FCM permission denied');
      }
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }

    return _fcmToken;
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    if (_fcmToken != null) {
      return _fcmToken;
    }
    
    _fcmToken = await _storage.getFCMToken();
    if (_fcmToken == null) {
      return await initialize();
    }
    
    return _fcmToken;
  }

  /// Send push notification to a specific FCM token
  /// Note: This requires a backend service. For now, we'll use Firebase Cloud Functions
  /// or HTTP API calls to FCM server
  Future<bool> sendNotification({
    required String toToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This requires a backend service to send FCM messages
    // For now, we'll return false and use email fallback
    // TODO: Implement FCM sending via HTTP API or Cloud Functions
    debugPrint('FCM send notification not implemented yet - requires backend');
    return false;
  }

  /// Check if a contact has FCM token (has app installed)
  Future<bool> contactHasApp(String contactEmail) async {
    final contacts = await _storage.getEmergencyContacts();
    final contact = contacts.firstWhere(
      (c) => c['number']?.toLowerCase() == contactEmail.toLowerCase(),
      orElse: () => {},
    );
    
    return contact['fcmToken'] != null && contact['fcmToken'].toString().isNotEmpty;
  }

  /// Set FCM token for a contact
  Future<void> setContactToken(String contactEmail, String fcmToken) async {
    final contacts = await _storage.getEmergencyContacts();
    final index = contacts.indexWhere(
      (c) => c['number']?.toLowerCase() == contactEmail.toLowerCase(),
    );
    
    if (index >= 0) {
      contacts[index]['fcmToken'] = fcmToken;
      await _storage.setEmergencyContacts(contacts);
    }
  }

  /// Get FCM token for a contact
  Future<String?> getContactToken(String contactEmail) async {
    final contacts = await _storage.getEmergencyContacts();
    final contact = contacts.firstWhere(
      (c) => c['number']?.toLowerCase() == contactEmail.toLowerCase(),
      orElse: () => {},
    );
    
    return contact['fcmToken'] as String?;
  }
}
