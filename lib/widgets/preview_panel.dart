import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../l10n/app_localizations.dart';
import '../models/file_model.dart';
import '../services/file_operation_service.dart';
import '../utils/file_type_helper.dart';

class PreviewPanel extends StatelessWidget {
  final FileGroup fileGroup;
  final Function(String) onFileTap;

  const PreviewPanel({super.key, required this.fileGroup, required this.onFileTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final previewablePaths = fileGroup.paths.where((path) {
      return FileTypeHelper.isImageFile(path) || FileTypeHelper.isVideoFile(path);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: FileTypeHelper.getFileColor(fileGroup.paths.first),
                        child: Icon(
                          FileTypeHelper.getFileIcon(fileGroup.paths.first),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FileTypeHelper.getFileType(fileGroup.paths.first),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              FileTypeHelper.formatFileSize(fileGroup.size),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "${fileGroup.paths.length} ${l10n.files}",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${l10n.hash}: ${fileGroup.hash.substring(0, 16)}...",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Preview grid
          if (previewablePaths.isNotEmpty) ...[
            Text(
              "${l10n.preview} (${previewablePaths.length}/${fileGroup.paths.length})",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AnimationLimiter(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calculateCrossAxisCount(context),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: previewablePaths.length,
                  itemBuilder: (context, index) {
                    final path = previewablePaths[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: _calculateCrossAxisCount(context),
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: _buildPreviewTile(context, path, index, l10n),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FileTypeHelper.getFileIcon(fileGroup.paths.first),
                      size: 64,
                      color: FileTypeHelper.getFileColor(fileGroup.paths.first),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noPreviewAvailable,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${fileGroup.paths.length} ${FileTypeHelper.getFileType(fileGroup.paths.first)} ${l10n.files}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    return 2;
  }

  Widget _buildPreviewTile(BuildContext context, String path, int index, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => onFileTap(path),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (FileTypeHelper.isImageFile(path))
              Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.broken_image,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  );
                },
              )
            else if (FileTypeHelper.isVideoFile(path))
              Container(
                color: Colors.black87,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            // Overlay with file name and actions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        path.split('/').last,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (FileTypeHelper.isImageFile(path))
                      IconButton(
                        icon: const Icon(Icons.fullscreen, color: Colors.white, size: 18),
                        onPressed: () => onFileTap(path), // Triggers full screen in home_screen
                        tooltip: l10n.fullScreen,
                      ),
                  ],
                ),
              ),
            ),
            // Index indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
