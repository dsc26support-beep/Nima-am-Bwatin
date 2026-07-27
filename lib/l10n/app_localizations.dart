import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';

/// Ergonomic shorthand so widgets can call `ref.t('key')` instead of
/// `ref.watch(translatorProvider).t('key')` everywhere.
extension AppLocalizationsX on WidgetRef {
  /// Use inside a widget's build method -- reactively rebuilds when the
  /// language toggle changes.
  String t(String key, [Map<String, String>? params]) {
    return watch(translatorProvider).t(key, params);
  }

  /// Use in callbacks/dialog builders outside of build (e.g. a button's
  /// onPressed), where `ref.watch` is not allowed.
  String tImperative(String key, [Map<String, String>? params]) {
    return read(translatorProvider).t(key, params);
  }
}
