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
  FileGroup? _selectedGroupForPreview;

  bool get isScanning => _isScanning;
  double get progress => _progress;
  String get currentFilePath => _currentFilePath;
  List<FileGroup> get duplicateFiles => _duplicateFiles;
  Directory? get selectedDirectory => _selectedDirectory;
  FileGroup? get selectedGroupForPreview => _selectedGroupForPreview;

  void setDirectory(Directory? directory) {
    _selectedDirectory = directory;
    _duplicateFiles = []; // Clear previous results
    _selectedGroupForPreview = null;
    notifyListeners();
  }

  void selectGroupForPreview(FileGroup group) {
    _selectedGroupForPreview = group;
    notifyListeners();
  }

  void removeFileFromGroup(String hash, String path) {
    final groupIndex = _duplicateFiles.indexWhere((g) => g.hash == hash);
    if (groupIndex != -1) {
      final group = _duplicateFiles[groupIndex];
      group.paths.remove(path);

      if (group.paths.length < 2) {
        _duplicateFiles.removeAt(groupIndex);
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