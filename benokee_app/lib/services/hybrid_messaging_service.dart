import 'package:flutter/foundation.dart';
import 'fcm_service.dart';
import 'resend_email_service.dart';
import 'email_service.dart' as url_email;
import 'storage_service.dart';

class HybridMessagingService {
  static final HybridMessagingService _instance = HybridMessagingService._internal();
  factory HybridMessagingService() => _instance;
  HybridMessagingService._internal();

  final FCMService _fcmService = FCMService();
  final ResendEmailService _resendService = ResendEmailService();
  final url_email.EmailService _urlEmailService = url_email.EmailService();
  final StorageService _storage = StorageService();

  /// Send message using hybrid approach (FCM first, then email fallback)
  Future<bool> sendMessage({
    required String toEmail,
    required String subject,
    required String body,
    String? htmlBody,
    Map<String, dynamic>? fcmData,
  }) async {
    // Check if contact has app installed (has FCM token)
    final contactHasApp = await _fcmService.contactHasApp(toEmail);
    
    if (contactHasApp) {
      // Try FCM push notification first
      final fcmToken = await _fcmService.getContactToken(toEmail);
      if (fcmToken != null) {
        // Note: FCM sending requires backend. For now, we'll use email
        // TODO: Implement FCM sending via HTTP API or Cloud Functions
        debugPrint('Contact has app, but FCM sending requires backend. Using email fallback.');
      }
    }

    // Fallback to email (Resend via Firebase Functions)
    // Try Resend first (automatic, no user setup needed)
    final resendSuccess = await _resendService.sendEmail(
      to: toEmail,
      subject: subject,
      body: body,
      htmlBody: htmlBody,
    );
    
    if (resendSuccess) {
      return true;
    }

    // No fallback to URL launcher - email must be sent via Resend
    // Return false so app can continue in demo mode
    return false;
  }

  /// Send introduction email with app installation info
  Future<bool> sendIntroductionEmail({
    required String toEmail,
    required String contactName,
    required String userName,
    String? fcmToken, // User's FCM token to share
  }) async {
    // Generate app store links (will be replaced with actual links)
    final playStoreLink = 'https://play.google.com/store/apps/details?id=com.benokee.app';
    final appStoreLink = 'https://apps.apple.com/app/benokee/id123456789';
    
    // Use Resend service directly for introduction email
    return await _resendService.sendIntroductionEmail(
      to: toEmail,
      contactName: contactName,
      userName: userName,
      fcmToken: fcmToken,
      playStoreLink: playStoreLink,
      appStoreLink: appStoreLink,
    );
  }

  /// Send missed check-in alert
  Future<bool> sendMissedCheckInAlert({
    required String toEmail,
    required String contactName,
    required String userName,
    required int daysMissed,
    required DateTime lastCheckIn,
  }) async {
    final subject = 'Benokee Alert: $userName heeft niet gecheckt';
    final body = '''
Beste $contactName,

Dit is een automatische melding van de Benokee app.

$userName heeft $daysMissed opeenvolgende dagen niet ingelogd in de app.
De laatste check-in was op ${lastCheckIn.day}/${lastCheckIn.month}/${lastCheckIn.year}.

Neem alstublieft contact op met $userName om te controleren of alles in orde is.

⚠️ Belangrijk: Controleer ook je spam/ongewenste items map, want e-mails kunnen daar terechtkomen.

Met vriendelijke groet,
De Benokee app
''';

    return await sendMessage(
      toEmail: toEmail,
      subject: subject,
      body: body,
    );
  }

  /// Send "I'm OK" message
  Future<bool> sendOkMessage({
    required String toEmail,
    required String contactName,
    required String userName,
    required DateTime checkInTime,
  }) async {
    final subject = 'Benokee: $userName is oké';
    final body = '''
Beste $contactName,

Ik ben oké!

Check-in op ${checkInTime.day}/${checkInTime.month}/${checkInTime.year} om ${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}.

⚠️ Tip: Controleer ook je spam/ongewenste items map als je deze e-mails niet ontvangt.

Met vriendelijke groet,
$userName
''';

    return await sendMessage(
      toEmail: toEmail,
      subject: subject,
      body: body,
    );
  }
}
