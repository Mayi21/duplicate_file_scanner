import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/file_model.dart';
import '../services/file_scanner_service.dart';

class FileScannerProvider with ChangeNotifier {
  final FileScannerService _scannerService = FileScannerService();

  bool _isScanning = false;
  double _progress = 0.0;
  String _currentFilePath = '';
  List<FileGroup> _duplicateFiles = [];
  Directory? _selectedDirectory;

  // State for the new preview logic
  FileGroup? _groupForPreview;
  String? _fileForPreview;

  bool get isScanning => _isScanning;
  double get progress => _progress;
  String get currentFilePath => _currentFilePath;
  List<FileGroup> get duplicateFiles => _duplicateFiles;
  Directory? get selectedDirectory => _selectedDirectory;
  FileGroup? get groupForPreview => _groupForPreview;
  String? get fileForPreview => _fileForPreview;

  void setDirectory(Directory? directory) {
    _selectedDirectory = directory;
    _duplicateFiles = [];
    _groupForPreview = null;
    _fileForPreview = null;
    notifyListeners();
  }

  void selectGroupForPreview(FileGroup group) {
    _groupForPreview = group;
    _fileForPreview = null; // Clear single file selection
    notifyListeners();
  }

  void selectFileForPreview(String path) {
    _fileForPreview = path;
    _groupForPreview = null; // Clear group selection
    notifyListeners();
  }

  void removeFileFromGroup(String hash, String path) {
    final groupIndex = _duplicateFiles.indexWhere((g) => g.hash == hash);
    if (groupIndex != -1) {
      final group = _duplicateFiles[groupIndex];
      group.paths.remove(path);

      // If the deleted file was being previewed, clear the preview
      if (_fileForPreview == path) {
        _fileForPreview = null;
      }

      if (group.paths.length < 2) {
        _duplicateFiles.removeAt(groupIndex);
        // If the group was being previewed, clear the preview
        if (_groupForPreview?.hash == hash) {
          _groupForPreview = null;
        }
      }
      notifyListeners();
    }
  }

  Future<void> startScan() async {
    if (_selectedDirectory == null || _isScanning) {
      return;
    }

    _isScanning = true;
    _progress = 0.0;
    _currentFilePath = '';
    _duplicateFiles = [];
    _groupForPreview = null;
    _fileForPreview = null;
    notifyListeners();

    await _scannerService.startScan(
      _selectedDirectory!.path,
      (progressData) {
        if (progressData is Map) {
          _progress = progressData['progress'];
          _currentFilePath = progressData['filePath'];
          notifyListeners();
        }
      },
      (result) {
        _duplicateFiles = result;
        _isScanning = false;
        _progress = 0.0;
        _currentFilePath = '';
        notifyListeners();
      },
    );
  }
}
