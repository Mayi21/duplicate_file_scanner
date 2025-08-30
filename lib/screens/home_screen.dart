import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/file_model.dart';
import '../providers/file_scanner_provider.dart';
import '../widgets/preview_panel.dart';
import 'file_group_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FileScannerProvider>(context);
    final selectedGroup = provider.selectedGroupForPreview;

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
                      return ListTile(
                        selected: selectedGroup == group,
                        leading: CircleAvatar(child: Text("${group.paths.length}")),
                        title: Text("Hash: ${group.hash.substring(0, 10)}..."),
                        subtitle: Text("Size: ${group.size} bytes"),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FileGroupDetailsScreen(fileGroup: group),
                              ),
                            );
                          },
                        ),
                        onTap: () => provider.selectGroupForPreview(group),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1),
                // RIGHT PANEL - PREVIEW
                Expanded(
                  flex: 3,
                  child: selectedGroup != null
                      ? PreviewPanel(fileGroup: selectedGroup)
                      : const Center(child: Text("Select a group to preview"))
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}