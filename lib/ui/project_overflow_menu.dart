import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paintroid/data/project_database.dart';
import 'package:paintroid/io/src/ui/delete_project_dialog.dart';

import '../data/model/project.dart';

enum ProjectOverflowMenuOption {
  deleteProject("Delete"),
  getDetails("Details");

  const ProjectOverflowMenuOption(this.label);

  final String label;
}

class ProjectOverflowMenu extends ConsumerStatefulWidget {
  final ProjectDatabase database;
  final Project project;

  const ProjectOverflowMenu(
      {Key? key, required this.database, required this.project})
      : super(key: key);

  @override
  ConsumerState<ProjectOverflowMenu> createState() =>
      _ProjectOverFlowMenuState();
}

class _ProjectOverFlowMenuState extends ConsumerState<ProjectOverflowMenu> {
  @override
  Widget build(BuildContext context) => PopupMenuButton(
        color: Theme.of(context).colorScheme.background,
        icon: const Icon(Icons.more_vert),
        shape: RoundedRectangleBorder(
          side: const BorderSide(),
          borderRadius: BorderRadius.circular(20),
        ),
        onSelected: _handleSelectedOption,
        itemBuilder: (BuildContext context) => ProjectOverflowMenuOption.values
            .map((option) =>
                PopupMenuItem(value: option, child: Text(option.label)))
            .toList(),
      );

  void _handleSelectedOption(ProjectOverflowMenuOption option) {
    switch (option) {
      case ProjectOverflowMenuOption.deleteProject:
        _deleteProject();
        break;
      case ProjectOverflowMenuOption.getDetails:
        print('details');
        break;
    }
  }

  Future<void> _deleteProject() async {
    bool? shouldDelete = await showDeleteDialog(context, widget.project.name);
    if (shouldDelete != null && shouldDelete) {
      try {
        final file = File(widget.project.path);
        await file.delete();
      } catch (err, stacktrace) {
        print("$err + $stacktrace.toString()");
      }
      await widget.database.projectDAO.deleteProject(widget.project);
    }
  }
}
