import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../services/photo_service.dart';

/// A tappable box showing either a saved photo (with a remove button) or a
/// placeholder that opens a camera/gallery choice. Used on the medication
/// and appointment forms so a photo of the medicine box, prescription, or
/// referral letter can be attached.
class PhotoPickerField extends ConsumerWidget {
  const PhotoPickerField({
    super.key,
    required this.photoPath,
    required this.onChanged,
  });

  final String? photoPath;
  final ValueChanged<String?> onChanged;

  Future<void> _pick(BuildContext context, WidgetRef ref, ImageSource source) async {
    final saved = await PhotoService.pickAndSave(source);
    if (saved != null) {
      onChanged(saved);
    }
  }

  Future<void> _remove() async {
    await PhotoService.delete(photoPath);
    onChanged(null);
  }

  Future<void> _showSourcePicker(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(ref.t('photo_take')),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(context, ref, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(ref.t('photo_choose_gallery')),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(context, ref, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = photoPath != null ? File(photoPath!) : null;
    final hasPhoto = file != null && file.existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ref.t('photo_label'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Stack(
          children: [
            InkWell(
              onTap: () => _showSourcePicker(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.deepBlue.withValues(alpha: 0.4)),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasPhoto
                    ? Image.file(file, fit: BoxFit.cover, width: 120, height: 120)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, color: AppColors.deepBlue),
                          const SizedBox(height: 8),
                          Text(
                            ref.t('photo_add'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: AppColors.deepBlue),
                          ),
                        ],
                      ),
              ),
            ),
            if (hasPhoto)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _remove,
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
