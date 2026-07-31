import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/blood_sugar_band.dart';

class BandBadge extends ConsumerWidget {
  const BandBadge({super.key, required this.band});

  final GlucoseBand band;

  Color _color() {
    switch (band) {
      case GlucoseBand.normal:
        return Colors.green;
      case GlucoseBand.prediabetes:
        return Colors.orange;
      case GlucoseBand.diabetes:
        return Colors.red;
    }
  }

  String _labelKey() {
    switch (band) {
      case GlucoseBand.normal:
        return 'band_normal';
      case GlucoseBand.prediabetes:
        return 'band_prediabetes';
      case GlucoseBand.diabetes:
        return 'band_diabetes';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        ref.t(_labelKey()),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
