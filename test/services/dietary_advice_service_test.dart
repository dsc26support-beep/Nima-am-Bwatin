import 'package:flutter_test/flutter_test.dart';
import 'package:nima_am_bwatin/models/blood_sugar_band.dart';
import 'package:nima_am_bwatin/services/dietary_advice_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads advice for every test type and band, in English', () async {
    final service = DietaryAdviceService();
    await service.load();

    for (final type in GlucoseTestType.values) {
      for (final band in GlucoseBand.values) {
        final advice = service.adviceFor(type, band, 'en');
        expect(advice, isNotEmpty, reason: 'missing advice for ${type.name}_${band.name}');
      }
    }
  });

  test('falls back to English when a language is missing', () async {
    final service = DietaryAdviceService();
    await service.load();

    final advice = service.adviceFor(GlucoseTestType.fbs, GlucoseBand.normal, 'fr');
    expect(advice, isNotEmpty);
  });
}
