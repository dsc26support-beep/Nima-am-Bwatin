import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';

import '../models/caregiver.dart';

enum CaregiverChannel { email, whatsapp, messenger }

/// Opens the caregiver's email/WhatsApp/Messenger with a reminder message
/// ready to send. None of these can be sent silently in the background --
/// that would require a server plus (for WhatsApp/Messenger) Meta's
/// business APIs, which this local-only app deliberately doesn't have --
/// so each of these still needs a person to tap send once the relevant app
/// opens.
///
/// Email and WhatsApp both support addressing a specific person *and*
/// pre-filling the message text. Messenger's public deep link
/// (`m.me/<username>`) can open a chat with a specific person, but Meta does
/// not allow pre-filling message text for regular (non-bot) chats -- so for
/// Messenger the message is copied to the clipboard instead, ready to paste.
class CaregiverAlertService {
  CaregiverAlertService._();

  static Future<bool> send(Caregiver caregiver, CaregiverChannel channel, String message) async {
    switch (channel) {
      case CaregiverChannel.email:
        return _sendEmail(caregiver, message);
      case CaregiverChannel.whatsapp:
        return _sendWhatsApp(caregiver, message);
      case CaregiverChannel.messenger:
        return _openMessenger(caregiver, message);
    }
  }

  static Future<bool> _sendEmail(Caregiver caregiver, String message) async {
    final email = caregiver.email;
    if (email == null || email.isEmpty) return false;
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent('Medication reminder')}'
          '&body=${Uri.encodeComponent(message)}',
    );
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _sendWhatsApp(Caregiver caregiver, String message) async {
    final number = caregiver.whatsappNumber?.replaceAll(RegExp(r'[^0-9]'), '');
    if (number == null || number.isEmpty) return false;
    final uri = Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(message)}');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the Messenger chat was opened. The message is copied
  /// to the clipboard as a side effect either way (callers should tell the
  /// user to paste it).
  static Future<bool> _openMessenger(Caregiver caregiver, String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    final username = caregiver.messengerUsername;
    if (username == null || username.isEmpty) return false;
    final uri = Uri.parse('https://m.me/$username');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
