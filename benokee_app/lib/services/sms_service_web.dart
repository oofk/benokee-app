// Web implementation - SMS not supported on web
class SMSService {
  static final SMSService _instance = SMSService._internal();
  factory SMSService() => _instance;
  SMSService._internal();

  Future<bool> sendSMS(String phoneNumber, String message) async {
    // SMS not supported on web
    return false;
  }

  Future<bool> hasPermission() async {
    return false;
  }
}
