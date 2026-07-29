import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = ref.tImperative('feedback_empty_error'));
      return;
    }
    setState(() => _error = null);

    final uri = Uri(
      scheme: 'mailto',
      path: 'dsc26.support@gmail.com',
      query: 'subject=${Uri.encodeComponent('Nima-am-Bwatin Feedback')}'
          '&body=${Uri.encodeComponent(text)}',
    );

    bool sent;
    try {
      sent = await launchUrl(uri);
    } catch (_) {
      sent = false;
    }

    if (!mounted) return;
    sent ? _showSentDialog() : _showFailedDialog();
  }

  void _showSentDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(ref.tImperative('feedback_sent_title')),
        content: Text(ref.tImperative('feedback_sent_body')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // close dialog
              Navigator.of(context).pop(); // back to Settings
            },
            child: Text(ref.tImperative('common_ok')),
          ),
        ],
      ),
    );
  }

  void _showFailedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(ref.tImperative('feedback_failed_title')),
        content: Text(ref.tImperative('feedback_failed_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(), // stay on feedback form
            child: Text(ref.tImperative('feedback_try_again')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // close dialog
              Navigator.of(context).pop(); // back to Settings
            },
            child: Text(ref.tImperative('feedback_back_to_settings')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ref.t('feedback_title'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ref.t('feedback_intro')),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: ref.t('feedback_hint'),
                  errorText: _error,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text(ref.t('feedback_submit')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
