import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/locale_provider.dart';
import '../../services/export_import_service.dart';
import '../../widgets/confirm_dialog.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _import() async {
    final service = ref.read(exportImportServiceProvider);
    final file = await service.pickImportFile();
    if (file == null || !mounted) return;

    final confirmed = await showConfirmDialog(
      context,
      message: ref.tImperative('import_confirm_replace'),
      confirmLabel: ref.tImperative('common_confirm'),
      cancelLabel: ref.tImperative('common_cancel'),
    );
    if (!confirmed) return;

    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      final translator = ref.read(translatorProvider);
      await service.importFromFile(file, translator);
      setState(() => _message = ref.tImperative('import_success'));
    } on ImportValidationException {
      setState(() => _message = ref.tImperative('import_error'));
    } catch (_) {
      setState(() => _message = ref.tImperative('import_error'));
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ref.t('import_title'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.download_outlined, size: 64),
              const SizedBox(height: 24),
              if (_message != null) ...[
                Text(_message!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: _busy ? null : _import,
                child: Text(ref.t('settings_import_data')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
