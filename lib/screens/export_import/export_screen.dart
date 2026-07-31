import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _export() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref.read(exportImportServiceProvider).shareExport();
      setState(() => _message = ref.tImperative('export_success'));
    } catch (_) {
      setState(() => _message = ref.tImperative('export_error'));
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ref.t('export_title'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_file_outlined, size: 64),
              const SizedBox(height: 24),
              Text(ref.t('export_intro'), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                ref.t('export_recovery_note'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              if (_message != null) ...[
                Text(_message!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: _busy ? null : _export,
                child: Text(ref.t('settings_export_data')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
