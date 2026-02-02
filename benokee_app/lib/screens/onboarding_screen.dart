import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/localization_service.dart';
import '../services/hybrid_messaging_service.dart';
import '../services/fcm_service.dart';
import 'home_screen.dart';
import 'help_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isRedo;
  final bool returnToPrevious;
  final String? prefillUserName;
  final String? prefillEmail;
  final String? prefillContactName;
  
  const OnboardingScreen({
    super.key,
    this.isRedo = false,
    this.returnToPrevious = false,
    this.prefillUserName,
    this.prefillEmail,
    this.prefillContactName,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final StorageService _storage = StorageService();
  final LocalizationService _localization = LocalizationService();
  final HybridMessagingService _messagingService = HybridMessagingService();
  final FCMService _fcmService = FCMService();
  bool _introEmailSent = false;

  List<OnboardingPage> get _pages {
    return [
      OnboardingPage(
        title: _localization.translate('welcome_title'),
        description: _localization.translate('welcome_desc'),
        icon: Icons.favorite,
        isWelcome: true,
      ),
      OnboardingPage(
        title: _localization.translate('what_is_benokee'),
        description: _localization.translate('what_is_benokee_desc'),
        icon: Icons.info_outline,
      ),
      OnboardingPage(
        title: _localization.translate('how_app_works'),
        description: _localization.translate('how_app_works_desc'),
        icon: Icons.settings,
      ),
      OnboardingPage(
        title: _localization.translate('why_benokee'),
        description: _localization.translate('why_benokee_desc'),
        icon: Icons.favorite_border,
      ),
      OnboardingPage(
        title: _localization.translate('enter_your_name'),
        description: _localization.translate('enter_your_name_desc'),
        icon: Icons.person,
      ),
      OnboardingPage(
        title: _localization.translate('enter_contact'),
        description: _localization.translate('enter_contact_desc'),
        icon: Icons.email,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    // Load previously entered data
    _loadPreviousData();
  }

  Future<void> _loadPreviousData() async {
    // Load user name if available
    final lastUserName = await _storage.getLastOnboardingUserName();
    if (lastUserName != null && lastUserName.isNotEmpty) {
      _userNameController.text = lastUserName;
    } else if (widget.prefillUserName != null && widget.prefillUserName!.isNotEmpty) {
      _userNameController.text = widget.prefillUserName!;
    } else {
      // Try to load from saved user name
      final savedUserName = await _storage.getUserName();
      if (savedUserName != null && savedUserName.isNotEmpty) {
        _userNameController.text = savedUserName;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _contactNameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showEmailInput();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }


  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localization.translate('help'), style: const TextStyle(fontSize: 28)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _localization.translate('how_app_works'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _pages[_currentPage].description,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Text(
                _localization.translate('onboarding_help_general'),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_localization.translate('back'), style: const TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              );
            },
            child: Text(_localization.translate('help'), style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  void _showEmailInput() {
    // First show dialog for user's own name
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _localization.translate('enter_your_name'),
          style: const TextStyle(fontSize: 28),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _localization.translate('enter_your_name_desc'),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: _localization.translate('your_name'),
                  hintText: _localization.translate('name_placeholder'),
                  border: const OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 24),
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pageController.jumpToPage(_pages.length - 1);
            },
            child: Text(_localization.translate('back'), style: const TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_userNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_localization.translate('enter_your_name')),
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }
              Navigator.of(context).pop();
              _showContactInput();
            },
            child: Text(_localization.translate('next'), style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  void _showContactInput() async {
    bool introEmailSent = false; // Local variable for dialog state
    
    // Load previously entered data if available
    final lastEmail = await _storage.getLastOnboardingEmail();
    final lastContactName = await _storage.getLastOnboardingContactName();
    final lastUserName = await _storage.getLastOnboardingUserName();
    
    // Prefill with widget prefill values, or last entered values, or existing contact
    if (widget.prefillEmail != null && widget.prefillEmail!.isNotEmpty) {
      _emailController.text = widget.prefillEmail!;
    } else if (lastEmail != null && lastEmail.isNotEmpty) {
      _emailController.text = lastEmail;
    } else {
      final contacts = await _storage.getEmergencyContacts();
      final emergencyNumber = await _storage.getEmergencyNumber();
      if (contacts.isEmpty && (emergencyNumber == null || emergencyNumber.isEmpty)) {
        _emailController.clear();
      } else if (emergencyNumber != null && emergencyNumber.isNotEmpty) {
        _emailController.text = emergencyNumber;
      }
    }
    
    if (lastContactName != null && lastContactName.isNotEmpty) {
      _contactNameController.text = lastContactName;
    }
    
    if (lastUserName != null && lastUserName.isNotEmpty && _userNameController.text.isEmpty) {
      _userNameController.text = lastUserName;
    }
    
    // Get root context BEFORE showing dialog
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            _localization.translate('add_contact'),
            style: const TextStyle(fontSize: 28),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _localization.translate('enter_contact_desc'),
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: _localization.translate('email_address'),
                    hintText: _localization.translate('email_placeholder'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 24),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _contactNameController,
                  decoration: InputDecoration(
                    labelText: _localization.translate('contact_name_optional'),
                    hintText: _localization.translate('contact_name_placeholder'),
                    border: const OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final emailText = _emailController.text.trim();
                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(emailText)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_localization.translate('enter_valid_email')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      final success = await _sendIntroductionEmail(setDialogState);
                      if (success) {
                        setDialogState(() {
                          introEmailSent = true;
                        });
                      }
                    },
                    icon: Icon(introEmailSent ? Icons.check_circle : Icons.email),
                    label: Text(introEmailSent 
                        ? _localization.translate('intro_email_sent')
                        : _localization.translate('send_intro_email')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: introEmailSent ? Colors.green[700] : Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (!introEmailSent) ...[
                  const SizedBox(height: 10),
                  Text(
                    _localization.translate('intro_email_optional'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pageController.jumpToPage(_pages.length - 1);
              },
              child: Text(_localization.translate('back'), style: const TextStyle(fontSize: 20)),
            ),
            // Skip button (always visible)
            TextButton(
              onPressed: () async {
                try {
                  debugPrint('[Onboarding] Skip button pressed - START');
                  // Skip email - save without email and go to demo mode
                  final emailText = _emailController.text.trim();
                  debugPrint('[Onboarding] Skip: emailText="$emailText"');
                  
                  if (emailText.isNotEmpty) {
                    // Validate email if provided
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (emailRegex.hasMatch(emailText)) {
                      debugPrint('[Onboarding] Skip: Valid email, saving contact');
                      // Save contact even if email not sent
                      await _saveContactWithoutEmail(emailText);
                    }
                  }
                  // Save user name if provided
                  final userName = _userNameController.text.trim();
                  if (userName.isNotEmpty) {
                    debugPrint('[Onboarding] Skip: Saving userName="$userName"');
                    await _storage.setUserName(userName);
                    // Also save for next onboarding
                    await _storage.setLastOnboardingUserName(userName);
                  }
                  
                  debugPrint('[Onboarding] Skip: Closing dialog');
                  // Close dialog first
                  Navigator.of(context, rootNavigator: true).pop();
                  debugPrint('[Onboarding] Skip: Dialog closed, waiting...');
                  
                  // Wait a moment for dialog to close
                  await Future.delayed(const Duration(milliseconds: 200));
                  
                  debugPrint('[Onboarding] Skip: Calling _completeWithoutEmail');
                  // Now navigate
                  await _completeWithoutEmail();
                  debugPrint('[Onboarding] Skip button pressed - COMPLETE');
                } catch (e, stackTrace) {
                  debugPrint('[Onboarding] Skip: ERROR - $e');
                  debugPrint('[Onboarding] Skip: Stack trace: $stackTrace');
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fout bij overslaan: $e'),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: Text(_localization.translate('skip') ?? 'Overslaan', style: const TextStyle(fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  debugPrint('[Onboarding] Save button pressed - START');
                  // Check if email is provided
                  final emailText = _emailController.text.trim();
                  debugPrint('[Onboarding] Save: emailText="$emailText", introEmailSent=$introEmailSent');
                  
                  if (emailText.isEmpty) {
                    debugPrint('[Onboarding] Save: No email provided, showing message');
                    // No email provided - show message and stay on screen
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Voer een e-mailadres in om de app te laten werken. Je kunt doorgaan in demo modus met de knop "Overslaan".'),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                    return; // Stay on the same screen, don't navigate
                  }
                  
                  // Valideer email
                  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(emailText)) {
                    debugPrint('[Onboarding] Save: Invalid email format');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_localization.translate('enter_valid_email')),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    return;
                  }
                  
                  // Check if introduction email was sent
                  if (!introEmailSent) {
                    debugPrint('[Onboarding] Save: Introduction email not sent, showing warning');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Verstuur eerst de introductie e-mail. Druk op "Overslaan" als u de mail nog niet wil versturen.'),
                          duration: const Duration(seconds: 4),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    return; // Stay on screen, don't save
                  }
                  
                  // Email was sent, proceed with save and complete
                  debugPrint('[Onboarding] Save: Email sent, using _saveAndComplete');
                  // Save and complete - this will close dialog and navigate
                  final userName = _userNameController.text.trim();
                  final contactName = _contactNameController.text.trim();
                  debugPrint('[Onboarding] Save: userName="$userName", contactName="$contactName"');
                  
                  // Save entered data for next time
                  await _storage.setLastOnboardingEmail(emailText);
                  await _storage.setLastOnboardingContactName(contactName);
                  if (userName.isNotEmpty) {
                    await _storage.setLastOnboardingUserName(userName);
                  }
                  
                  // Close dialog first
                  debugPrint('[Onboarding] Save: Closing dialog');
                  Navigator.of(context, rootNavigator: true).pop();
                  
                  // Wait a moment for dialog to close
                  await Future.delayed(const Duration(milliseconds: 200));
                  debugPrint('[Onboarding] Save: Dialog closed, calling _saveAndComplete');
                  
                  // Now save and navigate
                  await _saveAndComplete(emailText, userName, contactName);
                  debugPrint('[Onboarding] Save: _saveAndComplete completed');
                  debugPrint('[Onboarding] Save button pressed - COMPLETE');
                } catch (e, stackTrace) {
                  debugPrint('[Onboarding] Save: ERROR - $e');
                  debugPrint('[Onboarding] Save: Stack trace: $stackTrace');
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fout bij opslaan: $e'),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(_localization.translate('save'), style: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _sendIntroductionEmail([StateSetter? setDialogState]) async {
    final emailText = _emailController.text.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(emailText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localization.translate('enter_valid_email')),
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }

    final userName = _userNameController.text.trim().isNotEmpty 
        ? _userNameController.text.trim() 
        : _localization.translate('name_placeholder');
    
    final contactName = _contactNameController.text.trim().isNotEmpty
        ? _contactNameController.text.trim()
        : emailText.split('@')[0]; // Use email prefix as fallback
    
    // Show loading indicator
    if (mounted && setDialogState != null) {
      setDialogState(() {
        // Show loading state
      });
    }

    // Get FCM token to include in email
    final fcmToken = await _fcmService.getToken();

    debugPrint('Attempting to send introduction email to: $emailText');
    final success = await _messagingService.sendIntroductionEmail(
      toEmail: emailText,
      contactName: contactName,
      userName: userName,
      fcmToken: fcmToken,
    );

    debugPrint('Introduction email send result: $success');

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localization.translate('intro_email_sent'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tip: Controleer ook de spam/ongewenste items map.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show user-friendly error message
        String errorMessage;
        if (emailText.toLowerCase() == 'resend@okerckhoff.nl') {
          errorMessage = 'E-mail verzenden mislukt. Controleer de Firebase logs of probeer het later opnieuw. Je kunt doorgaan in demo modus.';
        } else {
          errorMessage = 'E-mail verzenden mislukt. In Resend test-modus kun je alleen naar resend@okerckhoff.nl sturen. Gebruik dat adres om te testen, of verifieer je domein in Resend. Je kunt doorgaan in demo modus.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 8),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
    
    return success;
  }

  Future<void> _saveAndComplete(String emailText, String userName, String contactName) async {
    if (emailText.isEmpty) {
      // This should not happen as we check before calling this function
      debugPrint('_saveAndComplete: Email is empty, this should not happen');
      return;
    }

    // Betere email validatie met regex
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(emailText)) {
      // This should not happen as we check before calling this function
      debugPrint('_saveAndComplete: Email is invalid, this should not happen');
      return;
    }

    // Save user's own name
    if (userName.isNotEmpty) {
      await _storage.setUserName(userName);
    }

    // Save contact to emergency contacts list
    final finalContactName = contactName.isNotEmpty
        ? contactName
        : emailText.split('@')[0];
    
    final contacts = await _storage.getEmergencyContacts();
    
    // Check if contact with same email already exists and replace it
    final existingIndex = contacts.indexWhere((contact) => 
        contact['number']?.toLowerCase() == emailText.toLowerCase());
    
    if (existingIndex >= 0) {
      // Replace existing contact
      contacts[existingIndex] = {
        'number': emailText,
        'name': finalContactName,
      };
    } else {
      // Add new contact
      contacts.add({
        'number': emailText,
        'name': finalContactName,
      });
    }
    
    await _storage.setEmergencyContacts(contacts);
    
    // Also save as primary emergency contact for backwards compatibility
    await _storage.setEmergencyNumber(emailText);

    // Set default check time to 09:00
    await _storage.setCheckTime(const TimeOfDay(hour: 9, minute: 0));

    // Verify the save worked
    final saved = await _storage.getEmergencyNumber();
    if (saved != emailText) {
      // Retry save if it didn't work
      await _storage.setEmergencyNumber(emailText);
    }

    // Mark as onboarded
    debugPrint('[Onboarding] _saveAndComplete: Marking as onboarded');
    await _storage.setOnboarded(true);
    debugPrint('[Onboarding] _saveAndComplete: Onboarded marked');

    // Schedule first notification
    debugPrint('[Onboarding] _saveAndComplete: Scheduling notification');
    try {
      await NotificationService().scheduleNextCheckIn();
      debugPrint('[Onboarding] _saveAndComplete: Notification scheduled successfully');
    } catch (e, stackTrace) {
      debugPrint('[Onboarding] _saveAndComplete: Notification scheduling failed: $e');
      debugPrint('[Onboarding] _saveAndComplete: Notification stack trace: $stackTrace');
      // Continue anyway - don't let notification errors block onboarding
    }

    debugPrint('[Onboarding] _saveAndComplete: Starting navigation');
    
    if (!mounted) {
      debugPrint('_saveAndComplete: Not mounted, returning');
      return;
    }
    
    // Navigate immediately - dialog is already closed by caller
    if (widget.returnToPrevious) {
      debugPrint('_saveAndComplete: Returning to previous');
      if (mounted) {
        final rootNavigator = Navigator.of(context, rootNavigator: true);
        if (rootNavigator.canPop()) {
          rootNavigator.pop(true);
        }
      }
      return;
    }
    
    debugPrint('[Onboarding] _saveAndComplete: Navigating to HomeScreen');
    if (!mounted) {
      debugPrint('[Onboarding] _saveAndComplete: Not mounted, returning');
      return;
    }
    
    debugPrint('[Onboarding] _saveAndComplete: Getting root navigator');
    try {
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      debugPrint('[Onboarding] _saveAndComplete: Root navigator obtained, calling pushAndRemoveUntil');
      
      // Use pushAndRemoveUntil to clear entire navigation stack
      rootNavigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) {
          debugPrint('[Onboarding] _saveAndComplete: Route predicate called for: ${route.settings.name}');
          return false; // Remove all previous routes
        },
      );
      debugPrint('[Onboarding] _saveAndComplete: Navigation complete');
    } catch (e, stackTrace) {
      debugPrint('[Onboarding] _saveAndComplete: ERROR during navigation: $e');
      debugPrint('[Onboarding] _saveAndComplete: Stack trace: $stackTrace');
      // Fallback: try pushReplacement
      if (mounted) {
        try {
          debugPrint('[Onboarding] _saveAndComplete: Trying fallback navigation');
          final rootNavigator = Navigator.of(context, rootNavigator: true);
          rootNavigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          debugPrint('[Onboarding] _saveAndComplete: Fallback navigation succeeded');
        } catch (e2, stackTrace2) {
          debugPrint('[Onboarding] _saveAndComplete: Fallback navigation also failed: $e2');
          debugPrint('[Onboarding] _saveAndComplete: Fallback stack trace: $stackTrace2');
        }
      }
    }
  }

  Future<void> _saveContactWithoutEmail(String emailText) async {
    final contactName = _contactNameController.text.trim().isNotEmpty
        ? _contactNameController.text.trim()
        : emailText.split('@')[0];
    
    final contacts = await _storage.getEmergencyContacts();
    
    // Check if contact with same email already exists and replace it
    final existingIndex = contacts.indexWhere((contact) => 
        contact['number']?.toLowerCase() == emailText.toLowerCase());
    
    if (existingIndex >= 0) {
      // Replace existing contact
      contacts[existingIndex] = {
        'number': emailText,
        'name': contactName,
      };
    } else {
      // Add new contact
      contacts.add({
        'number': emailText,
        'name': contactName,
      });
    }
    
    await _storage.setEmergencyContacts(contacts);
    await _storage.setEmergencyNumber(emailText);
  }

  Future<void> _completeWithoutEmail() async {
    // Save user name if provided
    final userName = _userNameController.text.trim();
    if (userName.isNotEmpty) {
      await _storage.setUserName(userName);
      // Also save for next onboarding
      await _storage.setLastOnboardingUserName(userName);
    }
    
    // Set default check time
    await _storage.setCheckTime(const TimeOfDay(hour: 9, minute: 0));
    
    // Mark as onboarded
    debugPrint('[Onboarding] _completeWithoutEmail: Marking as onboarded');
    await _storage.setOnboarded(true);
    debugPrint('[Onboarding] _completeWithoutEmail: Onboarded marked');
    
    // Schedule first notification
    debugPrint('[Onboarding] _completeWithoutEmail: Scheduling notification');
    try {
      await NotificationService().scheduleNextCheckIn();
      debugPrint('[Onboarding] _completeWithoutEmail: Notification scheduled successfully');
    } catch (e, stackTrace) {
      debugPrint('[Onboarding] _completeWithoutEmail: Notification scheduling failed: $e');
      debugPrint('[Onboarding] _completeWithoutEmail: Notification stack trace: $stackTrace');
      // Continue anyway - don't let notification errors block onboarding
    }
    
    debugPrint('[Onboarding] _completeWithoutEmail: Starting navigation');
    
    if (!mounted) {
      debugPrint('_completeWithoutEmail: Not mounted, returning');
      return;
    }
    
    // Navigate immediately - dialog is already closed by caller
    if (widget.returnToPrevious) {
      debugPrint('_completeWithoutEmail: Returning to previous');
      if (mounted) {
        final rootNavigator = Navigator.of(context, rootNavigator: true);
        if (rootNavigator.canPop()) {
          rootNavigator.pop(true);
        }
      }
      return;
    }
    
    debugPrint('[Onboarding] _completeWithoutEmail: Navigating to HomeScreen');
    if (!mounted) {
      debugPrint('[Onboarding] _completeWithoutEmail: Not mounted, returning');
      return;
    }
    
    debugPrint('[Onboarding] _completeWithoutEmail: Getting root navigator');
    try {
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      debugPrint('[Onboarding] _completeWithoutEmail: Root navigator obtained, calling pushAndRemoveUntil');
      
      // Use pushAndRemoveUntil to clear entire navigation stack
      rootNavigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) {
          debugPrint('[Onboarding] _completeWithoutEmail: Route predicate called for: ${route.settings.name}');
          return false; // Remove all previous routes
        },
      );
      debugPrint('[Onboarding] _completeWithoutEmail: Navigation complete');
    } catch (e, stackTrace) {
      debugPrint('[Onboarding] _completeWithoutEmail: ERROR during navigation: $e');
      debugPrint('[Onboarding] _completeWithoutEmail: Stack trace: $stackTrace');
      // Fallback: try pushReplacement
      if (mounted) {
        try {
          debugPrint('[Onboarding] _completeWithoutEmail: Trying fallback navigation');
          final rootNavigator = Navigator.of(context, rootNavigator: true);
          rootNavigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          debugPrint('[Onboarding] _completeWithoutEmail: Fallback navigation succeeded');
        } catch (e2, stackTrace2) {
          debugPrint('[Onboarding] _completeWithoutEmail: Fallback navigation also failed: $e2');
          debugPrint('[Onboarding] _completeWithoutEmail: Fallback stack trace: $stackTrace2');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stap ${_currentPage + 1} van ${_pages.length}',
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_pages[_currentPage].isWelcome)
            TextButton(
              onPressed: () => _showHelp(),
              child: Text(
                _localization.translate('help'),
                style: const TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(_localization.translate('previous'), style: const TextStyle(fontSize: 20)),
                    )
                  else
                    const SizedBox(),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(120, 60),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 
                          ? _localization.translate('start')
                          : _localization.translate('next'),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.green[700]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.isWelcome) ...[
            // Logo/Icon for welcome screen - white background with green circle and OK
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ] else if (_currentPage == 0) ...[
            // "Zo werkt de app..." uitleg op eerste pagina (na welcome)
            Text(
              _localization.translate('how_app_works'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              _localization.translate('how_app_works_desc'),
              style: const TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            // Normale pagina's
            Text(
              _localization.translate('how_app_works'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Icon(
              page.icon,
              size: 120,
              color: Colors.green[700],
            ),
            const SizedBox(height: 40),
          ],
          Text(
            page.title,
            style: TextStyle(
              fontSize: page.isWelcome ? 36 : 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: TextStyle(
              fontSize: page.isWelcome ? 26 : 24,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final bool isWelcome;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.isWelcome = false,
  });
}
