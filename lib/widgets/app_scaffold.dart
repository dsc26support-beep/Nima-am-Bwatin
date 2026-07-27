import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';

/// A Scaffold with a consistent AppBar whose title is looked up through the
/// current translator, so every top-level screen stays in sync with the
/// language toggle without repeating boilerplate.
class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.titleKey,
    required this.body,
    this.floatingActionButton,
    this.actions,
  });

  final String titleKey;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.t(titleKey)),
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
