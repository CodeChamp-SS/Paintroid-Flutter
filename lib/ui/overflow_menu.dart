import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paintroid/ui/io_handler.dart';
import 'package:paintroid/workspace/workspace.dart';

import '../data/model/project.dart';
import '../data/project_database.dart';
import '../io/src/ui/save_image_dialog.dart';

enum OverflowMenuOption {
  fullscreen("Fullscreen"),
  saveImage("Save Image"),
  saveProject("Save Project"),
  loadImage("Load Image"),
  newImage("New Image");

  const OverflowMenuOption(this.label);

  final String label;
}

class OverflowMenu extends ConsumerStatefulWidget {
  const OverflowMenu({Key? key}) : super(key: key);

  @override
  ConsumerState<OverflowMenu> createState() => _OverflowMenuState();
}

class _OverflowMenuState extends ConsumerState<OverflowMenu> {
  late final ioHandler = ref.read(IOHandler.provider);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OverflowMenuOption>(
      color: Theme.of(context).colorScheme.background,
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(
        side: const BorderSide(),
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: _handleSelectedOption,
      itemBuilder: (BuildContext context) {
        return OverflowMenuOption.values.map((option) {
          return PopupMenuItem(value: option, child: Text(option.label));
        }).toList();
      },
    );
  }

  void _handleSelectedOption(OverflowMenuOption option) {
    switch (option) {
      case OverflowMenuOption.fullscreen:
        _enterFullscreen();
        break;
      case OverflowMenuOption.saveImage:
        ioHandler.saveImage(context, false);
        break;
      case OverflowMenuOption.saveProject:
        _saveProject();
        break;
      case OverflowMenuOption.loadImage:
        ioHandler.loadImage(context, this);
        break;
      case OverflowMenuOption.newImage:
        ioHandler.newImage(context, this);
        break;
    }
  }

  void _enterFullscreen() =>
      ref.read(WorkspaceState.provider.notifier).toggleFullscreen(true);

  Future<void> _saveProject() async {
    File? savedProject;
    final imageData = await showSaveImageDialog(context, true);

    if (imageData != null) {
      savedProject = await ioHandler.saveImage(context, true);
      Uint8List? imagePreview = await ioHandler.getPreview(imageData);
      if (savedProject != null) {
        print('save path: ${savedProject.path}');
        Project project = Project(
          name: imageData.name,
          path: savedProject.path,
          lastModified: DateTime.now(),
          creationDate: DateTime.now(),
          resolution: "",
          format: imageData.format.name,
          size: await savedProject.length(),
          imagePreview: imagePreview,
        );

        $FloorProjectDatabase
            .databaseBuilder("project_database.db")
            .build()
            .then((db) => db.projectDAO.insertProject(project));
      }

      // MemoryImage(imagePreview)
    }
    // getApplicationDocumentsDirectory()
  }
}
