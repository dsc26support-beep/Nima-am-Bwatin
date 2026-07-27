import 'package:flutter_test/flutter_test.dart';
import 'package:nima_am_bwatin/utils/unit_conversion.dart';

void main() {
  test('mmol/L to mg/dL round trip', () {
    final mgdl = UnitConversion.mmolToMgdl(5.6);
    expect(mgdl, closeTo(100.9, 0.5));
    final backToMmol = UnitConversion.mgdlToMmol(mgdl);
    expect(backToMmol, closeTo(5.6, 0.01));
  });
}
