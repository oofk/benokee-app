import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('help_support'), style: const TextStyle(fontSize: 28)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Hoe werkt de app?',
            'De Benokee app helpt je om regelmatig te laten weten dat alles goed gaat. Wanneer je op de grote "IK BEN OKÉ" knop drukt, weten je contactpersonen dat alles goed is.',
            Icons.info,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Wat gebeurt er als ik niet inlog?',
            'Als je 2 opeenvolgende dagen niet inlogt (instelbaar), krijgen je contactpersonen automatisch een e-mail om te laten weten dat er mogelijk iets aan de hand is. Dit geeft hen de mogelijkheid om contact met je op te nemen.',
            Icons.warning,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Hoe voeg ik een contact toe?',
            'Ga naar Instellingen > Contacten en klik op "Contact toevoegen". Voer het e-mailadres in en gebruik de knop "Verstuur introductie e-mail" om je contactpersoon te informeren over de app.',
            Icons.person_add,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Kan ik de tekstgrootte aanpassen?',
            'Ja! Ga naar Instellingen > Tekstgrootte en kies uit Klein, Normaal, Groot of Extra groot. Je moet de app herstarten om de wijzigingen toe te passen.',
            Icons.text_fields,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Hoe werkt e-mail modus?',
            'Je kunt kiezen tussen twee modi:\n• Elke check-in een e-mail: Je contactpersoon krijgt elke keer een "ik ben oké" e-mail\n• Alleen bij gemiste check-in: Je contactpersoon krijgt alleen een e-mail als je 2 opeenvolgende dagen niet inlogt',
            Icons.email,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Wat is check interval?',
            'Het check interval bepaalt na hoeveel uren de app controleert of je hebt ingelogd. Standaard is dit 24 uur. Als je bijvoorbeeld 48 uur instelt, controleert de app elke 2 dagen of je hebt ingelogd. Als je 2 opeenvolgende keren niet inlogt, krijgen je contactpersonen een e-mail.',
            Icons.timer,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Wat is herinnering interval?',
            'Het herinnering interval bepaalt hoe vaak je een herinnering krijgt om in te loggen. Standaard is dit 1 uur. Als je bijvoorbeeld 2 uur instelt, krijg je elke 2 uur een herinnering totdat je inlogt.',
            Icons.notifications_active,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Hoe stel ik de check-tijd in?',
            'Ga naar Instellingen > Check-tijd. Kies het tijdstip waarop je dagelijks een herinnering wilt ontvangen. Je kunt dit aanpassen naar je eigen voorkeur, bijvoorbeeld 09:00 in de ochtend.',
            Icons.access_time,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Kan ik meerdere contactpersonen toevoegen?',
            'Ja! Je kunt meerdere contactpersonen toevoegen. Ga naar Instellingen > Contacten en klik op "Contact toevoegen". Alle contactpersonen krijgen een e-mail als je 2 opeenvolgende dagen niet inlogt.',
            Icons.people,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Wat gebeurt er als ik de introductie opnieuw doe?',
            'Als je de introductie opnieuw doet, kun je je gegevens aanpassen. Je bestaande naam, e-mail en contactgegevens worden vooringevuld, maar je kunt ze aanpassen. Na het opslaan ga je terug naar het "ik ben oké" scherm.',
            Icons.refresh,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Hoe werkt trilfeedback?',
            'Trilfeedback geeft een lichte trilling wanneer je op knoppen drukt. Dit helpt om te bevestigen dat je actie is geregistreerd. Je kunt dit aan of uit zetten in Instellingen > Trilfeedback.',
            Icons.vibration,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Kan ik mijn check-in geschiedenis bekijken?',
            'Ja! Ga naar Instellingen > Bekijk logs om je laatste 10 check-ins te zien. Hier zie je wanneer je voor het laatst hebt ingelogd en hoe vaak je de app gebruikt.',
            Icons.history,
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_support, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Hulp nodig?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Voor technische ondersteuning of vragen, neem contact op via de app store of de ontwikkelaar.',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
