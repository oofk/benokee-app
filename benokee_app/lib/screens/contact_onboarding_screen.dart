import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/localization_service.dart';
import '../services/fcm_service.dart';
import '../services/pairing_service.dart';
import 'contact_home_screen.dart';

class ContactOnboardingScreen extends StatefulWidget {
  const ContactOnboardingScreen({super.key});

  @override
  State<ContactOnboardingScreen> createState() => _ContactOnboardingScreenState();
}

class _ContactOnboardingScreenState extends State<ContactOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final StorageService _storage = StorageService();
  final LocalizationService _localization = LocalizationService();
  final FCMService _fcmService = FCMService();
  final PairingService _pairingService = PairingService();

  final TextEditingController _codeController = TextEditingController();
  bool _codeEntered = false;
  String? _codeError;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welkom als contactpersoon',
      'description': 'Je ontvangt meldingen wanneer de gebruiker niet heeft ingecheckt.',
    },
    {
      'title': 'Hoe werkt het?',
      'description': 'Je krijgt automatisch een melding als de gebruiker 2 opeenvolgende dagen niet heeft ingecheckt.',
    },
    {
      'title': 'Koppelcode invoeren',
      'description': 'Voer de 6-cijferige code in die je van de gebruiker hebt gekregen om automatisch gekoppeld te worden.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
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

  Future<void> _validateCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() {
        _codeError = 'Voer een 6-cijferige code in';
      });
      return;
    }

    // Validate code format
    if (!code.contains(RegExp(r'^[0-9]+$'))) {
      setState(() {
        _codeError = 'Code moet alleen cijfers bevatten';
      });
      return;
    }

    // Get contact email (we'll use a placeholder for now)
    // In production, this would be done via Firebase Functions
    final contactEmail = await _storage.getEmergencyNumber() ?? 'contact@example.com';
    
    // Validate code
    final isValid = await _pairingService.validateCode(code, contactEmail);
    if (isValid) {
      setState(() {
        _codeEntered = true;
        _codeError = null;
      });
      // Continue to completion
      await _completeOnboarding();
    } else {
      setState(() {
        _codeError = 'Code niet gevonden. Controleer de code en probeer opnieuw.';
      });
    }
  }

  Future<void> _completeOnboarding() async {
    // Initialize FCM to get token
    await _fcmService.initialize();
    
    // Mark as onboarded
    await _storage.setOnboarded(true);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ContactHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / _pages.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
            ),
            
            // Page content
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
                  final page = _pages[index];
                  final isCodePage = index == 2; // Code entry page
                  
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          page['title']!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (isCodePage) ...[
                          Text(
                            page['description']!,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _codeController,
                            maxLength: 6,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                            decoration: InputDecoration(
                              hintText: '000000',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _codeError,
                              counterText: '',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _codeError = null;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Je kunt deze stap overslaan als je geen code hebt',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else
                          Text(
                            page['description']!,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(
                        _localization.translate('previous'),
                        style: const TextStyle(fontSize: 20),
                      ),
                    )
                  else
                    const SizedBox(),
                  if (_currentPage == 2) ...[
                    ElevatedButton(
                      onPressed: _codeController.text.length == 6 && !_codeEntered
                          ? _validateCode
                          : null,
                      child: const Text(
                        'Code valideren',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text(
                        'Overslaan',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ] else
                    ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? _localization.translate('next')
                            : _localization.translate('start'),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
