import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/localization_service.dart';
import 'settings_screen.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final StorageService _storage = StorageService();
  final NotificationService _notificationService = NotificationService();
  final LocalizationService _localization = LocalizationService();
  DateTime? _lastCheckIn;
  bool _isDemoMode = false;
  bool _isLoadingDemoMode = true; // Track loading state
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastCheckIn();
    _checkAndReschedule();
    _checkDemoMode(); // This will set _isDemoMode and _isLoadingDemoMode
    // Update time display every minute
    _startTimer();
  }

  Future<void> _checkDemoMode() async {
    final contacts = await _storage.getEmergencyContacts();
    final emergencyNumber = await _storage.getEmergencyNumber();
    final hasContacts = (contacts.isNotEmpty) || (emergencyNumber != null && emergencyNumber.isNotEmpty);
    if (mounted) {
      setState(() {
        _isDemoMode = !hasContacts;
        _isLoadingDemoMode = false;
      });
    }
  }

  // Synchronous check for FutureBuilder
  Future<bool> _checkDemoModeSync() async {
    final contacts = await _storage.getEmergencyContacts();
    final emergencyNumber = await _storage.getEmergencyNumber();
    final hasContacts = (contacts.isNotEmpty) || (emergencyNumber != null && emergencyNumber.isNotEmpty);
    return !hasContacts;
  }

  void _startTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {});
        _startTimer();
      }
    });
  }

  Future<void> _loadLastCheckIn() async {
    final lastCheckIn = await _storage.getLastCheckIn();
    setState(() {
      _lastCheckIn = lastCheckIn;
    });
  }

  String _getTimeSinceLastCheckIn() {
    if (_lastCheckIn == null) {
      return _localization.translate('no_check_in_yet');
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastCheckIn!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? _localization.translate('day') : _localization.translate('days')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? _localization.translate('hour') : _localization.translate('hours')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? _localization.translate('minute') : _localization.translate('minutes')}';
    } else {
      return _localization.translate('just_now');
    }
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
      _checkDemoMode();
    }
  }

  Future<void> _checkAndReschedule() async {
    await _notificationService.rescheduleNotifications();
  }

  Future<void> _handleOkButton() async {
    // Check if there are any contacts configured
    final contacts = await _storage.getEmergencyContacts();
    final emergencyNumber = await _storage.getEmergencyNumber();
    final hasContacts = (contacts.isNotEmpty) || (emergencyNumber != null && emergencyNumber.isNotEmpty);
    
    if (!hasContacts) {
      // Show warning that contact person must be added first
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              _localization.translate('no_contact_warning'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            content: Text(
              _localization.translate('no_contact_warning_desc'),
              style: const TextStyle(fontSize: 20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_localization.translate('cancel'), style: const TextStyle(fontSize: 18)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to settings -> contact management to add contact
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(openContactsDirectly: true),
                    ),
                  ).then((_) {
                    // Check demo mode after returning
                    _checkDemoMode();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                child: Text(_localization.translate('add_contact'), style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Haptic feedback (if enabled)
    final hapticEnabled = await _storage.getHapticFeedbackEnabled();
    if (hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    // Double-check contacts before proceeding (in case state changed)
    final contactsCheck = await _storage.getEmergencyContacts();
    final emergencyNumberCheck = await _storage.getEmergencyNumber();
    final hasContactsCheck = (contactsCheck.isNotEmpty) || (emergencyNumberCheck != null && emergencyNumberCheck.isNotEmpty);
    
    if (!hasContactsCheck) {
      // Contacts were removed between check and action - show warning
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_localization.translate('no_contact_warning')),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Log check-in
    await _storage.addCheckInLog();

    // Check email mode and send email if needed
    final emailMode = await _storage.getEmailMode();
    bool emailSent = false;
    if (emailMode == 'always') {
      // Send "ik ben oké" email on every check-in
      emailSent = await _notificationService.sendOkEmail();
    }

    // Reschedule next notification
    await _notificationService.rescheduleNotifications();

    // Reload last check-in time
    await _loadLastCheckIn();

    // Show confirmation feedback - only if we actually have contacts
    if (mounted) {
      if (emailMode == 'always' && emailSent) {
        await _showCheckInConfirmation();
      } else if (emailMode == 'always' && !emailSent) {
        // Email mode is 'always' but sending failed - show warning
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Check-in geregistreerd, maar e-mail verzenden mislukt. Controleer je contactpersonen.'),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Show snackbar for other modes (only if we have contacts)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_localization.translate('check_in_registered')),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showCheckInConfirmation() async {
    if (!mounted) return;
    
    // Show dialog and auto-close after 2 seconds
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (dialogContext) {
        // Auto-close after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });
        
        return AlertDialog(
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large success icon with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      Icons.check_circle,
                      size: 100,
                      color: Colors.green[700],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                _localization.translate('check_in_registered'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _localization.translate('contact_notified'),
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[800], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Controleer ook de spam/ongewenste items map.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    // Show warning dialog when user tries to close the app
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _localization.translate('exit_warning_title'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          _localization.translate('exit_warning_message'),
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              _localization.translate('keep_running'),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              _localization.translate('exit_anyway'),
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await _onWillPop();
        if (shouldExit && context.mounted) {
          // Exit the app
          // Note: On Android, we can't actually prevent the app from being closed
          // but we can show the warning
        }
      },
      child: Scaffold(
        body: SafeArea(
        child: Stack(
          children: [
            // Warning banner at top if no contacts - always check, don't wait for loading
            Builder(
              builder: (context) {
                // Check contacts synchronously in build to ensure banner shows immediately
                return FutureBuilder<bool>(
                  future: _checkDemoModeSync(),
                  initialData: _isDemoMode,
                  builder: (context, snapshot) {
                    final isDemo = snapshot.data ?? _isDemoMode;
                    if (!isDemo) return const SizedBox.shrink();
                    
                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          border: Border.all(color: Colors.orange[400]!, width: 3),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange[900], size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _localization.translate('no_contact_warning'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[900],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _localization.translate('no_contact_warning_desc'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Main OK button
            Center(
              child: GestureDetector(
                onTap: _handleOkButton,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use the smaller dimension to ensure a perfect circle
                    final size = MediaQuery.of(context).size;
                    final buttonSize = size.width < size.height
                        ? size.width * 0.8
                        : size.height * 0.8;
                    // Calculate font size based on button size (approximately 20% of button size)
                    final fontSize = buttonSize * 0.2;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // OK Button - visually disabled if no contacts
                        FutureBuilder<bool>(
                          future: _checkDemoModeSync(),
                          initialData: _isDemoMode,
                          builder: (context, snapshot) {
                            final isDemo = snapshot.data ?? _isDemoMode;
                            return Opacity(
                              opacity: isDemo ? 0.5 : 1.0,
                              child: Container(
                                width: buttonSize,
                                height: buttonSize,
                                decoration: BoxDecoration(
                                  color: isDemo ? Colors.grey[400] : Colors.green[700],
                                  shape: BoxShape.circle,
                                  boxShadow: isDemo ? [] : [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _localization.translate('i_am_ok'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: fontSize * 0.04,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _lastCheckIn != null
                                ? _localization.translate('last_check_in') + ': ' + _getTimeSinceLastCheckIn()
                                : _localization.translate('no_check_in_yet'),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Settings icon (top right, 10% of screen)
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                  // Always check demo mode after returning from settings
                  if (mounted) {
                    _checkDemoMode();
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings,
                    size: MediaQuery.of(context).size.width * 0.06,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
            // Demo mode banner (bottom)
            if (_isDemoMode)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    border: Border(
                      top: BorderSide(color: Colors.orange[300]!, width: 2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[800]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _localization.translate('demo_mode'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _localization.translate('demo_mode_desc'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Navigate directly to settings -> contact management
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(openContactsDirectly: true),
                                ),
                              );
                              // Check demo mode after returning
                              if (mounted) {
                                _checkDemoMode();
                              }
                            },
                            icon: const Icon(Icons.person_add),
                            label: Text(_localization.translate('add_contact')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
