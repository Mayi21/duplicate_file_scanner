import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../l10n/app_localizations.dart';
import '../providers/file_scanner_provider.dart';
import '../providers/language_provider.dart';
import '../providers/statistics_provider.dart';
import '../screens/statistics_screen.dart';
import '../utils/file_type_helper.dart';
import '../widgets/preview_panel.dart';
import 'video_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final FocusNode _focusNode = FocusNode();
  double _leftPanelWidth = 400;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildSingleFilePreview(BuildContext context, String path) {
    final extension = path.toLowerCase().substring(path.lastIndexOf('.'));
    final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'];
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.wmv'];

    if (imageExtensions.contains(extension)) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(path), fit: BoxFit.contain),
        ),
      );
    } else if (videoExtensions.contains(extension)) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: VideoPreviewScreen(videoPath: path),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FileTypeHelper.getFileIcon(path),
                size: 64,
                color: FileTypeHelper.getFileColor(path),
              ),
              const SizedBox(height: 16),
              Text(
                "${AppLocalizations.of(context)!.noPreviewAvailable}: $extension",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FileScannerProvider>(context);
    final statisticsProvider = Provider.of<StatisticsProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    // 更新统计数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      statisticsProvider.updateData(provider.duplicateFiles);
    });

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) => _handleKeyEvent(event, provider, statisticsProvider, l10n),
      child: Scaffold(
        appBar: _buildAppBar(context, l10n, statisticsProvider),
        body: Column(
          children: [
            _buildControlPanel(context, provider, l10n),
            if (provider.isScanning) _buildProgressSection(context, provider, l10n),
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  // 左侧面板 - 文件列表
                  SizedBox(
                    width: _leftPanelWidth,
                    child: _buildFileListPanel(context, provider, statisticsProvider, l10n),
                  ),
                  // 分割线 + 拖拽调整
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _leftPanelWidth = (_leftPanelWidth + details.delta.dx)
                              .clamp(250.0, MediaQuery.of(context).size.width - 400);
                        });
                      },
                      child: Container(
                        width: 8,
                        color: Colors.grey[300],
                        child: Center(
                          child: Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 右侧面板 - 预览
                  Expanded(
                    child: _buildPreviewPanel(context, provider, l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n, StatisticsProvider stats) {
    return AppBar(
      title: Text(l10n.appTitle),
      actions: [
        // 统计信息按钮
        badges.Badge(
          badgeContent: Text(
            '${stats.totalDuplicateGroups}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          showBadge: stats.totalDuplicateGroups > 0,
          child: IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
            tooltip: l10n.statistics,
          ),
        ),
        // 语言切换
        PopupMenuButton<String>(
          onSelected: (String result) {
            final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
            languageProvider.setLanguage(result);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: 8),
                  Text(l10n.english),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'zh',
              child: Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: 8),
                  Text(l10n.chinese),
                ],
              ),
            ),
          ],
          tooltip: l10n.language,
          child: const Icon(Icons.language),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildControlPanel(BuildContext context, FileScannerProvider provider, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open),
                    onPressed: provider.isScanning ? null : () async {
                      final path = await FilePicker.platform.getDirectoryPath();
                      if (path != null) {
                        provider.setDirectory(Directory(path));
                      }
                    },
                    label: Text(l10n.selectDirectory),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(provider.isScanning ? Icons.pause : Icons.search),
                    onPressed: (provider.selectedDirectory == null)
                        ? null
                        : () {
                            if (provider.isScanning) {
                              // TODO: 实现暂停功能
                            } else {
                              provider.startScan();
                            }
                          },
                    label: Text(provider.isScanning ? l10n.pauseScan : l10n.scan),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            if (provider.selectedDirectory != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.folder, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${l10n.selected}: ${provider.selectedDirectory!.path}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, FileScannerProvider provider, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.scanning,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: provider.progress,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${(provider.progress * 100).toStringAsFixed(1)}%",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.filesScanned,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      "0", // TODO: 实现文件计数
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            if (provider.currentFilePath.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.description, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.currentFilePath,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileListPanel(
    BuildContext context,
    FileScannerProvider provider,
    StatisticsProvider stats,
    AppLocalizations l10n,
  ) {
    if (provider.duplicateFiles.isEmpty && !provider.isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.selectGroupOrFile,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 工具栏
        if (provider.duplicateFiles.isNotEmpty) _buildListToolbar(context, provider, stats, l10n),
        const Divider(height: 1),
        // 文件列表
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              itemCount: provider.duplicateFiles.length,
              itemBuilder: (context, index) {
                final group = provider.duplicateFiles[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildFileGroupTile(context, group, provider, stats, l10n),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListToolbar(
    BuildContext context,
    FileScannerProvider provider,
    StatisticsProvider stats,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          Text(
            "${provider.duplicateFiles.length} ${l10n.duplicateGroups}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (stats.totalSelectedFiles > 0) ...[
            Text(
              "${stats.totalSelectedFiles} ${l10n.selectedFiles}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.delete, size: 16),
              label: Text(l10n.deleteSelected),
              onPressed: () => _deleteSelectedFiles(context, stats, l10n),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileGroupTile(
    BuildContext context,
    dynamic group,
    FileScannerProvider provider,
    StatisticsProvider stats,
    AppLocalizations l10n,
  ) {
    final selectedFiles = stats.getSelectedFilesInGroup(group.hash);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        key: PageStorageKey(group.hash),
        leading: CircleAvatar(
          backgroundColor: FileTypeHelper.getFileColor(group.paths.first),
          child: Text(
            "${group.paths.length}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Icon(
              FileTypeHelper.getFileIcon(group.paths.first),
              color: FileTypeHelper.getFileColor(group.paths.first),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${FileTypeHelper.getFileType(group.paths.first)} • ${FileTypeHelper.formatFileSize(group.size)}",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
        subtitle: Text(
          "${l10n.hash}: ${group.hash.substring(0, 10)}...",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedFiles.isNotEmpty)
              badges.Badge(
                badgeContent: Text(
                  '${selectedFiles.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: () => provider.selectGroupForPreview(group),
            ),
          ],
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            provider.selectGroupForPreview(group);
          }
        },
        children: group.paths.map<Widget>((path) {
          final isSelected = stats.isFileSelected(group.hash, path);
          return Slidable(
            key: Key(path),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _deleteFile(context, group, path, provider, l10n),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: l10n.delete,
                ),
              ],
            ),
            child: ListTile(
              selected: provider.fileForPreview == path,
              contentPadding: const EdgeInsets.only(left: 48, right: 16),
              leading: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  stats.toggleFileSelection(group.hash, path);
                },
              ),
              title: Text(
                path.split('/').last,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                path,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.visibility),
                        const SizedBox(width: 8),
                        Text(l10n.preview),
                      ],
                    ),
                    onTap: () => provider.selectFileForPreview(path),
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () => _deleteFile(context, group, path, provider, l10n),
                  ),
                ],
              ),
              onTap: () => provider.selectFileForPreview(path),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreviewPanel(BuildContext context, FileScannerProvider provider, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          // 预览工具栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  l10n.preview,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (provider.fileForPreview != null) ...[
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      // TODO: 打开文件所在目录
                    },
                    tooltip: "Open in Finder",
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // 预览内容
          Expanded(
            child: provider.fileForPreview != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildSingleFilePreview(context, provider.fileForPreview!),
                  )
                : (provider.groupForPreview != null
                    ? PreviewPanel(fileGroup: provider.groupForPreview!)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.preview, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              l10n.selectGroupOrFile,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )),
          ),
        ],
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event, FileScannerProvider provider, StatisticsProvider stats, AppLocalizations l10n) {
    if (event is KeyDownEvent) {
      // Delete键删除选中的文件
      if (event.logicalKey == LogicalKeyboardKey.delete && stats.totalSelectedFiles > 0) {
        _deleteSelectedFiles(context, stats, l10n);
      }
      // Escape键取消选择
      else if (event.logicalKey == LogicalKeyboardKey.escape) {
        stats.clearAllSelections();
      }
      // Ctrl+A全选
      else if (event.logicalKey == LogicalKeyboardKey.keyA && 
               HardwareKeyboard.instance.isControlPressed) {
        // TODO: 实现全选功能
      }
    }
  }

  void _deleteFile(
    BuildContext context,
    dynamic group,
    String path,
    FileScannerProvider provider,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteFile),
        content: Text("${l10n.deleteConfirmation}\n\n$path"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              try {
                File(path).deleteSync();
                provider.removeFileFromGroup(group.hash, path);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${l10n.errorDeletingFile}: $e")),
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedFiles(BuildContext context, StatisticsProvider stats, AppLocalizations l10n) {
    final selectedFiles = stats.getAllSelectedFiles();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSelected),
        content: Text("${l10n.deleteConfirmation}\n\n${selectedFiles.length} ${l10n.files}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // TODO: 实现批量删除
              Navigator.of(context).pop();
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}