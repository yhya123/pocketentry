import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pocketentry/core/constants/app_constants.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// واجهة موحدة للنسخ الاحتياطي — جاهزة لإضافة Google Drive لاحقًا
abstract class BackupProvider {
  BackupSource get source;
  Future<String> createBackup();
  Future<void> restoreBackup(String backupPath);
  Future<List<BackupFileInfo>> listBackups();
}

class BackupFileInfo {
  const BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.createdAt,
    required this.source,
  });

  final String path;
  final String fileName;
  final DateTime createdAt;
  final BackupSource source;
}

class LocalBackupProvider implements BackupProvider {
  LocalBackupProvider(this._dbHelper);
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  @override
  BackupSource get source => BackupSource.local;

  Future<Directory> _getBackupDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, AppConstants.backupsFolder));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<String> createBackup() async {
    final db = await _dbHelper.database;
    final dbPath = db.path;
    final backupDir = await _getBackupDir();
    final timestamp = DateTime.now();
    final fileName =
        'backup_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour}${timestamp.minute}_${_uuid.v4().substring(0, 8)}.db';
    final backupPath = p.join(backupDir.path, fileName);
    await File(dbPath).copy(backupPath);
    return backupPath;
  }

  @override
  Future<void> restoreBackup(String backupPath) async {
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      throw Exception('ملف النسخة الاحتياطية غير موجود');
    }
    await _dbHelper.close();
    final dbPath = p.join(await getDatabasesPath(), AppConstants.dbName);
    await File(dbPath).writeAsBytes(await backupFile.readAsBytes());
    await _dbHelper.database;
  }

  @override
  Future<List<BackupFileInfo>> listBackups() async {
    final dir = await _getBackupDir();
    if (!await dir.exists()) return [];

    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.db'))
            .toList()
          ..sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
          );

    return files.map((file) {
      return BackupFileInfo(
        path: file.path,
        fileName: p.basename(file.path),
        createdAt: file.lastModifiedSync(),
        source: BackupSource.local,
      );
    }).toList();
  }
}

/// Google Drive — بنية جاهزة للتوسعة (تتطلب google_sign_in + googleapis)
class GoogleDriveBackupProvider implements BackupProvider {
  @override
  BackupSource get source => BackupSource.googleDrive;

  @override
  Future<String> createBackup() {
    throw UnimplementedError(
      'نسخ Google Drive غير مفعّل بعد. استخدم النسخ المحلي أو أضف google_sign_in لاحقًا.',
    );
  }

  @override
  Future<void> restoreBackup(String backupPath) {
    throw UnimplementedError('استرجاع Google Drive غير مفعّل بعد.');
  }

  @override
  Future<List<BackupFileInfo>> listBackups() async => [];
}

class BackupService {
  BackupService({required LocalBackupProvider localProvider})
    : _providers = {BackupSource.local: localProvider};

  final Map<BackupSource, BackupProvider> _providers;

  BackupProvider provider(BackupSource source) => _providers[source]!;

  Future<String> backup(BackupSource source) => provider(source).createBackup();

  Future<void> restore(BackupSource source, String path) =>
      provider(source).restoreBackup(path);

  Future<List<BackupFileInfo>> listBackups(BackupSource source) =>
      provider(source).listBackups();
}
