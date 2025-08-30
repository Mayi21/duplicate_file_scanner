import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/file_scanner_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/preview_panel.dart';

import 'video_preview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildSingleFilePreview(BuildContext context, String path) {
    final extension = path.toLowerCase().substring(path.lastIndexOf('.'));
    final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'];
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.wmv'];

    if (imageExtensions.contains(extension)) {
      return Image.file(File(path), fit: BoxFit.contain);
    } else if (videoExtensions.contains(extension)) {
      return VideoPreviewScreen(videoPath: path);
    } else {
      return Center(child: Text("${AppLocalizations.of(context)!.noPreviewAvailable}: $extension"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FileScannerProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
              languageProvider.setLanguage(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'en',
                child: Text(l10n.english),
              ),
              PopupMenuItem<String>(
                value: 'zh',
                child: Text(l10n.chinese),
              ),
            ],
            child: Icon(Icons.language),
          ),
        ],
      ),
      body: Column(
        children: [
          // TOP CONTROLS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  onPressed: provider.isScanning ? null : () async {
                    final path = await FilePicker.platform.getDirectoryPath();
                    if (path != null) {
                      provider.setDirectory(Directory(path));
                    }
                  },
                  label: Text(l10n.selectDirectory),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  onPressed: (provider.selectedDirectory == null || provider.isScanning)
                      ? null
                      : () => provider.startScan(),
                  label: Text(l10n.scan),
                ),
              ],
            ),
          ),
          if (provider.selectedDirectory != null && !provider.isScanning)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("${l10n.selected}: ${provider.selectedDirectory!.path}", style: Theme.of(context).textTheme.bodySmall),
            ),
          if (provider.isScanning)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: Column(
                children: [
                  LinearProgressIndicator(value: provider.progress),
                  const SizedBox(height: 4),
                  Text("${(provider.progress * 100).toStringAsFixed(1)}% - ${provider.currentFilePath}", overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          const Divider(height: 1),
          // MAIN AREA
          Expanded(
            child: Row(
              children: [
                // LEFT PANEL - RESULTS
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: provider.duplicateFiles.length,
                    itemBuilder: (context, index) {
                      final group = provider.duplicateFiles[index];
                      return ExpansionTile(
                        key: PageStorageKey(group.hash), // Keep expansion state
                        leading: CircleAvatar(child: Text("${group.paths.length}")),
                        title: Text("${l10n.hash}: ${group.hash.substring(0, 10)}..."),
                        subtitle: Text("${l10n.size}: ${group.size} ${l10n.bytes}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.preview),
                              onPressed: () => provider.selectGroupForPreview(group),
                            ),
                            const Icon(Icons.expand_more), // Default expand icon
                          ],
                        ),
                        children: group.paths.map((path) {
                          return ListTile(
                            selected: provider.fileForPreview == path,
                            contentPadding: const EdgeInsets.only(left: 32.0), // Indent
                            title: Text(path.split('/').last),
                            subtitle: Text(path),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Delete logic (from FileGroupDetailsScreen)
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
                                        child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            onTap: () => provider.selectFileForPreview(path),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1),
                // RIGHT PANEL - PREVIEW
                Expanded(
                  flex: 3,
                  child: provider.fileForPreview != null
                      ? _buildSingleFilePreview(context, provider.fileForPreview!)
                      : (provider.groupForPreview != null
                          ? PreviewPanel(fileGroup: provider.groupForPreview!)
                          : Center(child: Text(l10n.selectGroupOrFile)))
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}