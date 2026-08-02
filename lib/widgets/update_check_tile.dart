import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../services/update_check_service.dart';

enum _UpdateState { idle, checking, upToDate, available, failed }

class UpdateCheckTile extends ConsumerStatefulWidget {
  const UpdateCheckTile({super.key});

  @override
  ConsumerState<UpdateCheckTile> createState() => _UpdateCheckTileState();
}

class _UpdateCheckTileState extends ConsumerState<UpdateCheckTile> {
  _UpdateState _state = _UpdateState.idle;

  Future<void> _onTap() async {
    if (_state == _UpdateState.checking) return;

    if (_state == _UpdateState.available) {
      await launchUrl(Uri.parse(UpdateCheckService.apkDownloadUrl), mode: LaunchMode.externalApplication);
      return;
    }

    setState(() => _state = _UpdateState.checking);
    final result = await UpdateCheckService.checkForUpdate();
    if (!mounted) return;
    setState(() {
      _state = switch (result) {
        UpdateCheckResult.updateAvailable => _UpdateState.available,
        UpdateCheckResult.upToDate => _UpdateState.upToDate,
        UpdateCheckResult.checkFailed => _UpdateState.failed,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final String label;
    switch (_state) {
      case _UpdateState.idle:
        label = ref.t('settings_check_updates');
      case _UpdateState.checking:
        label = ref.t('settings_checking_updates');
      case _UpdateState.available:
        label = ref.t('settings_update_now');
      case _UpdateState.upToDate:
        label = ref.t('settings_up_to_date');
      case _UpdateState.failed:
        label = ref.t('settings_update_check_failed');
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.system_update_alt_outlined),
        title: Text(label),
        trailing: _state == _UpdateState.checking
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
        onTap: _onTap,
      ),
    );
  }
}
