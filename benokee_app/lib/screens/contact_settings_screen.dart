import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/localization_service.dart';
import '../screens/contact_onboarding_screen.dart';
import '../screens/role_selection_screen.dart';

class ContactSettingsScreen extends StatefulWidget {
  const ContactSettingsScreen({super.key});

  @override
  State<ContactSettingsScreen> createState() => _ContactSettingsScreenState();
}

class _ContactSettingsScreenState extends State<ContactSettingsScreen> {
  final StorageService _storage = StorageService();
  final LocalizationService _localization = LocalizationService();
  
  bool _notificationSound = true;
  bool _notificationVibration = true;
  String _textSize = 'normal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sound = await _storage.getContactNotificationSound();
    final vibration = await _storage.getContactNotificationVibration();
    final textSize = await _storage.getTextSize();
    
    setState(() {
      _notificationSound = sound;
      _notificationVibration = vibration;
      _textSize = textSize;
    });
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, size: 32, color: Colors.blue[700]),
      title: Text(title, style: const TextStyle(fontSize: 24)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 20)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Notification settings
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Meldingen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Geluid', style: TextStyle(fontSize: 24)),
            subtitle: const Text('Speel geluid af bij meldingen', style: TextStyle(fontSize: 20)),
            value: _notificationSound,
            onChanged: (value) async {
              setState(() {
                _notificationSound = value;
              });
              await _storage.setContactNotificationSound(value);
            },
            secondary: Icon(Icons.volume_up, size: 32, color: Colors.blue[700]),
          ),
          SwitchListTile(
            title: const Text('Trilling', style: TextStyle(fontSize: 24)),
            subtitle: const Text('Tril bij meldingen', style: TextStyle(fontSize: 20)),
            value: _notificationVibration,
            onChanged: (value) async {
              setState(() {
                _notificationVibration = value;
              });
              await _storage.setContactNotificationVibration(value);
            },
            secondary: Icon(Icons.vibration, size: 32, color: Colors.blue[700]),
          ),
          const Divider(),
          
          // Text size
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Weergave',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          _buildSettingTile(
            'Tekst grootte',
            _textSize == 'small' ? 'Klein' : 
            _textSize == 'large' ? 'Groot' : 
            _textSize == 'extra_large' ? 'Extra groot' : 'Normaal',
            Icons.text_fields,
            () async {
              final sizes = ['small', 'normal', 'large', 'extra_large'];
              final labels = ['Klein', 'Normaal', 'Groot', 'Extra groot'];
              final currentIndex = sizes.indexOf(_textSize);
              
              final newIndex = await showDialog<int>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Tekst grootte'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: sizes.asMap().entries.map((entry) {
                      return RadioListTile<int>(
                        title: Text(labels[entry.key]),
                        value: entry.key,
                        groupValue: currentIndex,
                        onChanged: (value) => Navigator.pop(context, value),
                      );
                    }).toList(),
                  ),
                ),
              );
              
              if (newIndex != null && newIndex != currentIndex) {
                setState(() {
                  _textSize = sizes[newIndex];
                });
                await _storage.setTextSize(_textSize);
              }
            },
          ),
          const Divider(),
          
          // Account
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          _buildSettingTile(
            'Introductie opnieuw doen',
            'Doorloop de onboarding opnieuw',
            Icons.refresh,
            () async {
              await _storage.setOnboarded(false);
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
