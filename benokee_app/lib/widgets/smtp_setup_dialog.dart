import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../services/smtp_email_service.dart';
import '../services/storage_service.dart';

class SMTPSetupDialog extends StatefulWidget {
  final bool isRequired;
  
  const SMTPSetupDialog({
    super.key,
    this.isRequired = false,
  });

  @override
  State<SMTPSetupDialog> createState() => _SMTPSetupDialogState();
}

class _SMTPSetupDialogState extends State<SMTPSetupDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _localization = LocalizationService();
  final _smtpService = SMTPEmailService();
  final _storage = StorageService();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _smtpService.saveCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Mark that SMTP is configured
      await _storage.setSMTPConfigured(true);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail instellingen opgeslagen'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij opslaan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'E-mail instellingen',
        style: TextStyle(fontSize: 28),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voor automatisch e-mail versturen heb je je e-mailadres en wachtwoord nodig. Dit wordt veilig opgeslagen op je apparaat.',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mailadres',
                  hintText: 'voorbeeld@gmail.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 20),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Voer een e-mailadres in';
                  }
                  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Voer een geldig e-mailadres in';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Wachtwoord of App-wachtwoord',
                  hintText: 'Voor Gmail: gebruik App-wachtwoord',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showPassword,
                style: const TextStyle(fontSize: 20),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Voer een wachtwoord in';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gmail gebruikers:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '1. Zet 2-factor authenticatie aan\n'
                      '2. Maak een App-wachtwoord aan\n'
                      '3. Gebruik dit App-wachtwoord hier',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (!widget.isRequired)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Overslaan', style: TextStyle(fontSize: 20)),
          ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCredentials,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Opslaan', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
