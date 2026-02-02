import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/localization_service.dart';
import '../services/hybrid_messaging_service.dart';
import '../services/fcm_service.dart';
import '../services/pairing_service.dart';
import 'logs_screen.dart';
import 'help_screen.dart';
import 'onboarding_screen.dart';
import 'role_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool openContactsDirectly;
  
  const SettingsScreen({super.key, this.openContactsDirectly = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  final NotificationService _notificationService = NotificationService();
  final LocalizationService _localization = LocalizationService();
  final HybridMessagingService _messagingService = HybridMessagingService();
  final FCMService _fcmService = FCMService();

  TimeOfDay? _checkTime;
  int? _checkInterval;
  int? _reminderInterval;
  String? _notificationText;
  List<Map<String, dynamic>> _emergencyContacts = [];
  String? _emergencyNumber;
  String? _emailMode;
  String _textSize = 'normal';
  bool _hapticFeedback = true;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
    
    // If openContactsDirectly is true, open contact management after first frame
    if (widget.openContactsDirectly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _editEmergencyContacts();
      });
    }
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Future<void> _loadSettings() async {
    final checkTime = await _storage.getCheckTime();
    final checkInterval = await _storage.getCheckInterval();
    final reminderInterval = await _storage.getReminderInterval();
    final notificationText = await _storage.getNotificationText();
    final contacts = await _storage.getEmergencyContacts();
    final emergencyNumber = await _storage.getEmergencyNumber();
    final emailMode = await _storage.getEmailMode();
    final textSize = await _storage.getTextSize();
    final hapticFeedback = await _storage.getHapticFeedbackEnabled();

    setState(() {
      _checkTime = checkTime;
      _checkInterval = checkInterval;
      _reminderInterval = reminderInterval;
      _notificationText = notificationText;
      _emergencyContacts = contacts;
      _emergencyNumber = emergencyNumber;
      _emailMode = emailMode;
      _textSize = textSize;
      _hapticFeedback = hapticFeedback;
    });
  }

  Future<void> _selectCheckTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _checkTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: _localization.translate('select_check_time'),
      cancelText: _localization.translate('cancel'),
      confirmText: _localization.translate('save'),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time != null) {
      await _storage.setCheckTime(time);
      await _notificationService.rescheduleNotifications();
      setState(() {
        _checkTime = time;
      });
    }
  }

  Future<void> _editEmergencyContacts() async {
    // Show contact management screen
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ContactsManagementScreen(
          contacts: List.from(_emergencyContacts),
          onContactsUpdated: (contacts) async {
            await _storage.setEmergencyContacts(contacts);
            // Clear emergency number if no contacts left
            if (contacts.isEmpty) {
              await _storage.setEmergencyNumber('');
            } else {
              // Set first contact as primary emergency number for backwards compatibility
              await _storage.setEmergencyNumber(contacts[0]['number'] ?? '');
            }
            setState(() {
              _emergencyContacts = contacts;
              _emergencyNumber = contacts.isNotEmpty ? contacts[0]['number'] : null;
            });
            // Return true to indicate contacts changed (for demo mode check)
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          },
        ),
      ),
    );
    await _loadSettings(); // Reload to refresh display
  }

  Future<void> _editCheckInterval() async {
    final controller = TextEditingController(
      text: _checkInterval?.toString() ?? '48',
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localization.translate('check_interval'), style: const TextStyle(fontSize: 28)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _localization.translate('check_interval_desc'),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: _localization.translate('default_hours', params: {'value': '24'}),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_localization.translate('cancel'), style: const TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: Text(_localization.translate('save'), style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (result != null) {
      await _storage.setCheckInterval(result);
      await _notificationService.rescheduleNotifications();
      setState(() {
        _checkInterval = result;
      });
    }
  }


  Future<void> _editReminderInterval() async {
    final controller = TextEditingController(
      text: _reminderInterval?.toString() ?? '1',
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localization.translate('reminder_interval'), style: const TextStyle(fontSize: 28)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _localization.translate('reminder_interval_desc'),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: _localization.translate('default_hours', params: {'value': '1'}),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_localization.translate('cancel'), style: const TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: Text(_localization.translate('save'), style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (result != null) {
      await _storage.setReminderInterval(result);
      setState(() {
        _reminderInterval = result;
      });
    }
  }

  Future<void> _editEmailMode() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localization.translate('email_mode'), style: const TextStyle(fontSize: 28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(_localization.translate('email_mode_always'), style: const TextStyle(fontSize: 20)),
              subtitle: Text(_localization.translate('email_mode_always_desc'), style: const TextStyle(fontSize: 16)),
              value: 'always',
              groupValue: _emailMode ?? 'only_missed',
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            ),
            RadioListTile<String>(
              title: Text(_localization.translate('email_mode_missed'), style: const TextStyle(fontSize: 20)),
              subtitle: Text(_localization.translate('email_mode_missed_desc'), style: const TextStyle(fontSize: 16)),
              value: 'only_missed',
              groupValue: _emailMode ?? 'only_missed',
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_localization.translate('cancel'), style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (result != null) {
      await _storage.setEmailMode(result);
      setState(() {
        _emailMode = result;
      });
    }
  }

  Future<void> _editNotificationText() async {
    final controller = TextEditingController(
      text: _notificationText ?? 'Ik ben oké',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localization.translate('notification_text'), style: const TextStyle(fontSize: 28)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: _localization.translate('text'),
            border: const OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 24),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_localization.translate('cancel'), style: const TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: Text(_localization.translate('save'), style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (result != null) {
      await _storage.setNotificationText(result);
      setState(() {
        _notificationText = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localization.translate('settings'), style: const TextStyle(fontSize: 28)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Essential settings (always visible)
          _buildSettingTile(
            _localization.translate('emergency_contacts'),
            _emergencyContacts.isNotEmpty
                ? '${_emergencyContacts.length} ${_emergencyContacts.length == 1 ? _localization.translate('emergency_contact') : _localization.translate('emergency_contacts')}'
                : _localization.translate('no_contacts'),
            Icons.email,
            _editEmergencyContacts,
          ),
          const Divider(),
          _buildSettingTile(
            _localization.translate('check_time'),
            _checkTime != null
                ? '${_checkTime!.hour.toString().padLeft(2, '0')}:${_checkTime!.minute.toString().padLeft(2, '0')}'
                : '09:00',
            Icons.access_time,
            _selectCheckTime,
          ),
          const Divider(),
          _buildSettingTile(
            _localization.translate('email_mode'),
            _emailMode == 'always' 
                ? _localization.translate('email_mode_always')
                : _localization.translate('email_mode_missed'),
            Icons.email,
            _editEmailMode,
          ),
          const Divider(),
          // Advanced settings
            _buildSettingTile(
              _localization.translate('check_interval'),
              '${_checkInterval ?? 24} ${_localization.translate('hours_plural')}',
              Icons.timer,
              _editCheckInterval,
            ),
            const Divider(),
            _buildSettingTile(
              _localization.translate('reminder_interval'),
              '${_reminderInterval ?? 1} ${_localization.translate('hours_plural')}',
              Icons.notifications_active,
              _editReminderInterval,
            ),
            const Divider(),
            _buildSettingTile(
              _localization.translate('notification_text'),
              _notificationText ?? _localization.translate('i_am_ok').replaceAll('\n', ' '),
              Icons.text_fields,
              _editNotificationText,
            ),
            const Divider(),
          // Accessibility settings (moved before redo introduction)
          _buildSettingTile(
            _localization.translate('text_size'),
            _getTextSizeLabel(_textSize),
            Icons.text_fields,
            _editTextSize,
          ),
          const Divider(),
          _buildSettingTile(
            _localization.translate('haptic_feedback'),
            _hapticFeedback ? _localization.translate('enabled') : _localization.translate('disabled'),
            Icons.vibration,
            _toggleHapticFeedback,
          ),
          const Divider(),
          // Re-do introduction
          _buildSettingTile(
            _localization.translate('redo_introduction'),
            _localization.translate('redo_introduction_desc'),
            Icons.refresh,
            _redoIntroduction,
          ),
          const Divider(),
          // Help and logs
          _buildSettingTile(
            _localization.translate('help_support'),
            _localization.translate('help_support_desc'),
            Icons.help,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              );
            },
          ),
          const Divider(),
          _buildSettingTile(
            _localization.translate('view_logs'),
            _localization.translate('view_logs_desc'),
            Icons.history,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LogsScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          // App version
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Benokee v$_appVersion',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTextSizeLabel(String size) {
    switch (size) {
      case 'small':
        return _localization.translate('text_size_small');
      case 'large':
        return _localization.translate('text_size_large');
      case 'extra_large':
        return _localization.translate('text_size_extra_large');
      default:
        return _localization.translate('text_size_normal');
    }
  }

  Future<void> _editTextSize() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localization.translate('text_size'), style: const TextStyle(fontSize: 28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(_localization.translate('text_size_small'), style: const TextStyle(fontSize: 20)),
              value: 'small',
              groupValue: _textSize,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: Text(_localization.translate('text_size_normal'), style: const TextStyle(fontSize: 20)),
              value: 'normal',
              groupValue: _textSize,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: Text(_localization.translate('text_size_large'), style: const TextStyle(fontSize: 20)),
              value: 'large',
              groupValue: _textSize,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: Text(_localization.translate('text_size_extra_large'), style: const TextStyle(fontSize: 20)),
              value: 'extra_large',
              groupValue: _textSize,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_localization.translate('cancel'), style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (result != null) {
      await _storage.setTextSize(result);
      setState(() {
        _textSize = result;
      });
      // Restart app to apply text size changes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localization.translate('text_size_restart_message')),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleHapticFeedback() async {
    final newValue = !_hapticFeedback;
    await _storage.setHapticFeedbackEnabled(newValue);
    setState(() {
      _hapticFeedback = newValue;
    });
  }


  Future<void> _redoIntroduction() async {
    // Reset onboarding status to go back to role selection
    await _storage.setOnboarded(false);
    
    // Navigate back to role selection screen (first screen)
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const RoleSelectionScreen(),
        ),
        (route) => false, // Remove all previous routes
      );
    }
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, size: 32, color: Colors.green[700]),
      title: Text(title, style: const TextStyle(fontSize: 24)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 20)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }
}

// Contacts Management Screen
class _ContactsManagementScreen extends StatefulWidget {
  final List<Map<String, dynamic>> contacts;
  final Function(List<Map<String, dynamic>>) onContactsUpdated;

  const _ContactsManagementScreen({
    required this.contacts,
    required this.onContactsUpdated,
  });

  @override
  State<_ContactsManagementScreen> createState() => _ContactsManagementScreenState();
}

class _ContactsManagementScreenState extends State<_ContactsManagementScreen> {
  final LocalizationService _localization = LocalizationService();
  final HybridMessagingService _messagingService = HybridMessagingService();
  final FCMService _fcmService = FCMService();
  final PairingService _pairingService = PairingService();
  late List<Map<String, dynamic>> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = List.from(widget.contacts);
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _addContact() async {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    bool isEmailValid = false;
    bool introEmailSent = false;
    bool contactUsesApp = false;
    String? pairingCode;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            _localization.translate('add_contact'),
            style: const TextStyle(fontSize: 28),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  onChanged: (value) {
                    setDialogState(() {
                      isEmailValid = _validateEmail(value);
                      introEmailSent = false; // Reset when email changes
                    });
                  },
                  decoration: InputDecoration(
                    labelText: _localization.translate('email_address'),
                    hintText: _localization.translate('email_placeholder'),
                    border: const OutlineInputBorder(),
                    suffixIcon: isEmailValid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : emailController.text.isNotEmpty
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: _localization.translate('name_optional'),
                    hintText: _localization.translate('name_placeholder'),
                    border: const OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                // Checkbox: Contact uses Benokee app
                CheckboxListTile(
                  title: const Text(
                    'Mijn contactpersoon gebruikt de Benokee app',
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: const Text(
                    'Genereer een koppelcode die je contactpersoon kan invoeren',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: contactUsesApp,
                  onChanged: (value) {
                    setDialogState(() {
                      contactUsesApp = value ?? false;
                      if (contactUsesApp && isEmailValid) {
                        // Generate pairing code
                        _pairingService.generatePairingCode(emailController.text.trim()).then((code) {
                          setDialogState(() {
                            pairingCode = code;
                          });
                        });
                      } else {
                        pairingCode = null;
                      }
                    });
                  },
                ),
                if (contactUsesApp && pairingCode != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Koppelcode voor je contactpersoon:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pairingCode!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Deel deze code met je contactpersoon. Zij kunnen deze code invoeren tijdens de onboarding.',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final emailText = emailController.text.trim();
                      if (!isEmailValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_localization.translate('enter_valid_email')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // Send introduction email (required)
                      final userName = await StorageService().getUserName() ?? 
                                      _localization.translate('name_placeholder');
                      final contactName = nameController.text.trim().isNotEmpty
                          ? nameController.text.trim()
                          : emailText.split('@')[0];

                      // Get FCM token to include in email
                      final fcmToken = await _fcmService.getToken();

                      final emailSent = await _messagingService.sendIntroductionEmail(
                        toEmail: emailText,
                        contactName: contactName,
                        userName: userName,
                        fcmToken: fcmToken,
                      );

                      setDialogState(() {
                        introEmailSent = emailSent;
                      });

                      if (mounted) {
                        if (emailSent) {
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
                            errorMessage = 'E-mail verzenden mislukt. Controleer de Firebase logs of probeer het later opnieuw.';
                          } else {
                            errorMessage = 'E-mail verzenden mislukt. In Resend test-modus kun je alleen naar resend@okerckhoff.nl sturen. Gebruik dat adres om te testen, of verifieer je domein in Resend.';
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
                if (!introEmailSent && isEmailValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _localization.translate('intro_email_required'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_localization.translate('cancel'), style: const TextStyle(fontSize: 20)),
            ),
            ElevatedButton(
              onPressed: (introEmailSent || contactUsesApp) ? () {
                final emailText = emailController.text.trim();
                final contactName = nameController.text.trim().isNotEmpty
                    ? nameController.text.trim()
                    : emailText.split('@')[0];
                final result = <String, dynamic>{
                  'number': emailText,
                  'name': contactName,
                };
                if (contactUsesApp && pairingCode != null) {
                  result['hasApp'] = true;
                  result['pairingCode'] = pairingCode!;
                }
                Navigator.pop(context, result);
              } : null,
              child: Text(_localization.translate('save'), style: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        // Check if contact with same email already exists and replace it
        final emailText = result['number']?.toLowerCase() ?? '';
        final existingIndex = _contacts.indexWhere((contact) => 
            contact['number']?.toLowerCase() == emailText);
        
        if (existingIndex >= 0) {
          // Replace existing contact
          _contacts[existingIndex] = result;
        } else {
          // Add new contact
          _contacts.add(result);
        }
      });
      await widget.onContactsUpdated(_contacts);
      
      // Show feedback that contact was saved
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_localization.translate('contact_saved')),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editContact(int index) async {
    final contact = _contacts[index];
    final emailController = TextEditingController(text: contact['number'] ?? '');
    final nameController = TextEditingController(text: contact['name'] ?? '');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _localization.translate('edit_contact'),
          style: const TextStyle(fontSize: 28),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: _localization.translate('email_address'),
                  hintText: _localization.translate('email_placeholder'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: _localization.translate('name_optional'),
                  hintText: _localization.translate('name_placeholder'),
                  border: const OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_localization.translate('cancel'), style: const TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () {
              final emailText = emailController.text.trim();
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
              final contactName = nameController.text.trim().isNotEmpty
                  ? nameController.text.trim()
                  : emailText.split('@')[0];
              Navigator.pop(context, {
                'number': emailText,
                'name': contactName,
              });
            },
            child: Text(_localization.translate('save'), style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        final emailText = (result['number'] as String?)?.toLowerCase() ?? '';
        final oldEmail = (_contacts[index]['number'] as String?)?.toLowerCase() ?? '';
        
        // Check if email changed and if new email already exists
        if (emailText != oldEmail) {
          final existingIndex = _contacts.indexWhere((contact) => 
              (contact['number'] as String?)?.toLowerCase() == emailText && 
              _contacts.indexOf(contact) != index);
          
          if (existingIndex >= 0) {
            // Email already exists in another contact, replace that one and remove current
            _contacts[existingIndex] = result;
            _contacts.removeAt(index);
          } else {
            // Just update the contact
            _contacts[index] = result;
          }
        } else {
          // Email didn't change, just update the contact
          _contacts[index] = result;
        }
      });
      widget.onContactsUpdated(_contacts);
    }
  }

  void _deleteContact(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localization.translate('delete_contact')),
        content: Text('${_localization.translate('delete_contact')} ${_contacts[index]['name'] ?? _contacts[index]['number']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_localization.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _contacts.removeAt(index);
              });
              widget.onContactsUpdated(_contacts);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(_localization.translate('delete_contact')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localization.translate('emergency_contacts'), style: const TextStyle(fontSize: 28)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _contacts.length + 1,
        itemBuilder: (context, index) {
          if (index == _contacts.length) {
            // Add contact button
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _addContact,
                icon: const Icon(Icons.add),
                label: Text(_localization.translate('add_contact')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            );
          }

          final contact = _contacts[index];
          final contactEmail = contact['number'] as String? ?? '';
          final hasApp = contact['hasApp'] == true;
          final pairingCode = contact['pairingCode'] as String?;
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              leading: Icon(
                hasApp ? Icons.phone_android : Icons.email,
                size: 32,
                color: hasApp ? Colors.blue : Colors.green,
              ),
              title: Text(
                contact['name'] ?? contactEmail,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contactEmail,
                    style: const TextStyle(fontSize: 20),
                  ),
                  if (hasApp && pairingCode != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.vpn_key, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Code: $pairingCode',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editContact(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteContact(index),
                  ),
                ],
              ),
              children: [
                if (hasApp && pairingCode != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Je contactpersoon gebruikt de Benokee app',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Deel deze code met je contactpersoon. Zij kunnen deze code invoeren tijdens de onboarding om automatisch gekoppeld te worden.',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
