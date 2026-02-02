// SMS service is deprecated - app now uses email instead
// This file is kept for backwards compatibility but SMS functionality is disabled
import 'dart:io';

class SMSService {
  static final SMSService _instance = SMSService._internal();
  factory SMSService() => _instance;
  SMSService._internal();

  Future<bool> sendSMS(String phoneNumber, String message) async {
    // SMS is no longer supported - app uses email instead
    return false;
  }

  Future<bool> hasPermission() async {
    // SMS is no longer supported
    return false;
  }
}
