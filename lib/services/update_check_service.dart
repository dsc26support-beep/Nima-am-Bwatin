import 'dart:convert';

import 'package:http/http.dart' as http;

/// Result of comparing the running app's build against the latest
/// CI-published debug release. Kept distinct from a plain bool so a failed
/// check (bad network, stale CDN cache, unparseable response) never gets
/// reported to the user as "you're up to date" -- those are very different
/// things to tell someone about a health-reminder app.
enum UpdateCheckResult { upToDate, updateAvailable, checkFailed }

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

  /// Checks whether a newer build than the one currently installed is
  /// available. Every release re-publishes `version.json` under the same
  /// URL, which is exactly the shape of request an intermediate cache (a
  /// mobile carrier's proxy, a DNS/CDN edge) is prone to serve stale --
  /// hence the cache-busting query param and no-cache header below, on top
  /// of a generous timeout for slower connections.
  static Future<UpdateCheckResult> checkForUpdate() async {
    if (currentBuildSha.isEmpty) return UpdateCheckResult.checkFailed;

    try {
      final bustUrl = Uri.parse(versionJsonUrl).replace(
        queryParameters: {'cb': DateTime.now().millisecondsSinceEpoch.toString()},
      );
      final response = await http
          .get(bustUrl, headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'})
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) return UpdateCheckResult.checkFailed;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final latestSha = data['sha'] as String?;
      if (latestSha == null || latestSha.isEmpty) return UpdateCheckResult.checkFailed;

      return latestSha != currentBuildSha ? UpdateCheckResult.updateAvailable : UpdateCheckResult.upToDate;
    } catch (_) {
      return UpdateCheckResult.checkFailed;
    }
  }
}
