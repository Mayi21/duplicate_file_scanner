
import 'package:flutter/foundation.dart';

@immutable
class FileGroup {
  final String hash;
  final int size;
  final List<String> paths;

  const FileGroup({
    required this.hash,
    required this.size,
    required this.paths,
  });
}
