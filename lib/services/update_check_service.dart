import 'dart:convert';

import 'package:http/http.dart' as http;

/// Compares the running app's build against the latest CI-published debug
/// release on GitHub. The commit SHA the app was built from is baked in at
/// build time via `--dart-define=BUILD_SHA=<sha>` (see
/// .github/workflows/build-apk.yml); a build run outside that workflow (e.g.
/// a local `flutter run`) has no BUILD_SHA, so update checks are skipped.
class UpdateCheckService {
  UpdateCheckService._();

  static const String _releaseBase =
      'https://github.com/dsc26support-beep/Nima-am-Bwatin/releases/download/debug-latest';
  static const String versionJsonUrl = '$_releaseBase/version.json';
  static const String apkDownloadUrl = '$_releaseBase/app-debug.apk';

  static const String currentBuildSha = String.fromEnvironment('BUILD_SHA');

  /// Returns true if a newer build than the one currently installed is
  /// available. Returns false (rather than throwing) on any network or
  /// parsing failure, or when this build has no embedded BUILD_SHA to
  /// compare against.
  static Future<bool> isUpdateAvailable() async {
    if (currentBuildSha.isEmpty) return false;

    try {
      final response = await http.get(Uri.parse(versionJsonUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final latestSha = data['sha'] as String?;
      return latestSha != null && latestSha.isNotEmpty && latestSha != currentBuildSha;
    } catch (_) {
      return false;
    }
  }
}
