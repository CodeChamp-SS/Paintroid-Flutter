import 'dart:typed_data';

import 'package:floor/floor.dart';

@entity
class Project {
  final String name;
  final String path;
  final DateTime lastModified;
  final DateTime creationDate;
  final String? resolution;
  final String? format;
  final int? size;
  final Uint8List? imagePreview;
  @PrimaryKey(autoGenerate: true)
  final int? id;

  Project({
    required this.name,
    required this.path,
    required this.lastModified,
    required this.creationDate,
    this.resolution,
    this.format,
    this.size,
    this.imagePreview,
    this.id,
  });
}
