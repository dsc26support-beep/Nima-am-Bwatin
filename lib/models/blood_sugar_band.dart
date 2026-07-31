import '../utils/unit_conversion.dart';

enum GlucoseTestType { rbs, fbs }

enum GlucoseUnit { mmolL, mgdL }

enum GlucoseBand { normal, prediabetes, diabetes }

/// Classifies a blood sugar reading into a band using standard WHO/ADA-style
/// cutoffs. This is general guidance, not a diagnosis -- shown alongside a
/// disclaimer in the UI.
///
/// Values are always normalized to mmol/L before comparison, so there is
/// only one canonical threshold table to maintain.
///
/// | Test | Normal        | Prediabetes      | Diabetes     |
/// |------|---------------|------------------|--------------|
/// | FBS  | < 5.6 mmol/L  | 5.6 - 6.9 mmol/L | >= 7.0 mmol/L|
/// | RBS  | < 7.8 mmol/L  | 7.8 - 11.0 mmol/L| >= 11.1 mmol/L|
class BandClassifier {
  BandClassifier._();

  static GlucoseBand classify(GlucoseTestType type, double value, GlucoseUnit unit) {
    final mmol = unit == GlucoseUnit.mmolL ? value : UnitConversion.mgdlToMmol(value);

    if (type == GlucoseTestType.fbs) {
      if (mmol < 5.6) return GlucoseBand.normal;
      if (mmol < 7.0) return GlucoseBand.prediabetes;
      return GlucoseBand.diabetes;
    } else {
      if (mmol < 7.8) return GlucoseBand.normal;
      if (mmol < 11.1) return GlucoseBand.prediabetes;
      return GlucoseBand.diabetes;
    }
  }
}
