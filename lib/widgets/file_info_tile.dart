import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../utils/file_type_helper.dart';

class FileInfoTile extends StatefulWidget {
  final String filePath;
  final DateTime? lastModified;
  final int? fileSize;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onSelectionChanged;

  const FileInfoTile({
    super.key,
    required this.filePath,
    this.lastModified,
    this.fileSize,
    this.isSelected = false,
    this.onTap,
    this.onSelectionChanged,
  });

  @override
  State<FileInfoTile> createState() => _FileInfoTileState();
}

class _FileInfoTileState extends State<FileInfoTile> {
  Uint8List? _thumbnailData;
  bool _thumbnailLoading = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  void _loadThumbnail() async {
    if (!FileTypeHelper.isImageFile(widget.filePath)) return;
    
    setState(() {
      _thumbnailLoading = true;
    });

    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (mounted && bytes.length < 50 * 1024 * 1024) { // 限制50MB以下的图片
          setState(() {
            _thumbnailData = bytes;
            _thumbnailLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _thumbnailLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(widget.filePath);
    final folderPath = path.dirname(widget.filePath);
    final folderName = path.basename(folderPath);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      elevation: widget.isSelected ? 4 : 1,
      color: widget.isSelected 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // 缩略图或文件图标
              SizedBox(
                width: 48,
                height: 48,
                child: _buildThumbnail(),
              ),
              const SizedBox(width: 12),
              // 文件信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 文件名 (智能截断)
                    Text(
                      _smartTruncate(fileName, 30),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // 文件夹路径
                    Row(
                      children: [
                        Icon(Icons.folder, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            folderName.isEmpty ? 'Root' : folderName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // 文件信息行
                    Row(
                      children: [
                        // 文件大小
                        if (widget.fileSize != null) ...[
                          Icon(Icons.storage, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Text(
                            FileTypeHelper.formatFileSize(widget.fileSize!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // 修改时间
                        if (widget.lastModified != null) ...[
                          Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              _formatDate(widget.lastModified!),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // 选择框和操作按钮
              Column(
                children: [
                  if (widget.onSelectionChanged != null)
                    Checkbox(
                      value: widget.isSelected,
                      onChanged: (_) => widget.onSelectionChanged?.call(),
                      visualDensity: VisualDensity.compact,
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'show_in_finder',
                        child: Row(
                          children: [
                            Icon(Icons.folder_open, size: 16),
                            SizedBox(width: 8),
                            Text('Show in Finder'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'keep_this',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('Keep This'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleMenuAction(value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (FileTypeHelper.isImageFile(widget.filePath)) {
      if (_thumbnailLoading) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      } else if (_thumbnailData != null) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              _thumbnailData!,
              fit: BoxFit.cover,
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) {
                return _buildFileIcon();
              },
            ),
          ),
        );
      }
    }
    
    return _buildFileIcon();
  }

  Widget _buildFileIcon() {
    return Container(
      decoration: BoxDecoration(
        color: FileTypeHelper.getFileColor(widget.filePath).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: FileTypeHelper.getFileColor(widget.filePath).withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Icon(
          FileTypeHelper.getFileIcon(widget.filePath),
          color: FileTypeHelper.getFileColor(widget.filePath),
          size: 24,
        ),
      ),
    );
  }

  String _smartTruncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    
    const ellipsis = '...';
    final availableLength = maxLength - ellipsis.length;
    final frontLength = (availableLength / 2).floor();
    final backLength = availableLength - frontLength;
    
    return text.substring(0, frontLength) + 
           ellipsis + 
           text.substring(text.length - backLength);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'show_in_finder':
        _showInFinder();
        break;
      case 'keep_this':
        _keepThis();
        break;
      case 'delete':
        _deleteFile();
        break;
    }
  }

  void _showInFinder() {
    // TODO: 实现在 Finder 中显示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Show in Finder: ${widget.filePath}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _keepThis() {
    // TODO: 实现保留此文件逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marked as keep'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteFile() {
    // TODO: 实现删除文件逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delete functionality'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}