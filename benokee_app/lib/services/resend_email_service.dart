import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class ResendEmailService {
  static final ResendEmailService _instance = ResendEmailService._internal();
  factory ResendEmailService() => _instance;
  ResendEmailService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Send email via Firebase Functions (Resend API)
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? htmlBody,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendEmail');
      final result = await callable.call({
        'to': to,
        'subject': subject,
        'body': body,
        if (htmlBody != null) 'htmlBody': htmlBody,
      });

      final data = result.data as Map<String, dynamic>;
      final success = data['success'] == true;
      
      if (success) {
        debugPrint('Email sent successfully to $to');
      } else {
        debugPrint('Email send returned false for $to');
      }
      
      return success;
    } catch (e) {
      debugPrint('Resend email error: $e');
      debugPrint('Error details: ${e.toString()}');
      // Don't throw - return false so app can continue in demo mode
      return false;
    }
  }

  /// Send introduction email with app installation info
  Future<bool> sendIntroductionEmail({
    required String to,
    required String contactName,
    required String userName,
    String? fcmToken,
    String? playStoreLink,
    String? appStoreLink,
  }) async {
    try {
      debugPrint('Sending introduction email to $to');
      debugPrint('Contact name: $contactName, User name: $userName');
      
      final callable = _functions.httpsCallable('sendIntroductionEmail');
      final result = await callable.call({
        'to': to,
        'contactName': contactName,
        'userName': userName,
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (playStoreLink != null) 'playStoreLink': playStoreLink,
        if (appStoreLink != null) 'appStoreLink': appStoreLink,
      });

      debugPrint('Firebase Function result: ${result.data}');
      
      final data = result.data as Map<String, dynamic>;
      final success = data['success'] == true;
      
      if (success) {
        debugPrint('Introduction email sent successfully to $to');
        return true;
      } else {
        debugPrint('Introduction email send returned false for $to');
        debugPrint('Response data: $data');
        
        // Log error details if available
        if (data.containsKey('error')) {
          debugPrint('Error message: ${data['error']}');
          debugPrint('Error name: ${data['errorName']}');
          debugPrint('Status code: ${data['statusCode']}');
        }
        
        return false;
      }
    } catch (e) {
      debugPrint('Resend introduction email error: $e');
      debugPrint('Error details: ${e.toString()}');
      
      // Check if it's a Firebase Functions error
      if (e is FirebaseFunctionsException) {
        debugPrint('Firebase Functions error code: ${e.code}');
        debugPrint('Firebase Functions error message: ${e.message}');
        debugPrint('Firebase Functions error details: ${e.details}');
        
        // Log specific error information
        if (e.code == 'invalid-argument') {
          debugPrint('Invalid argument error - check required fields');
        } else if (e.code == 'internal') {
          debugPrint('Internal server error - check Firebase logs');
        } else if (e.code == 'unavailable') {
          debugPrint('Service unavailable - Firebase Functions may be down');
        }
      }
      
      if (e is Exception) {
        debugPrint('Exception type: ${e.runtimeType}');
      }
      
      // Don't throw - return false so app can continue in demo mode
      return false;
    }
  }
}
