import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A small leading thumbnail for list rows: shows the attached photo if one
/// exists and its file is still present, otherwise falls back to [icon].
class EntityThumbnail extends StatelessWidget {
  const EntityThumbnail({super.key, required this.photoPath, required this.icon});

  final String? photoPath;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final file = photoPath != null ? File(photoPath!) : null;
    if (file != null && file.existsSync()) {
      return CircleAvatar(backgroundImage: FileImage(file));
    }
    return CircleAvatar(
      backgroundColor: AppColors.coral.withValues(alpha: 0.15),
      child: Icon(icon, color: AppColors.coral),
    );
  }
}
