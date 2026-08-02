import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Picks a photo (camera or gallery) and copies it into the app's own
/// documents directory so it survives after the picker's temporary file is
/// cleared, then returns the saved file's path to store on a Medication or
/// Appointment.
class PhotoService {
  PhotoService._();

  static Future<String?> pickAndSave(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'photos'));
    if (!photosDir.existsSync()) {
      photosDir.createSync(recursive: true);
    }

    final fileName = '${DateTime.now().microsecondsSinceEpoch}_${p.basename(picked.path)}';
    final savedPath = p.join(photosDir.path, fileName);
    await File(picked.path).copy(savedPath);
    return savedPath;
  }

  static Future<void> delete(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
