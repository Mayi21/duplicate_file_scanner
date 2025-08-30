import 'package:flutter/foundation.dart';
import '../models/file_model.dart';
import '../utils/file_type_helper.dart';

class StatisticsProvider extends ChangeNotifier {
  List<FileGroup> _duplicateFiles = [];
  final Map<String, List<String>> _selectedFiles = {};

  void updateData(List<FileGroup> duplicateFiles) {
    _duplicateFiles = duplicateFiles;
    notifyListeners();
  }

  void toggleFileSelection(String groupHash, String filePath) {
    _selectedFiles[groupHash] ??= [];
    if (_selectedFiles[groupHash]!.contains(filePath)) {
      _selectedFiles[groupHash]!.remove(filePath);
      if (_selectedFiles[groupHash]!.isEmpty) {
        _selectedFiles.remove(groupHash);
      }
    } else {
      _selectedFiles[groupHash]!.add(filePath);
    }
    notifyListeners();
  }

  void selectAllInGroup(String groupHash, List<String> filePaths) {
    _selectedFiles[groupHash] = List.from(filePaths);
    notifyListeners();
  }

  void deselectAllInGroup(String groupHash) {
    _selectedFiles.remove(groupHash);
    notifyListeners();
  }

  void clearAllSelections() {
    _selectedFiles.clear();
    notifyListeners();
  }

  bool isFileSelected(String groupHash, String filePath) {
    return _selectedFiles[groupHash]?.contains(filePath) ?? false;
  }

  List<String> getSelectedFilesInGroup(String groupHash) {
    return _selectedFiles[groupHash] ?? [];
  }

  List<String> getAllSelectedFiles() {
    return _selectedFiles.values.expand((files) => files).toList();
  }

  int get totalSelectedFiles => getAllSelectedFiles().length;

  int get totalDuplicateGroups => _duplicateFiles.length;

  int get totalDuplicateFiles => _duplicateFiles.fold(0, (sum, group) => sum + group.paths.length);

  int get totalWastedSpace => _duplicateFiles.fold(0, (sum, group) => sum + (group.size * (group.paths.length - 1)));

  Map<String, int> get fileTypeStatistics {
    final Map<String, int> stats = {};
    for (final group in _duplicateFiles) {
      for (final path in group.paths) {
        final type = FileTypeHelper.getFileType(path);
        stats[type] = (stats[type] ?? 0) + 1;
      }
    }
    return stats;
  }

  Map<String, int> get fileSizeDistribution {
    final Map<String, int> distribution = {
      '< 1 MB': 0,
      '1-10 MB': 0,
      '10-100 MB': 0,
      '100MB-1GB': 0,
      '> 1 GB': 0,
    };

    for (final group in _duplicateFiles) {
      final sizeInMB = group.size / (1024 * 1024);
      String category;
      if (sizeInMB < 1) {
        category = '< 1 MB';
      } else if (sizeInMB < 10) {
        category = '1-10 MB';
      } else if (sizeInMB < 100) {
        category = '10-100 MB';
      } else if (sizeInMB < 1000) {
        category = '100MB-1GB';
      } else {
        category = '> 1 GB';
      }
      distribution[category] = distribution[category]! + group.paths.length;
    }
    
    return distribution;
  }

  FileGroup? getLargestDuplicateGroup() {
    if (_duplicateFiles.isEmpty) return null;
    return _duplicateFiles.reduce((a, b) => a.size > b.size ? a : b);
  }

  FileGroup? getMostDuplicatedGroup() {
    if (_duplicateFiles.isEmpty) return null;
    return _duplicateFiles.reduce((a, b) => a.paths.length > b.paths.length ? a : b);
  }
}