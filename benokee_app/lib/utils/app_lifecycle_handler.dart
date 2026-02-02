import '../services/notification_service.dart';
import '../services/storage_service.dart';

class AppLifecycleHandler {
  static Future<void> handleAppResumed() async {
    final storage = StorageService();
    final notificationService = NotificationService();
    
    // Check if 2 consecutive days have passed without check-in and send email if needed
    final lastCheckIn = await storage.getLastCheckIn();
    if (lastCheckIn != null) {
      final now = DateTime.now();
      final timeSinceCheckIn = now.difference(lastCheckIn);
      
      // If 2 consecutive days (48+ hours) have passed, email alert will be sent
      if (timeSinceCheckIn.inHours >= 48) {
        // This will be handled by notification service
        await notificationService.rescheduleNotifications();
      }
    }
    
    // Always reschedule to ensure notifications are up to date
    await notificationService.rescheduleNotifications();
  }
}
