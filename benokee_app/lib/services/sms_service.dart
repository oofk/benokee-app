// Conditional import - only import telephony on non-web platforms
import 'sms_service_stub.dart'
    if (dart.library.io) 'sms_service_io.dart'
    if (dart.library.html) 'sms_service_web.dart';

// Re-export the platform-specific implementation
export 'sms_service_stub.dart'
    if (dart.library.io) 'sms_service_io.dart'
    if (dart.library.html) 'sms_service_web.dart';
