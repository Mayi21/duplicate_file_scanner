import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class BreadcrumbNavigator extends StatelessWidget {
  final String? currentPath;
  final Function(String) onPathSelected;

  const BreadcrumbNavigator({
    super.key,
    this.currentPath,
    required this.onPathSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (currentPath == null) return const SizedBox.shrink();

    final parts = _buildPathParts();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_open, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbs(context, parts),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildPathParts() {
    if (currentPath == null) return [];
    
    final parts = <String>[];
    String currentDir = currentPath!;
    
    while (currentDir != path.dirname(currentDir)) {
      parts.insert(0, path.basename(currentDir));
      currentDir = path.dirname(currentDir);
    }
    
    // 添加根目录
    parts.insert(0, Platform.isWindows ? currentDir : '/');
    
    return parts;
  }

  List<Widget> _buildBreadcrumbs(BuildContext context, List<String> parts) {
    final widgets = <Widget>[];
    String currentFullPath = '';
    
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      
      // 构建完整路径
      if (i == 0) {
        currentFullPath = Platform.isWindows ? part : '/';
      } else {
        currentFullPath = path.join(currentFullPath, part);
      }
      
      final isLast = i == parts.length - 1;
      final displayName = _getDisplayName(part, i == 0);
      
      // 面包屑项
      widgets.add(
        InkWell(
          onTap: isLast ? null : () => onPathSelected(currentFullPath),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              displayName,
              style: TextStyle(
                color: isLast 
                    ? Theme.of(context).textTheme.bodyMedium?.color
                    : Theme.of(context).colorScheme.primary,
                fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
      
      // 分隔符
      if (!isLast) {
        widgets.add(
          Icon(
            Icons.chevron_right,
            size: 14,
            color: Colors.grey[500],
          ),
        );
      }
    }
    
    return widgets;
  }

  String _getDisplayName(String part, bool isRoot) {
    if (isRoot) {
      if (Platform.isWindows) {
        return part; // C:\ 等
      } else {
        return 'Root'; // 在 macOS/Linux 上显示 "Root" 而不是 "/"
      }
    }
    
    // 限制长度以避免太长的文件夹名
    if (part.length > 15) {
      return '${part.substring(0, 7)}...${part.substring(part.length - 5)}';
    }
    
    return part;
  }
}