import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/file_model.dart';
import '../providers/file_scanner_provider.dart';
import 'video_preview_screen.dart';

class FileGroupDetailsScreen extends StatefulWidget {
  final FileGroup fileGroup;

  const FileGroupDetailsScreen({super.key, required this.fileGroup});

  @override
  State<FileGroupDetailsScreen> createState() => _FileGroupDetailsScreenState();
}

class _FileGroupDetailsScreenState extends State<FileGroupDetailsScreen> {
  late List<String> _paths;

  final _imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'];
  final _videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.wmv'];

  @override
  void initState() {
    super.initState();
    _paths = List.from(widget.fileGroup.paths);
  }

  void _deleteFile(String path) {
    final provider = Provider.of<FileScannerProvider>(context, listen: false);
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
                setState(() {
                  _paths.remove(path);
                });
                provider.removeFileFromGroup(widget.fileGroup.hash, path);
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
  }

  void _previewFile(String path) {
    final extension = path.toLowerCase().substring(path.lastIndexOf('.'));

    if (_imageExtensions.contains(extension)) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Image.file(File(path)),
        ),
      );
    } else if (_videoExtensions.contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPreviewScreen(videoPath: path),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This file type is not supported for preview.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hash: ${widget.fileGroup.hash.substring(0, 10)}..."),
      ),
      body: ListView.builder(
        itemCount: _paths.length,
        itemBuilder: (context, index) {
          final path = _paths[index];
          return ListTile(
            onTap: () => _previewFile(path),
            leading: const Icon(Icons.insert_drive_file),
            title: Text(path.split('/').last),
            subtitle: Text(path),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFile(path),
            ),
          );
        },
      ),
    );
  }
}