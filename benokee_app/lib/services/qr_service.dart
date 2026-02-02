import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class QRService {
  static final QRService _instance = QRService._internal();
  factory QRService() => _instance;
  QRService._internal();

  /// Generate QR code widget for app installation link
  Widget generateQRCode({
    required String data,
    double size = 200,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  /// Generate deep link for contact person
  String generateDeepLink({
    required String fcmToken,
    required String email,
    String? userName,
  }) {
    final params = {
      'token': fcmToken,
      'email': email,
      if (userName != null) 'name': userName,
    };
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return 'benokee://contact?$queryString';
  }

  /// Generate app store links
  String getPlayStoreLink() {
    // TODO: Replace with actual Play Store link when app is published
    return 'https://play.google.com/store/apps/details?id=com.benokee.app';
  }

  String getAppStoreLink() {
    // TODO: Replace with actual App Store link when app is published
    return 'https://apps.apple.com/app/benokee/id123456789';
  }

  /// Generate combined QR code data (deep link + store links)
  String generateQRData({
    required String fcmToken,
    required String email,
    String? userName,
  }) {
    final deepLink = generateDeepLink(
      fcmToken: fcmToken,
      email: email,
      userName: userName,
    );
    
    // Include both deep link and store links in QR data
    return '''
$deepLink

Download de app:
Android: ${getPlayStoreLink()}
iOS: ${getAppStoreLink()}
''';
  }
}
