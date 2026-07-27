import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'providers/locale_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // Kept fixed regardless of the app's displayed language -- Kiribati
      // isn't ICU-supported, so built-in widgets (date/time pickers) stay
      // English while custom text is driven entirely by AppTranslator.
      locale: const Locale('en'),
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends ConsumerWidget {
  const _StartupGate();

  Future<bool> _isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefsKeyOnboardingComplete) ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stringsAsync = ref.watch(assetStringsProvider);

    return stringsAsync.when(
      data: (_) => FutureBuilder<bool>(
        future: _isOnboardingComplete(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const _SplashScreen();
          return snapshot.data! ? const HomeScreen() : const OnboardingScreen();
        },
      ),
      loading: () => const _SplashScreen(),
      error: (error, stackTrace) => const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/icons/moh_logo.png', height: 160)),
    );
  }
}
