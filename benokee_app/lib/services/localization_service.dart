class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  // Translations - alleen Nederlands
  static const Map<String, String> _translations = {
    // Welcome/Onboarding
    'welcome_title': 'Welkom bij Benokee',
    'welcome_desc': 'De app om te laten weten dat je oké bent',
    'what_is_benokee': 'Wat is Benokee?',
    'what_is_benokee_desc': 'Benokee is een eenvoudige app die je helpt om regelmatig te laten weten dat alles goed met je gaat. Perfect voor alleenstaanden of mensen die alleen wonen.',
    'how_app_works': 'Hoe werkt de app?',
    'how_app_works_desc': 'De app geeft je elke dag (instelbaar) een herinnering om te bevestigen dat alles goed gaat. Als je 2 dagen achter elkaar (instelbaar) niet bevestigt, stuurt de app automatisch een bericht naar je contactpersoon.',
    'why_benokee': 'Waarom Benokee?',
    'why_benokee_desc': 'Met Benokee hoef je je dierbaren niet elke dag te bellen of appen. Eén druk op de knop en je contactpersoon weet dat alles goed is. Alleen als je niet reageert, krijgen ze een melding.',
    'enter_your_name': 'Wat is je naam?',
    'enter_your_name_desc': 'Voer je eigen naam in. Deze wordt gebruikt in e-mails naar je contactpersonen.',
    'your_name': 'Je naam',
    'enter_contact': 'Voer contactgegevens in',
    'enter_contact_desc': 'Voer het email adres en (optioneel) de naam van je contactpersoon in.',
    'contact_name_optional': 'Naam contactpersoon (optioneel)',
    'contact_name_placeholder': 'Naam van contactpersoon',
    'choose_preference': 'Kies je voorkeur',
    'choose_preference_desc': 'Je kunt kiezen: elke check-in een "ik ben oké" email, of alleen een email als je 2 opeenvolgende dagen niet checkt.',
    'reminder_title': 'Elke dag een herinnering',
    'reminder_desc': 'De app stuurt je elke dag een herinnering om in te loggen.',
    'press_ok': 'Druk OK bij prompt',
    'press_ok_desc': 'Wanneer je een notificatie krijgt, druk op de grote OK knop in de app.',
    'missed_checkin_title': 'Wat gebeurt er als je niet inlogt?',
    'missed_checkin_desc': 'Als je 2 opeenvolgende dagen niet inlogt (instelbaar), krijgen je contactpersonen automatisch een e-mail om te laten weten dat er mogelijk iets aan de hand is.',
    'next': 'Volgende',
    'previous': 'Vorige',
    'start': 'Start',
    'back': 'Terug',
    'save': 'Opslaan',
    'cancel': 'Annuleren',
    'help': 'Help',
    'onboarding_help_general': 'Je kunt altijd teruggaan met de "Vorige" knop. Als je vragen hebt, bekijk de Help sectie in instellingen.',
    
    // Contact
    'emergency_contact': 'Contact',
    'contact': 'Contact',
    'contacts': 'Contacten',
    'contact_person': 'Contactpersoon',
    'email_address': 'Email adres',
    'email_placeholder': 'voorbeeld@email.com',
    'name_optional': 'Naam (optioneel)',
    'name_placeholder': 'Jouw naam',
    'enter_valid_email': 'Voer een geldig email adres in',
    'enter_email_address': 'Voer een email adres in',
    'send_intro_email': 'Verstuur introductie e-mail',
    'intro_email_sent': 'Introductie e-mail verstuurd!',
    'intro_email_failed': 'Kon e-mail niet openen. Controleer je e-mail app.',
    'intro_email_required': 'Verstuur eerst de introductie e-mail voordat je doorgaat.',
    'intro_email_optional': 'Je kunt de introductie e-mail later versturen via instellingen.',
    'skip': 'Overslaan',
    'demo_mode': 'Geen contactpersoon ingesteld',
    'demo_mode_desc': 'Voer een contactpersoon in zodat de app meldingen kan sturen als je niet reageert.',
    'no_contact_warning': 'Vul eerst een contactpersoon in',
    'no_contact_warning_desc': 'Je moet eerst een contactpersoon toevoegen voordat je kunt inchecken.',
    'add_contact_demo': 'Contactpersoon Toevoegen',
    
    // Home
    'i_am_ok': 'IK BEN\nOKÉ',
    'check_in_registered': 'Check-in geregistreerd!',
    'check_in_confirmation_message': 'Je check-in is geregistreerd! Je contactpersoon is op de hoogte.',
    'contact_notified': 'Je contactpersoon is op de hoogte gesteld.',
    'last_check_in': 'Laatste check-in',
    'no_check_in_yet': 'Nog geen check-in',
    'day': 'dag',
    'days': 'dagen',
    'hour': 'uur',
    'hours': 'uren',
    'minute': 'minuut',
    'minutes': 'minuten',
    'just_now': 'Zojuist',
    
    // Settings
    'settings': 'Instellingen',
    'emergency_contacts': 'Contacten',
    'no_contacts': 'Geen contacten',
    'add_contact': 'Contact toevoegen',
    'edit_contact': 'Contact bewerken',
    'delete_contact': 'Verwijderen',
    'contact_saved': 'Contact opgeslagen',
    'check_time': 'Check-tijd',
    'select_check_time': 'Selecteer check-in tijd',
    'check_interval': 'Check interval',
    'check_interval_desc': 'Het check interval bepaalt na hoeveel uren de app controleert of je hebt ingelogd. Standaard is dit 24 uur. Als je bijvoorbeeld 48 uur instelt, controleert de app elke 2 dagen of je hebt ingelogd. Als je 2 opeenvolgende keren niet inlogt, krijgen je contactpersonen een e-mail.',
    'grace_period': 'Grace periode',
    'reminder_interval': 'Herinnering interval',
    'reminder_interval_desc': 'Het herinnering interval bepaalt hoe vaak je een herinnering krijgt om in te loggen. Standaard is dit 1 uur. Als je bijvoorbeeld 2 uur instelt, krijg je elke 2 uur een herinnering totdat je inlogt.',
    'notification_text': 'Notificatie tekst',
    'email_mode': 'Email modus',
    'email_mode_always': 'Elke check-in een email',
    'email_mode_always_desc': 'Je contactpersoon krijgt elke keer een "ik ben oké" email',
    'email_mode_missed': 'Alleen bij gemiste check-in',
    'email_mode_missed_desc': 'Je contactpersoon krijgt alleen een email als je 2 opeenvolgende dagen niet checkt',
    'view_logs': 'Bekijk logs',
    'view_logs_desc': 'Laatste 10 check-ins',
    'hours_plural': 'uren',
    'default_hours': 'Uren (standaard: {value})',
    'text': 'Tekst',
    'text_size': 'Tekstgrootte',
    'text_size_small': 'Klein',
    'text_size_normal': 'Normaal',
    'text_size_large': 'Groot',
    'text_size_extra_large': 'Extra groot',
    'text_size_restart_message': 'Herstart de app om de tekstgrootte toe te passen',
    'haptic_feedback': 'Trilfeedback',
    'simple_mode': 'Eenvoudige modus',
    'enabled': 'Aan',
    'disabled': 'Uit',
    'redo_introduction': 'Introductie opnieuw doen',
    'redo_introduction_desc': 'Herhaal de introductie met je huidige gegevens',
    'exit_warning_title': 'App sluiten?',
    'exit_warning_message': 'Als je de app sluit, krijg je geen herinneringen meer. De app moet op de achtergrond blijven draaien om je te herinneren aan je check-in.',
    'exit_anyway': 'Toch sluiten',
    'keep_running': 'App open houden',
    'help_support': 'Help en ondersteuning',
    'help_support_desc': 'Veelgestelde vragen en contact',
    
    // Email
    'intro_email_subject': 'Informatie over de Benokee app',
    'intro_email_body': 'Beste {name},\n\nJe bent toegevoegd als contactpersoon in de Benokee app van {userName}.\n\nHoe werkt de app?\n\nDe Benokee app helpt {userName} om regelmatig te laten weten dat alles goed gaat. Elke dag krijgt {userName} een herinnering om in te loggen. Wanneer {userName} op de grote "IK BEN OKÉ" knop drukt, weet je dat alles goed is.\n\nWat gebeurt er als er geen check-in is?\n\nAls {userName} 2 opeenvolgende dagen niet inlogt, krijg je automatisch een e-mail om te laten weten dat er mogelijk iets aan de hand is. Dit geeft je de mogelijkheid om contact op te nemen.\n\n📱 Installeer de app voor directe meldingen\n\nJe kunt de Benokee app ook installeren om direct meldingen te ontvangen op je telefoon, zonder e-mail te hoeven checken. Als contactpersoon zie je alleen de meldingen - je hoeft zelf niet in te checken.\n\nDownload de app:\n• Android: {playStoreLink}\n• iOS: {appStoreLink}\n\n{qrCodeInfo}\n\nJe hoeft niets te doen - de app werkt automatisch. Je krijgt alleen een melding als {userName} 2 opeenvolgende dagen niet heeft ingelogd.\n\nMet vriendelijke groet,\nDe Benokee app',
    
    // User Role
    'select_role': 'Wat ben je?',
    'select_role_desc': 'Kies of je de app gebruikt om in te checken, of als contactpersoon om meldingen te ontvangen.',
    'role_user': 'Ik gebruik de app om in te checken',
    'role_user_desc': 'Je krijgt herinneringen en drukt op de "IK BEN OKÉ" knop',
    'role_contact': 'Ik ben een contactpersoon',
    'role_contact_desc': 'Je ontvangt alleen meldingen, je hoeft zelf niet in te checken',
    
    // QR Code
    'qr_code_title': 'QR Code voor app installatie',
    'qr_code_desc': 'Scan deze QR code met je telefoon om de app te installeren en direct te koppelen',
    'install_app': 'Installeer de app',
    'app_install_info': 'Installeer de Benokee app om direct meldingen te ontvangen op je telefoon',
  };

  Future<void> init() async {
    // Geen taal-selectie meer nodig, altijd Nederlands
  }

  String translate(String key, {Map<String, String>? params}) {
    final translation = _translations[key] ?? key;
    
    if (params != null) {
      String result = translation;
      params.forEach((key, value) {
        result = result.replaceAll('{$key}', value);
      });
      return result;
    }
    
    return translation;
  }

  // Shortcut method
  static String t(String key, {Map<String, String>? params}) {
    return LocalizationService().translate(key, params: params);
  }
}
