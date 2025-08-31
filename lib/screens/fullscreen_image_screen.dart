
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullscreenImageScreen extends StatelessWidget {
  final String imagePath;

  const FullscreenImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        child: PhotoView(
          imageProvider: FileImage(File(imagePath)),
          heroAttributes: PhotoViewHeroAttributes(tag: imagePath),
        ),
      ),
    );
  }
}
