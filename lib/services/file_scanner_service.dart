import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/file_model.dart';

class FileScannerService {
  Future<void> startScan(
    String path,
    Function(dynamic) onProgress,
    Function(List<FileGroup>) onResult,
  ) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      scanIsolate,
      [receivePort.sendPort, path],
    );

    receivePort.listen((message) {
      if (message is Map) {
        onProgress(message);
      } else if (message is List<FileGroup>) {
        onResult(message);
        isolate.kill(priority: Isolate.immediate);
      }
    });
  }

  static void scanIsolate(List<dynamic> args) async {
    final sendPort = args[0] as SendPort;
    final path = args[1] as String;

    final files = Directory(path).listSync(recursive: true).whereType<File>().toList();
    final fileCount = files.length;
    int processedCount = 0;

    final Map<String, List<String>> hashes = {};

    for (final file in files) {
      try {
        final hash = await _calculateHash(file.path);
        if (hash.isNotEmpty) {
          if (hashes.containsKey(hash)) {
            hashes[hash]!.add(file.path);
          } else {
            hashes[hash] = [file.path];
          }
        }
      } catch (e) {
        // Ignore files that can't be read
      }

      processedCount++;
      sendPort.send({'progress': processedCount / fileCount, 'filePath': file.path});
    }

    final List<FileGroup> duplicates = [];
    hashes.forEach((hash, paths) {
      if (paths.length > 1) {
        final size = File(paths.first).lengthSync();
        duplicates.add(FileGroup(hash: hash, size: size, paths: paths));
      }
    });

    sendPort.send(duplicates);
  }

  static Future<String> _calculateHash(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      try {
        final stream = file.openRead();
        final hash = await md5.bind(stream).first;
        return hash.toString();
      } catch (e) {
        return '';
      }
    }
    return '';
  }
}
