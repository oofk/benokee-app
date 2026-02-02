import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/contact_home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue without Firebase if initialization fails
  }
  
  // Initialize localization
  await LocalizationService().init();
  
  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Amsterdam'));
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Set preferred orientations (not needed on Windows/Web)
  if (!kIsWeb && !Platform.isWindows) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  runApp(const BenokeeApp());
}

class BenokeeApp extends StatefulWidget {
  const BenokeeApp({super.key});

  @override
  State<BenokeeApp> createState() => _BenokeeAppState();
}

class _BenokeeAppState extends State<BenokeeApp> with WidgetsBindingObserver {
  final StorageService _storage = StorageService();
  String _textSize = 'normal';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTextSize();
    _checkAndReschedule();
  }

  Future<void> _loadTextSize() async {
    final size = await _storage.getTextSize();
    setState(() {
      _textSize = size;
    });
  }

  TextTheme _getTextTheme(String size) {
    final baseSize = (size == 'small' ? 20.0 : 
                     size == 'large' ? 28.0 : 
                     size == 'extra_large' ? 32.0 : 24.0);
    return TextTheme(
      displayLarge: TextStyle(fontSize: baseSize + 8, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: baseSize + 4, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: baseSize),
      bodyMedium: TextStyle(fontSize: baseSize - 4),
      bodySmall: TextStyle(fontSize: baseSize - 8),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkAndReschedule();
    }
  }

  Future<void> _checkAndReschedule() async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboarded = prefs.getBool('is_onboarded') ?? false;
    if (isOnboarded) {
      await NotificationService().rescheduleNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Benokee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[700],
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: _getTextTheme(_textSize),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[700],
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: _getTextTheme(_textSize),
      ),
      themeMode: ThemeMode.system,
      home: FutureBuilder<Map<String, dynamic>>(
        future: _checkInitialState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final isOnboarded = snapshot.data?['isOnboarded'] ?? false;
          final userRole = snapshot.data?['userRole'] ?? 'user';
          
          if (!isOnboarded) {
            return const RoleSelectionScreen();
          }
          
          if (userRole == 'contact') {
            return const ContactHomeScreen();
          }
          
          return const HomeScreen();
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _checkInitialState() async {
    final isOnboarded = await _storage.isOnboarded();
    final userRole = await _storage.getUserRole();
    return {
      'isOnboarded': isOnboarded,
      'userRole': userRole,
    };
  }
}
