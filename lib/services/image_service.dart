import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pocketentry/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;
  final _uuid = const Uuid();

  Future<bool> requestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
    return true;
  }

  Future<String?> pickAndSaveImage(ImageSource source) async {
    final granted = await requestPermissions(source);
    if (!granted) return null;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory(
      p.join(appDir.path, AppConstants.attachmentsFolder),
    );
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    final ext = p.extension(picked.path);
    final fileName = '${_uuid.v4()}$ext';
    final savedPath = p.join(receiptsDir.path, fileName);
    await File(picked.path).copy(savedPath);
    return savedPath;
  }

  Future<void> deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
