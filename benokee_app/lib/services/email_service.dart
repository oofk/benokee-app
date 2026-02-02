import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  /// Opens the default email app with pre-filled recipient, subject, and body
  /// Returns true if the email app was opened successfully
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    try {
      // Create mailto URL with proper encoding
      // Use encodeComponent to properly encode special characters
      final encodedSubject = Uri.encodeComponent(subject);
      final encodedBody = Uri.encodeComponent(body);
      
      // Build mailto URL manually to ensure proper encoding
      final mailtoUrl = 'mailto:$to?subject=$encodedSubject&body=$encodedBody';
      
      final emailUri = Uri.parse(mailtoUrl);

      // Check if we can launch the URL
      final canLaunch = await canLaunchUrl(emailUri);
      
      if (canLaunch) {
        // Try different launch modes
        try {
          await launchUrl(
            emailUri,
            mode: LaunchMode.externalApplication,
          );
          return true;
        } catch (e) {
          // Fallback: try platform default
          try {
            await launchUrl(
              emailUri,
              mode: LaunchMode.platformDefault,
            );
            return true;
          } catch (e2) {
            debugPrint('Failed to launch email: $e2');
            return false;
          }
        }
      } else {
        debugPrint('Cannot launch email URL: $mailtoUrl');
        return false;
      }
    } catch (e) {
      debugPrint('Email service error: $e');
      return false;
    }
  }
}
