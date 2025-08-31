import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class FileOperationService {
  /// 在Finder/文件管理器中显示文件
  static Future<void> showInFinder(String filePath) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', ['/select,', filePath]);
      } else if (Platform.isLinux) {
        // 尝试使用xdg-open打开文件所在目录
        final directory = path.dirname(filePath);
        await Process.run('xdg-open', [directory]);
      }
    } catch (e) {
      debugPrint('Error showing file in finder: $e');
      rethrow;
    }
  }

  /// 移动文件到回收站
  static Future<void> moveToTrash(List<String> filePaths) async {
    try {
      if (Platform.isMacOS) {
        // 使用AppleScript移动到回收站
        for (final filePath in filePaths) {
          final script = '''
            tell application "Finder"
              move POSIX file "$filePath" to trash
            end tell
          ''';
          final result = await Process.run('osascript', ['-e', script]);
          if (result.exitCode != 0) {
            throw Exception('Failed to move file to trash: ${result.stderr}');
          }
        }
      } else if (Platform.isWindows) {
        // Windows使用PowerShell移动到回收站
        for (final filePath in filePaths) {
          final script = '''
            Add-Type -AssemblyName Microsoft.VisualBasic
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('$filePath', 'OnlyErrorDialogs', 'SendToRecycleBin')
          ''';
          await Process.run('powershell', ['-Command', script]);
        }
      } else if (Platform.isLinux) {
        // Linux使用gio trash
        await Process.run('gio', ['trash', ...filePaths]);
      }
    } catch (e) {
      debugPrint('Error moving files to trash: $e');
      rethrow;
    }
  }

  /// 永久删除文件
  static Future<void> deleteFiles(List<String> filePaths) async {
    try {
      for (final filePath in filePaths) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error deleting files: $e');
      rethrow;
    }
  }

  /// 根据条件过滤文件（保留最新、最旧、最大、最小等）
  static List<String> filterFilesByStrategy(List<String> filePaths, FileFilterStrategy strategy) {
    if (filePaths.length <= 1) return [];

    final fileInfos = filePaths.map((path) {
      final file = File(path);
      return FileInfo(
        path: path,
        size: file.existsSync() ? file.lengthSync() : 0,
        lastModified: file.existsSync() ? file.lastModifiedSync() : DateTime.now(),
      );
    }).toList();

    FileInfo keepFile;
    switch (strategy) {
      case FileFilterStrategy.keepNewest:
        keepFile = fileInfos.reduce((a, b) {
          final comparison = a.lastModified.compareTo(b.lastModified);
          if (comparison == 0) {
            return a.path.compareTo(b.path) > 0 ? a : b;
          }
          return comparison > 0 ? a : b;
        });
        break;
      case FileFilterStrategy.keepOldest:
        keepFile = fileInfos.reduce((a, b) {
          final comparison = a.lastModified.compareTo(b.lastModified);
          if (comparison == 0) {
            return a.path.compareTo(b.path) < 0 ? a : b;
          }
          return comparison < 0 ? a : b;
        });
        break;
    }

    // 返回除了保留文件之外的所有文件
    return fileInfos.where((info) => info.path != keepFile.path).map((info) => info.path).toList();
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

enum FileFilterStrategy {
  keepNewest,
  keepOldest,
}

class FileInfo {
  final String path;
  final int size;
  final DateTime lastModified;

  FileInfo({
    required this.path,
    required this.size,
    required this.lastModified,
  });
}