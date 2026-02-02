// Stub implementation for platforms that don't support SMS
class SMSService {
  static final SMSService _instance = SMSService._internal();
  factory SMSService() => _instance;
  SMSService._internal();

  Future<bool> sendSMS(String phoneNumber, String message) async {
    return false;
  }

  Future<bool> hasPermission() async {
    return false;
  }
}
