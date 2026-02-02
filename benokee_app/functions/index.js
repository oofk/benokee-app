const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Resend } = require('resend');

// Initialize Firebase Admin
admin.initializeApp();

// Initialize Resend with API key from environment
// API Key is configured via: firebase functions:config:set resend.api_key="..."
// For now using fallback, but should be removed after config is set
const resend = new Resend(process.env.RESEND_API_KEY || functions.config().resend?.api_key || 're_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL');

/**
 * Send email via Resend API
 * Called from Flutter app
 */
exports.sendEmail = functions.https.onCall(async (data, context) => {
  // Optional: Add authentication check
  // if (!context.auth) {
  //   throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  // }

  const { to, subject, body, htmlBody } = data;

  // Validate input
  if (!to || !subject || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: to, subject, body'
    );
  }

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(to)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Invalid email address'
    );
  }

  try {
    // Use verified domain - okerckhoff.nl is now verified!
    const fromAddress = process.env.RESEND_FROM_ADDRESS || 'Benokee <noreply@okerckhoff.nl>';
    
    const result = await resend.emails.send({
      from: fromAddress,
      to: to,
      subject: subject,
      text: body,
      html: htmlBody || body.replace(/\n/g, '<br>'),
    });

    console.log('Resend API response:', JSON.stringify(result, null, 2));

    // Check if there's an error in the result
    if (result.error) {
      console.error('Resend API error detected:', JSON.stringify(result.error, null, 2));
      // Return a normal response so the client can show a friendly message.
      return {
        success: false,
        error: result.error.message,
        errorName: result.error.name,
        statusCode: result.error.statusCode,
      };
    }

    // Check if data exists
    if (!result.data || !result.data.id) {
      console.error('No email ID returned from Resend:', JSON.stringify(result, null, 2));
      return {
        success: false,
        error: 'Failed to send email: No email ID returned',
      };
    }

    console.log('Email sent successfully with ID:', result.data.id);
    return {
      success: true,
      id: result.data.id,
    };
  } catch (error) {
    console.error('Error sending email:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to send email: ' + error.message
    );
  }
});

/**
 * Send introduction email with app installation info
 */
exports.sendIntroductionEmail = functions.https.onCall(async (data, context) => {
  const { to, contactName, userName, fcmToken, playStoreLink, appStoreLink } = data;

  if (!to || !contactName || !userName) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields'
    );
  }

  // Generate deep link if FCM token is provided
  let deepLink = '';
  let qrCodeInfo = '';
  if (fcmToken) {
    deepLink = `benokee://contact?token=${encodeURIComponent(fcmToken)}&email=${encodeURIComponent(to)}`;
    qrCodeInfo = `\n\nOf scan de QR code in de bijlage om direct te koppelen.\nDeep link: ${deepLink}`;
  }

  const subject = 'Informatie over de Benokee app';
  const body = `Beste ${contactName},

Je bent toegevoegd als contactpersoon in de Benokee app van ${userName}.

Hoe werkt de app?

De Benokee app helpt ${userName} om regelmatig te laten weten dat alles goed gaat. Elke dag krijgt ${userName} een herinnering om in te loggen. Wanneer ${userName} op de grote "IK BEN OKÉ" knop drukt, weet je dat alles goed is.

Wat gebeurt er als er geen check-in is?

Als ${userName} 2 opeenvolgende dagen niet inlogt, krijg je automatisch een melding om te laten weten dat er mogelijk iets aan de hand is. Dit geeft je de mogelijkheid om contact op te nemen.

📱 Installeer de app voor directe meldingen

Je kunt de Benokee app ook installeren om direct meldingen te ontvangen op je telefoon, zonder e-mail te hoeven checken. Als contactpersoon zie je alleen de meldingen - je hoeft zelf niet in te checken.

Download de app:
• Android: ${playStoreLink || 'https://play.google.com/store/apps/details?id=com.benokee.app'}
• iOS: ${appStoreLink || 'https://apps.apple.com/app/benokee/id123456789'}
${qrCodeInfo}

Je hoeft niets te doen - de app werkt automatisch. Je krijgt alleen een melding als ${userName} 2 opeenvolgende dagen niet heeft ingelogd.

⚠️ Belangrijk: Controleer ook je spam/ongewenste items map, want e-mails kunnen daar terechtkomen.

Met vriendelijke groet,
De Benokee app`;

  try {
    // Use verified domain - okerckhoff.nl is now verified!
    const fromAddress = process.env.RESEND_FROM_ADDRESS || 'Benokee <noreply@okerckhoff.nl>';
    
    const result = await resend.emails.send({
      from: fromAddress,
      to: to,
      subject: subject,
      text: body,
      html: body.replace(/\n/g, '<br>'),
    });

    console.log('Resend API response for introduction email:', JSON.stringify(result, null, 2));

    // Check if there's an error in the result
    if (result.error) {
      console.error('Resend API error detected:', JSON.stringify(result.error, null, 2));
      // Return a normal response so the client can show a friendly message.
      return {
        success: false,
        error: result.error.message,
        errorName: result.error.name,
        statusCode: result.error.statusCode,
      };
    }

    // Check if data exists
    if (!result.data || !result.data.id) {
      console.error('No email ID returned from Resend:', JSON.stringify(result, null, 2));
      return {
        success: false,
        error: 'Failed to send email: No email ID returned',
      };
    }

    console.log('Introduction email sent successfully with ID:', result.data.id);
    return {
      success: true,
      id: result.data.id,
    };
  } catch (error) {
    console.error('Error sending introduction email:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to send email: ' + error.message
    );
  }
});
