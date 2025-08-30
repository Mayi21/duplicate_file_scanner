import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../l10n/app_localizations.dart';
import '../providers/file_scanner_provider.dart';
import '../providers/language_provider.dart';
import '../providers/statistics_provider.dart';
import '../screens/statistics_screen.dart';
import '../utils/file_type_helper.dart';
import '../widgets/breadcrumb_navigator.dart';
import '../widgets/batch_operation_toolbar.dart';
import '../widgets/file_comparison_view.dart';
import '../widgets/file_info_tile.dart';
import '../widgets/preview_panel.dart';
import 'video_preview_screen.dart';

enum ViewMode { list, comparison, grid }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final FocusNode _focusNode = FocusNode();
  double _leftPanelWidth = 450;
  ViewMode _currentViewMode = ViewMode.list;
  String? _comparisonGroupHash;
  
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(path), fit: BoxFit.contain),
        ),
      );
    } else if (videoExtensions.contains(extension)) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: VideoPreviewScreen(videoPath: path),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
            _buildEnhancedControlPanel(context, provider, l10n),
            if (provider.isScanning) _buildEnhancedProgressSection(context, provider, l10n),
            _buildViewModeSelector(context, l10n),
            const Divider(height: 1),
            Expanded(
              child: _currentViewMode == ViewMode.comparison && _comparisonGroupHash != null
                  ? _buildComparisonView(context, provider, l10n)
                  : Row(
                      children: [
                        // 左侧面板 - 增强的文件列表
                        Container(
                          width: _leftPanelWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(2, 0),
                              ),
                            ],
                          ),
                          child: _buildEnhancedFileListPanel(context, provider, statisticsProvider, l10n),
                        ),
                        // 可拖拽分割线
                        _buildResizableHandle(context),
                        // 右侧面板 - 增强的预览
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: _buildEnhancedPreviewPanel(context, provider, l10n),
                          ),
                        ),
                      ],
                    ),
            ),
            // 批量操作工具栏
            if (statisticsProvider.totalSelectedFiles > 0 || provider.duplicateFiles.isNotEmpty)
              BatchOperationToolbar(
                selectedCount: statisticsProvider.totalSelectedFiles,
                totalCount: statisticsProvider.totalDuplicateFiles,
                onAction: (action) => _handleBatchAction(action, provider, statisticsProvider, l10n),
                isEnabled: !provider.isScanning,
              ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n, StatisticsProvider stats) {
    return AppBar(
      title: Row(
        children: [
          Text(l10n.appTitle),
          const SizedBox(width: 16),
          // 当前语言指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              Provider.of<LanguageProvider>(context).locale.languageCode.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // 统计信息按钮 - 带徽章
        badges.Badge(
          badgeContent: Text(
            '${stats.totalDuplicateGroups}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          showBadge: stats.totalDuplicateGroups > 0,
          child: IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
            tooltip: l10n.statistics,
          ),
        ),
        // 视图模式切换
        PopupMenuButton<ViewMode>(
          icon: const Icon(Icons.view_module_outlined),
          onSelected: (mode) {
            setState(() {
              _currentViewMode = mode;
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ViewMode.list,
              child: Row(
                children: [
                  Icon(Icons.list, 
                    color: _currentViewMode == ViewMode.list ? Theme.of(context).colorScheme.primary : null),
                  const SizedBox(width: 8),
                  const Text('List View'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ViewMode.comparison,
              child: Row(
                children: [
                  Icon(Icons.compare_arrows,
                    color: _currentViewMode == ViewMode.comparison ? Theme.of(context).colorScheme.primary : null),
                  const SizedBox(width: 8),
                  const Text('Comparison View'),
                ],
              ),
            ),
          ],
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
                  const Spacer(),
                  if (Provider.of<LanguageProvider>(context, listen: false).locale.languageCode == 'en')
                    const Icon(Icons.check, color: Colors.green),
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
                  const Spacer(),
                  if (Provider.of<LanguageProvider>(context, listen: false).locale.languageCode == 'zh')
                    const Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
          ],
          tooltip: l10n.language,
          child: const Icon(Icons.translate),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEnhancedControlPanel(BuildContext context, FileScannerProvider provider, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open_outlined),
                    onPressed: provider.isScanning ? null : () async {
                      final path = await FilePicker.platform.getDirectoryPath();
                      if (path != null) {
                        provider.setDirectory(Directory(path));
                      }
                    },
                    label: Text(l10n.selectDirectory),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(provider.isScanning ? Icons.pause_circle_outline : Icons.search_outlined),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      backgroundColor: provider.isScanning ? Colors.orange : null,
                    ),
                  ),
                ),
              ],
            ),
            if (provider.selectedDirectory != null) ...[
              const SizedBox(height: 16),
              // 面包屑导航
              BreadcrumbNavigator(
                currentPath: provider.selectedDirectory?.path,
                onPathSelected: (path) {
                  provider.setDirectory(Directory(path));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedProgressSection(BuildContext context, FileScannerProvider provider, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              value: provider.progress,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.scanning,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${(provider.progress * 100).toStringAsFixed(1)}%",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: provider.progress,
                        backgroundColor: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // 统计信息
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatItem(context, l10n.filesScanned, "0", Icons.description_outlined),
                    _buildStatItem(context, l10n.duplicateGroups, "${provider.duplicateFiles.length}", Icons.group_outlined),
                  ],
                ),
              ],
            ),
            if (provider.currentFilePath.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.currentFilePath.split('/').last,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector(BuildContext context, AppLocalizations l10n) {
    if (_currentViewMode != ViewMode.comparison) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue[50],
      child: Row(
        children: [
          Icon(Icons.compare_arrows, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            'Comparison Mode',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _currentViewMode = ViewMode.list;
                _comparisonGroupHash = null;
              });
            },
            child: const Text('Exit Comparison'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFileListPanel(
    BuildContext context,
    FileScannerProvider provider,
    StatisticsProvider stats,
    AppLocalizations l10n,
  ) {
    if (provider.duplicateFiles.isEmpty && !provider.isScanning) {
      return _buildEmptyState(context, l10n);
    }

    return Column(
      children: [
        // 增强的工具栏
        if (provider.duplicateFiles.isNotEmpty) _buildEnhancedListToolbar(context, provider, stats, l10n),
        const Divider(height: 1),
        // 文件列表
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.duplicateFiles.length,
              itemBuilder: (context, index) {
                final group = provider.duplicateFiles[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildEnhancedFileGroupTile(context, group, provider, stats, l10n),
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No duplicates found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.selectGroupOrFile,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedListToolbar(
    BuildContext context,
    FileScannerProvider provider,
    StatisticsProvider stats,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.group_outlined, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            "${provider.duplicateFiles.length} ${l10n.duplicateGroups}",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${stats.totalDuplicateFiles} ${l10n.files}",
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          if (stats.totalSelectedFiles > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${stats.totalSelectedFiles} ${l10n.selectedFiles}",
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedFileGroupTile(
    BuildContext context,
    dynamic group,
    FileScannerProvider provider,
    StatisticsProvider stats,
    AppLocalizations l10n,
  ) {
    final selectedFiles = stats.getSelectedFilesInGroup(group.hash);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        key: PageStorageKey(group.hash),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: FileTypeHelper.getFileColor(group.paths.first).withOpacity(0.1),
              child: Icon(
                FileTypeHelper.getFileIcon(group.paths.first),
                color: FileTypeHelper.getFileColor(group.paths.first),
              ),
            ),
            if (selectedFiles.isNotEmpty)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${selectedFiles.length}',
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${FileTypeHelper.getFileType(group.paths.first)} • ${FileTypeHelper.formatFileSize(group.size)}",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${group.paths.length}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _getGroupFolderInfo(group.paths),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.compare_arrows_outlined),
              onPressed: () {
                setState(() {
                  _currentViewMode = ViewMode.comparison;
                  _comparisonGroupHash = group.hash;
                });
              },
              tooltip: 'Compare files',
            ),
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () => provider.selectGroupForPreview(group),
              tooltip: l10n.preview,
            ),
          ],
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            provider.selectGroupForPreview(group);
          }
        },
        children: group.paths.map<Widget>((path) {
          final file = File(path);
          final fileStats = file.existsSync() ? file.statSync() : null;
          
          return FileInfoTile(
            filePath: path,
            lastModified: fileStats?.modified,
            fileSize: fileStats?.size,
            isSelected: stats.isFileSelected(group.hash, path),
            onTap: () => provider.selectFileForPreview(path),
            onSelectionChanged: () => stats.toggleFileSelection(group.hash, path),
          );
        }).toList(),
      ),
    );
  }

  String _getGroupFolderInfo(List<String> paths) {
    final folders = paths.map((path) => path.split('/').reversed.skip(1).first).toSet();
    if (folders.length == 1) {
      return "in ${folders.first}";
    } else {
      return "in ${folders.length} folders";
    }
  }

  Widget _buildResizableHandle(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _leftPanelWidth = (_leftPanelWidth + details.delta.dx)
                .clamp(300.0, MediaQuery.of(context).size.width - 300);
          });
        },
        child: Container(
          width: 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.grey[300]!, Colors.transparent],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedPreviewPanel(BuildContext context, FileScannerProvider provider, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // 预览工具栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  l10n.preview,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (provider.fileForPreview != null) ...[
                  IconButton(
                    icon: const Icon(Icons.open_in_new_outlined),
                    onPressed: () {
                      // TODO: 打开文件所在目录
                    },
                    tooltip: l10n.showInFinder,
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen_outlined),
                    onPressed: () {
                      // TODO: 全屏预览
                    },
                    tooltip: "Full Screen",
                  ),
                ],
              ],
            ),
          ),
          // 预览内容
          Expanded(
            child: provider.fileForPreview != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildSingleFilePreview(context, provider.fileForPreview!),
                  )
                : (provider.groupForPreview != null
                    ? PreviewPanel(fileGroup: provider.groupForPreview!)
                    : _buildEmptyPreviewState(context, l10n)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPreviewState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.preview_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
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

  Widget _buildComparisonView(BuildContext context, FileScannerProvider provider, AppLocalizations l10n) {
    final group = provider.duplicateFiles.cast<dynamic>().firstWhere(
      (g) => g.hash == _comparisonGroupHash,
      orElse: () => null,
    );
    
    if (group == null) {
      return Center(
        child: Text('Comparison group not found'),
      );
    }

    return FileComparisonView(
      filePaths: group.paths,
      onFileSelected: (path) {
        provider.selectFileForPreview(path);
      },
    );
  }

  void _handleKeyEvent(KeyEvent event, FileScannerProvider provider, StatisticsProvider stats, AppLocalizations l10n) {
    if (event is KeyDownEvent) {
      // Delete键删除选中的文件
      if (event.logicalKey == LogicalKeyboardKey.delete && stats.totalSelectedFiles > 0) {
        _handleBatchAction(BatchAction.deleteSelected, provider, stats, l10n);
      }
      // Escape键取消选择
      else if (event.logicalKey == LogicalKeyboardKey.escape) {
        stats.clearAllSelections();
      }
      // Ctrl+A全选
      else if (event.logicalKey == LogicalKeyboardKey.keyA && 
               HardwareKeyboard.instance.isControlPressed) {
        _handleBatchAction(BatchAction.selectAll, provider, stats, l10n);
      }
    }
  }

  void _handleBatchAction(BatchAction action, FileScannerProvider provider, StatisticsProvider stats, AppLocalizations l10n) {
    switch (action) {
      case BatchAction.selectAll:
        // TODO: 实现全选所有文件
        break;
      case BatchAction.deselectAll:
        stats.clearAllSelections();
        break;
      case BatchAction.keepNewest:
        // TODO: 实现保留最新文件逻辑
        _showNotImplementedSnackBar(context, l10n.keepNewest);
        break;
      case BatchAction.keepOldest:
        // TODO: 实现保留最旧文件逻辑
        _showNotImplementedSnackBar(context, l10n.keepOldest);
        break;
      case BatchAction.keepLargest:
        // TODO: 实现保留最大文件逻辑
        _showNotImplementedSnackBar(context, l10n.keepLargest);
        break;
      case BatchAction.keepSmallest:
        // TODO: 实现保留最小文件逻辑
        _showNotImplementedSnackBar(context, l10n.keepSmallest);
        break;
      case BatchAction.deleteSelected:
        _showDeleteConfirmation(context, stats, l10n);
        break;
      case BatchAction.moveToTrash:
        _showMoveToTrashConfirmation(context, stats, l10n);
        break;
    }
  }

  void _showNotImplementedSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StatisticsProvider stats, AppLocalizations l10n) {
    final selectedFiles = stats.getAllSelectedFiles();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n.deleteSelected),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${l10n.deleteConfirmation}\n"),
            Text(
              "${selectedFiles.length} ${l10n.files}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "⚠️ This action cannot be undone!",
              style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现批量删除
              Navigator.of(context).pop();
              _showNotImplementedSnackBar(context, l10n.deleteSelected);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMoveToTrashConfirmation(BuildContext context, StatisticsProvider stats, AppLocalizations l10n) {
    final selectedFiles = stats.getAllSelectedFiles();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.moveToTrash),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Move ${selectedFiles.length} ${l10n.files} to trash?"),
            const SizedBox(height: 8),
            Text(
              "You can restore them from trash later.",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现移至回收站
              Navigator.of(context).pop();
              _showNotImplementedSnackBar(context, l10n.moveToTrash);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.moveToTrash, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}