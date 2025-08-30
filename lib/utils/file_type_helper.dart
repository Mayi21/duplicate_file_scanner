import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FileTypeHelper {
  static final Map<String, IconData> _typeIcons = {
    // 图片文件
    '.jpg': Icons.image,
    '.jpeg': Icons.image,
    '.png': Icons.image,
    '.gif': Icons.image,
    '.bmp': Icons.image,
    '.webp': Icons.image,
    '.svg': Icons.image,
    '.tiff': Icons.image,
    
    // 视频文件
    '.mp4': Icons.video_file,
    '.mov': Icons.video_file,
    '.avi': Icons.video_file,
    '.mkv': Icons.video_file,
    '.wmv': Icons.video_file,
    '.flv': Icons.video_file,
    '.webm': Icons.video_file,
    
    // 音频文件
    '.mp3': Icons.audio_file,
    '.wav': Icons.audio_file,
    '.flac': Icons.audio_file,
    '.aac': Icons.audio_file,
    '.m4a': Icons.audio_file,
    '.ogg': Icons.audio_file,
    
    // 文档文件
    '.pdf': Icons.picture_as_pdf,
    '.doc': Icons.description,
    '.docx': Icons.description,
    '.txt': Icons.text_snippet,
    '.rtf': Icons.description,
    
    // 表格文件
    '.xls': Icons.table_chart,
    '.xlsx': Icons.table_chart,
    '.csv': Icons.table_chart,
    
    // 演示文件
    '.ppt': Icons.slideshow,
    '.pptx': Icons.slideshow,
    
    // 压缩文件
    '.zip': Icons.archive,
    '.rar': Icons.archive,
    '.7z': Icons.archive,
    '.tar': Icons.archive,
    '.gz': Icons.archive,
    
    // 可执行文件
    '.exe': Icons.settings_applications,
    '.app': Icons.settings_applications,
    '.dmg': Icons.settings_applications,
    
    // 代码文件
    '.js': Icons.code,
    '.html': Icons.code,
    '.css': Icons.code,
    '.dart': Icons.code,
    '.java': Icons.code,
    '.py': Icons.code,
    '.cpp': Icons.code,
    '.c': Icons.code,
    '.swift': Icons.code,
    '.kt': Icons.code,
  };

  static final Map<String, Color> _typeColors = {
    // 图片文件 - 绿色系
    '.jpg': Colors.green,
    '.jpeg': Colors.green,
    '.png': Colors.green,
    '.gif': Colors.green,
    '.bmp': Colors.green,
    '.webp': Colors.green,
    '.svg': Colors.green,
    '.tiff': Colors.green,
    
    // 视频文件 - 红色系
    '.mp4': Colors.red,
    '.mov': Colors.red,
    '.avi': Colors.red,
    '.mkv': Colors.red,
    '.wmv': Colors.red,
    '.flv': Colors.red,
    '.webm': Colors.red,
    
    // 音频文件 - 紫色系
    '.mp3': Colors.purple,
    '.wav': Colors.purple,
    '.flac': Colors.purple,
    '.aac': Colors.purple,
    '.m4a': Colors.purple,
    '.ogg': Colors.purple,
    
    // 文档文件 - 蓝色系
    '.pdf': Colors.blue,
    '.doc': Colors.blue,
    '.docx': Colors.blue,
    '.txt': Colors.blue,
    '.rtf': Colors.blue,
    
    // 表格文件 - 橙色系
    '.xls': Colors.orange,
    '.xlsx': Colors.orange,
    '.csv': Colors.orange,
    
    // 演示文件 - 深橙色系
    '.ppt': Colors.deepOrange,
    '.pptx': Colors.deepOrange,
    
    // 压缩文件 - 棕色系
    '.zip': Colors.brown,
    '.rar': Colors.brown,
    '.7z': Colors.brown,
    '.tar': Colors.brown,
    '.gz': Colors.brown,
    
    // 可执行文件 - 灰色系
    '.exe': Colors.grey,
    '.app': Colors.grey,
    '.dmg': Colors.grey,
    
    // 代码文件 - 青色系
    '.js': Colors.teal,
    '.html': Colors.teal,
    '.css': Colors.teal,
    '.dart': Colors.teal,
    '.java': Colors.teal,
    '.py': Colors.teal,
    '.cpp': Colors.teal,
    '.c': Colors.teal,
    '.swift': Colors.teal,
    '.kt': Colors.teal,
  };

  static IconData getFileIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return _typeIcons[extension] ?? Icons.insert_drive_file;
  }

  static Color getFileColor(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return _typeColors[extension] ?? Colors.blueGrey;
  }

  static String getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
      case '.svg':
      case '.tiff':
        return 'Image';
      case '.mp4':
      case '.mov':
      case '.avi':
      case '.mkv':
      case '.wmv':
      case '.flv':
      case '.webm':
        return 'Video';
      case '.mp3':
      case '.wav':
      case '.flac':
      case '.aac':
      case '.m4a':
      case '.ogg':
        return 'Audio';
      case '.pdf':
      case '.doc':
      case '.docx':
      case '.txt':
      case '.rtf':
        return 'Document';
      case '.xls':
      case '.xlsx':
      case '.csv':
        return 'Spreadsheet';
      case '.ppt':
      case '.pptx':
        return 'Presentation';
      case '.zip':
      case '.rar':
      case '.7z':
      case '.tar':
      case '.gz':
        return 'Archive';
      case '.exe':
      case '.app':
      case '.dmg':
        return 'Executable';
      case '.js':
      case '.html':
      case '.css':
      case '.dart':
      case '.java':
      case '.py':
      case '.cpp':
      case '.c':
      case '.swift':
      case '.kt':
        return 'Code';
      default:
        return 'File';
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static bool isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg', '.tiff']
        .contains(extension);
  }

  static bool isVideoFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv', '.webm']
        .contains(extension);
  }
}