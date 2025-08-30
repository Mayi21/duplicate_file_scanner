import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/file_model.dart';
import '../providers/file_scanner_provider.dart';
import '../widgets/preview_panel.dart';

import 'video_preview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildSingleFilePreview(String path) {
    final extension = path.toLowerCase().substring(path.lastIndexOf('.'));
    final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'];
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.wmv'];

    if (imageExtensions.contains(extension)) {
      return Image.file(File(path), fit: BoxFit.contain);
    } else if (videoExtensions.contains(extension)) {
      return VideoPreviewScreen(videoPath: path);
    } else {
      return Center(child: Text("No preview available for this file type: $extension"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FileScannerProvider>(context);
    final selectedGroup = provider.groupForPreview;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Duplicate File Scanner"),
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
                  label: const Text("Select Directory"),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  onPressed: (provider.selectedDirectory == null || provider.isScanning)
                      ? null
                      : () => provider.startScan(),
                  label: const Text("Scan"),
                ),
              ],
            ),
          ),
          if (provider.selectedDirectory != null && !provider.isScanning)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Selected: ${provider.selectedDirectory!.path}", style: Theme.of(context).textTheme.bodySmall),
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
                        title: Text("Hash: ${group.hash.substring(0, 10)}..."),
                        subtitle: Text("Size: ${group.size} bytes"),
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
                                    title: const Text("Delete File?"),
                                    content: Text("Are you sure you want to permanently delete this file?\n\n$path"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          try {
                                            File(path).deleteSync();
                                            provider.removeFileFromGroup(group.hash, path);
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error deleting file: $e")),
                                            );
                                          }
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
                      ? _buildSingleFilePreview(provider.fileForPreview!)
                      : (provider.groupForPreview != null
                          ? PreviewPanel(fileGroup: provider.groupForPreview!)
                          : const Center(child: Text("Select a group or file to preview")))
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}