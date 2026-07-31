class UnitConversion {
  UnitConversion._();

  static const double mmolToMgdlFactor = 18.0182;

  static double mmolToMgdl(double mmol) => mmol * mmolToMgdlFactor;
  static double mgdlToMmol(double mgdl) => mgdl / mmolToMgdlFactor;
}
