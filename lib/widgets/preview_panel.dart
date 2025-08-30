import 'dart:io';

import 'package:flutter/material.dart';

import '../models/file_model.dart';

class PreviewPanel extends StatelessWidget {
  final FileGroup fileGroup;

  const PreviewPanel({super.key, required this.fileGroup});

  final _imageExtensions = const ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'];

  @override
  Widget build(BuildContext context) {
    final previewablePaths = fileGroup.paths.where((p) {
      final ext = p.toLowerCase().substring(p.lastIndexOf('.'));
      return _imageExtensions.contains(ext); // For now, only images in grid
    }).toList();

    if (previewablePaths.isEmpty) {
      return const Center(
        child: Text("No image previews for this group."),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // More items for a panel view
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: previewablePaths.length,
      itemBuilder: (context, index) {
        final path = previewablePaths[index];
        return Image.file(File(path), fit: BoxFit.cover);
      },
    );
  }
}
