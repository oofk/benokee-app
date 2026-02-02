import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class SMTPEmailService {
  static final SMTPEmailService _instance = SMTPEmailService._internal();
  factory SMTPEmailService() => _instance;
  SMTPEmailService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final StorageService _storage = StorageService();

  static const String _keyEmailAddress = 'smtp_email_address';
  static const String _keyEmailPassword = 'smtp_email_password';

  /// Save email credentials securely
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _keyEmailAddress, value: email);
    await _secureStorage.write(key: _keyEmailPassword, value: password);
  }

  /// Get saved email address
  Future<String?> getEmailAddress() async {
    return await _secureStorage.read(key: _keyEmailAddress);
  }

  /// Check if credentials are saved
  Future<bool> hasCredentials() async {
    final email = await _secureStorage.read(key: _keyEmailAddress);
    final password = await _secureStorage.read(key: _keyEmailPassword);
    return email != null && password != null && email.isNotEmpty && password.isNotEmpty;
  }

  /// Detect SMTP server settings from email address
  SmtpServer _getSmtpServer(String email) {
    final domain = email.split('@')[1].toLowerCase();
    
    if (domain.contains('gmail')) {
      return SmtpServer('smtp.gmail.com',
        port: 587,
        ssl: false,
        allowInsecure: false,
      );
    } else if (domain.contains('outlook') || domain.contains('hotmail') || domain.contains('live')) {
      return SmtpServer('smtp-mail.outlook.com',
        port: 587,
        ssl: false,
        allowInsecure: false,
      );
    } else if (domain.contains('yahoo')) {
      return SmtpServer('smtp.mail.yahoo.com',
        port: 587,
        ssl: false,
        allowInsecure: false,
      );
    } else {
      // Generic SMTP server (user might need to configure)
      return SmtpServer('smtp.$domain',
        port: 587,
        ssl: false,
        allowInsecure: false,
      );
    }
  }

  /// Send email via SMTP
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? htmlBody,
  }) async {
    try {
      final emailAddress = await getEmailAddress();
      final password = await _secureStorage.read(key: _keyEmailPassword);
      
      if (emailAddress == null || password == null) {
        debugPrint('SMTP credentials not found');
        return false;
      }

      final smtpServer = _getSmtpServer(emailAddress);
      
      final message = Message()
        ..from = Address(emailAddress, await _storage.getUserName() ?? 'Benokee App')
        ..recipients.add(to)
        ..subject = subject
        ..text = body;
      
      if (htmlBody != null) {
        message.html = htmlBody;
      }

      final sendReport = await send(message, smtpServer);
      
      debugPrint('Email sent: ${sendReport.toString()}');
      return true;
    } catch (e) {
      debugPrint('SMTP email error: $e');
      return false;
    }
  }
}
