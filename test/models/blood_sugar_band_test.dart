import 'package:flutter_test/flutter_test.dart';
import 'package:nima_am_bwatin/models/blood_sugar_band.dart';

void main() {
  group('FBS boundaries', () {
    test('just under 5.6 is normal', () {
      expect(BandClassifier.classify(GlucoseTestType.fbs, 5.5, GlucoseUnit.mmolL), GlucoseBand.normal);
    });
    test('5.6 is prediabetes', () {
      expect(BandClassifier.classify(GlucoseTestType.fbs, 5.6, GlucoseUnit.mmolL), GlucoseBand.prediabetes);
    });
    test('6.9 is prediabetes', () {
      expect(BandClassifier.classify(GlucoseTestType.fbs, 6.9, GlucoseUnit.mmolL), GlucoseBand.prediabetes);
    });
    test('7.0 is diabetes', () {
      expect(BandClassifier.classify(GlucoseTestType.fbs, 7.0, GlucoseUnit.mmolL), GlucoseBand.diabetes);
    });
  });

  group('RBS boundaries', () {
    test('just under 7.8 is normal', () {
      expect(BandClassifier.classify(GlucoseTestType.rbs, 7.7, GlucoseUnit.mmolL), GlucoseBand.normal);
    });
    test('7.8 is prediabetes', () {
      expect(BandClassifier.classify(GlucoseTestType.rbs, 7.8, GlucoseUnit.mmolL), GlucoseBand.prediabetes);
    });
    test('11.0 is prediabetes', () {
      expect(BandClassifier.classify(GlucoseTestType.rbs, 11.0, GlucoseUnit.mmolL), GlucoseBand.prediabetes);
    });
    test('11.1 is diabetes', () {
      expect(BandClassifier.classify(GlucoseTestType.rbs, 11.1, GlucoseUnit.mmolL), GlucoseBand.diabetes);
    });
  });

  test('mg/dL input is normalized before classification', () {
    // 100 mg/dL ~= 5.55 mmol/L -> just under the 5.6 FBS cutoff -> normal
    expect(BandClassifier.classify(GlucoseTestType.fbs, 100, GlucoseUnit.mgdL), GlucoseBand.normal);
    // 126 mg/dL ~= 6.99 mmol/L -> still prediabetes, not yet diabetes
    expect(BandClassifier.classify(GlucoseTestType.fbs, 126, GlucoseUnit.mgdL), GlucoseBand.prediabetes);
  });
}
