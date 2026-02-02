import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'storage_service.dart';
import 'hybrid_messaging_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final StorageService _storage = StorageService();
  final HybridMessagingService _messagingService = HybridMessagingService();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Windows and Web don't support local notifications the same way
    if (kIsWeb || (!kIsWeb && Platform.isWindows)) {
      _initialized = true;
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) async {
        await _onNotificationTapped(response);
      },
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    // Android 13+ notification permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Android exact alarm permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap - app will open automatically
      // If it's the email alert trigger notification (ID 200), check and send email
      if (response.id == 200) {
        await _checkAndSendEmailAlert();
      }
  }

  Future<void> scheduleNextCheckIn() async {
    try {
      debugPrint('[NotificationService] scheduleNextCheckIn: Starting');
      
      if (!_initialized) {
        debugPrint('[NotificationService] scheduleNextCheckIn: Not initialized, initializing...');
        await initialize();
      }
      
      final checkTime = await _storage.getCheckTime();
      final interval = await _storage.getCheckInterval();
      final notificationText = await _storage.getNotificationText();
      
      debugPrint('[NotificationService] scheduleNextCheckIn: checkTime=$checkTime, interval=$interval');

      // Calculate next check-in time
      final now = tz.TZDateTime.now(tz.local);
      var nextCheck = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        checkTime.hour,
        checkTime.minute,
      );

      // If time has passed today, schedule for tomorrow
      if (nextCheck.isBefore(now)) {
        nextCheck = nextCheck.add(const Duration(days: 1));
      }

      // Add interval days
      nextCheck = nextCheck.add(Duration(days: interval ~/ 24));
      if (interval % 24 > 0) {
        nextCheck = nextCheck.add(Duration(hours: interval % 24));
      }
      
      debugPrint('[NotificationService] scheduleNextCheckIn: nextCheck=$nextCheck');

      const androidDetails = AndroidNotificationDetails(
        'check_in_channel',
        'Check-in Notificaties',
        channelDescription: 'Notificaties voor check-in reminders',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        enableLights: true,
        ledColor: Colors.green,
        ledOnMs: 1000, // LED on duration in milliseconds
        ledOffMs: 500, // LED off duration in milliseconds
        visibility: NotificationVisibility.public,
        fullScreenIntent: true, // Show as heads-up notification
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use friendly notification text with emoji
      final friendlyText = notificationText.contains('👋') 
          ? notificationText 
          : '👋 Tijd om te checken! Druk op de groene knop in de app.';
      
      debugPrint('[NotificationService] scheduleNextCheckIn: Scheduling notification for $nextCheck');
      
      await _notifications.zonedSchedule(
        1,
        'Benokee Check-in',
        friendlyText,
        nextCheck,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      debugPrint('[NotificationService] scheduleNextCheckIn: Successfully scheduled');
    } catch (e, stackTrace) {
      debugPrint('[NotificationService] scheduleNextCheckIn: ERROR - $e');
      debugPrint('[NotificationService] scheduleNextCheckIn: Stack trace: $stackTrace');
      // Don't rethrow - we don't want to break onboarding if notification scheduling fails
    }
  }

  // Grace period functionality removed - no longer needed

  Future<void> _checkAndSendEmailAlert() async {
    final lastCheckIn = await _storage.getLastCheckIn();
    if (lastCheckIn == null) return;

    final now = DateTime.now();
    final timeSinceCheckIn = now.difference(lastCheckIn);
    
    // Send email if 2 consecutive days (48+ hours) have passed without check-in
    // Email is sent on the 3rd day (after 2 missed days)
    if (timeSinceCheckIn.inHours >= 48) {
      // Check if email was already sent for this missed period
      final lastEmailSent = await _storage.getLastSMSSent(); // Reusing this field for email tracking
      if (lastEmailSent == null || lastEmailSent.isBefore(lastCheckIn)) {
        await _sendMissedCheckInEmail();
      }
    }
  }

  Future<bool> sendOkEmail() async {
    final emergencyContacts = await _storage.getEmergencyContacts();
    final userName = await _storage.getUserName() ?? 'Gebruiker';
    final now = DateTime.now();

    // Check if there are any contacts to send to
    if (emergencyContacts.isEmpty) {
      final emergencyNumber = await _storage.getEmergencyNumber();
      if (emergencyNumber == null || emergencyNumber.isEmpty || !emergencyNumber.contains('@')) {
        // No contacts at all
        return false;
      }
    }

    bool anyEmailSent = false;

    // Send to all emergency contacts
    for (final contact in emergencyContacts) {
      final email = contact['number'] as String?;
      if (email != null && email.contains('@')) {
        final success = await _messagingService.sendOkMessage(
          toEmail: email,
          contactName: contact['name'] as String? ?? 'contactpersoon',
          userName: userName,
          checkInTime: now,
        );
        if (success) {
          anyEmailSent = true;
        }
      }
    }
    
    // Also check legacy emergency number
    final emergencyNumber = await _storage.getEmergencyNumber();
    if (emergencyNumber != null && emergencyNumber.contains('@')) {
      // Check if this email is not already in contacts list
      final alreadySent = emergencyContacts.any((c) => c['number'] == emergencyNumber);
      if (!alreadySent) {
        final success = await _messagingService.sendOkMessage(
          toEmail: emergencyNumber,
          contactName: 'contactpersoon',
          userName: userName,
          checkInTime: now,
        );
        if (success) {
          anyEmailSent = true;
        }
      }
    }

    return anyEmailSent;
  }

  Future<void> _sendMissedCheckInEmail() async {
    final emergencyContacts = await _storage.getEmergencyContacts();
    final userName = await _storage.getUserName() ?? 'Gebruiker';
    final lastCheckIn = await _storage.getLastCheckIn();
    final now = DateTime.now();

    if (emergencyContacts.isEmpty || lastCheckIn == null) return;

    // Calculate days missed
    final daysMissed = (now.difference(lastCheckIn).inHours / 24).floor();
    
    // Send to all emergency contacts
    for (final contact in emergencyContacts) {
      final email = contact['number'] as String?;
      if (email != null && email.contains('@')) {
        final success = await _messagingService.sendMissedCheckInAlert(
          toEmail: email,
          contactName: contact['name'] as String? ?? 'contactpersoon',
          userName: userName,
          daysMissed: daysMissed,
          lastCheckIn: lastCheckIn,
        );
        if (success) {
          await _storage.setLastSMSSent(now); // Track that email was sent
        }
      }
    }
    
    // Also check legacy emergency number
    final emergencyNumber = await _storage.getEmergencyNumber();
    if (emergencyNumber != null && emergencyNumber.contains('@')) {
      // Check if this email is not already in contacts list
      final alreadySent = emergencyContacts.any((c) => c['number'] == emergencyNumber);
      if (!alreadySent) {
        final success = await _messagingService.sendMissedCheckInAlert(
          toEmail: emergencyNumber,
          contactName: 'contactpersoon',
          userName: userName,
          daysMissed: daysMissed,
          lastCheckIn: lastCheckIn,
        );
        if (success) {
          await _storage.setLastSMSSent(now);
        }
      }
    }
  }

  Future<void> rescheduleNotifications() async {
    // Don't cancel all - we need to keep scheduled reminders
    // Only cancel check-in notification and reschedule
    await _notifications.cancel(1);
    await scheduleNextCheckIn();
    await _checkAndSendEmailAlert();
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
