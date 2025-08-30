import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../l10n/app_localizations.dart';
import '../utils/file_type_helper.dart';

class FileComparisonView extends StatefulWidget {
  final List<String> filePaths;
  final Function(String)? onFileSelected;

  const FileComparisonView({
    super.key,
    required this.filePaths,
    this.onFileSelected,
  });

  @override
  State<FileComparisonView> createState() => _FileComparisonViewState();
}

class _FileComparisonViewState extends State<FileComparisonView> 
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showDetails = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (widget.filePaths.length < 2) {
      return const Center(
        child: Text('Need at least 2 files for comparison'),
      );
    }

    return Column(
      children: [
        // 对比控制栏
        _buildComparisonControls(context, l10n),
        const Divider(height: 1),
        // 对比内容
        Expanded(
          child: widget.filePaths.length == 2
              ? _buildSideBySideComparison(context, l10n)
              : _buildCarouselComparison(context, l10n),
        ),
      ],
    );
  }

  Widget _buildComparisonControls(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.compare_arrows, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '${l10n.comparing} ${widget.filePaths.length} ${l10n.files}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(_showDetails ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showDetails = !_showDetails;
              });
              if (_showDetails) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
            tooltip: _showDetails ? 'Hide Details' : 'Show Details',
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'side_by_side',
                child: Row(
                  children: [
                    Icon(Icons.view_column, size: 16),
                    SizedBox(width: 8),
                    Text('Side by Side'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'overlay',
                child: Row(
                  children: [
                    Icon(Icons.layers, size: 16),
                    SizedBox(width: 8),
                    Text('Overlay View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'carousel',
                child: Row(
                  children: [
                    Icon(Icons.view_carousel, size: 16),
                    SizedBox(width: 8),
                    Text('Carousel View'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySideComparison(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        // 左侧文件
        Expanded(
          child: _buildFilePanel(
            context,
            widget.filePaths[0],
            'A',
            Colors.blue,
            isSelected: _currentIndex == 0,
            onTap: () => widget.onFileSelected?.call(widget.filePaths[0]),
          ),
        ),
        // 分割线
        Container(
          width: 2,
          color: Theme.of(context).dividerColor,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Icon(
                Icons.compare_arrows,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        // 右侧文件
        Expanded(
          child: _buildFilePanel(
            context,
            widget.filePaths[1],
            'B',
            Colors.red,
            isSelected: _currentIndex == 1,
            onTap: () => widget.onFileSelected?.call(widget.filePaths[1]),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselComparison(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // 文件指示器
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.filePaths.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: index == _currentIndex
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, etc.
                    style: TextStyle(
                      color: index == _currentIndex ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // 轮播视图
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.filePaths.length,
            itemBuilder: (context, index) {
              return _buildFilePanel(
                context,
                widget.filePaths[index],
                String.fromCharCode(65 + index),
                _getFileColor(index),
                isSelected: index == _currentIndex,
                onTap: () => widget.onFileSelected?.call(widget.filePaths[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilePanel(
    BuildContext context,
    String filePath,
    String label,
    Color labelColor, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final file = File(filePath);
    final fileName = path.basename(filePath);
    final fileSize = file.existsSync() ? file.lengthSync() : 0;
    final lastModified = file.existsSync() 
        ? file.lastModifiedSync() 
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: labelColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: labelColor,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onTap != null)
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    onPressed: onTap,
                    tooltip: 'Select this file',
                  ),
              ],
            ),
          ),
          // 文件预览
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: _buildFilePreview(filePath),
              ),
            ),
          ),
          // 详细信息
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _animation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.storage, 'Size', FileTypeHelper.formatFileSize(fileSize)),
                      _buildInfoRow(Icons.access_time, 'Modified', _formatDate(lastModified)),
                      _buildInfoRow(Icons.folder, 'Folder', path.basename(path.dirname(filePath))),
                      _buildInfoRow(Icons.category, 'Type', FileTypeHelper.getFileType(filePath)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(String filePath) {
    if (FileTypeHelper.isImageFile(filePath)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFileIcon(filePath);
          },
        ),
      );
    } else {
      return _buildFileIcon(filePath);
    }
  }

  Widget _buildFileIcon(String filePath) {
    return Container(
      decoration: BoxDecoration(
        color: FileTypeHelper.getFileColor(filePath).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FileTypeHelper.getFileIcon(filePath),
              size: 64,
              color: FileTypeHelper.getFileColor(filePath),
            ),
            const SizedBox(height: 8),
            Text(
              FileTypeHelper.getFileType(filePath),
              style: TextStyle(
                color: FileTypeHelper.getFileColor(filePath),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFileColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}