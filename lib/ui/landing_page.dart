import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oxidized/oxidized.dart';
import 'package:paintroid/core/loggable_mixin.dart';
import 'package:paintroid/data/model/project.dart';
import 'package:paintroid/data/project_database.dart';
import 'package:intl/intl.dart';
import 'package:paintroid/ui/project_overflow_menu.dart';

import '../core/failure.dart';
import '../io/src/failure/load_image_failure.dart';
import '../io/src/ui/delete_project_dialog.dart';
import '../workspace/src/state/canvas_state_notifier.dart';
import '../workspace/src/state/workspace_state_notifier.dart';
import 'color_schemes.dart';
import 'io_handler.dart';

class LandingPage extends ConsumerStatefulWidget {
  final String title;

  const LandingPage({Key? key, required this.title}) : super(key: key);

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> with LoggableMixin {
  late ProjectDatabase database;

  @override
  void initState() {
    super.initState();
    final db = ref.read(ProjectDatabase.provider);
    // db.when(data: (database) {this.database = database;}, error: error, loading: loading)
    db.whenData((value) => database = value);
    // $FloorProjectDatabase.databaseBuilder("project_database.db").build().then(
    //   (db) => database = db,
    // );
  }

  Future<List<Project>> _getProjects() async {
    return await database.projectDAO.getProjects();
  }

  void _navigateToPocketPaint() async {
    await Navigator.pushNamed(context, '/PocketPaint');
    setState(() {});
  }

  Result<File, Failure> getFile(String path) {
    try {
      return Result.ok(File(path));
    } catch (err, stacktrace) {
      logger.severe("Could not load file", err, stacktrace);
      return Result.err(LoadImageFailure.unidentified);
    }
  }

  Future<bool> _loadProject(IOHandler ioHandler, Project project) async {
    project.lastModified = DateTime.now();
    await database.projectDAO.insertProject(project);
    return getFile(project.path).when(
      ok: (file) async {
        print(file.lengthSync());
        return await ioHandler.loadFromFiles(getFile(project.path));
      },
      err: (failure) {
        if (failure != LoadImageFailure.userCancelled) {
          showToast(failure.message);
        }
        return false;
      },
    );
  }

  Future<void> _deleteProject(Project project) async {
    bool? shouldDelete = await showDeleteDialog(context, project.name);
    if (shouldDelete != null && shouldDelete) {
      try {
        final file = File(project.path);
        await file.delete();
      } catch (err, stacktrace) {
        showToast(stacktrace.toString());
      }
      await database.projectDAO.deleteProject(project);
      setState(() {});
    }
  }

  Uint8List? _getProjectPreview(String? path) {
    if (path == null) {
      return null;
    }
    try {
      File file = File(path);
      return file.readAsBytesSync();
    } catch (err, stacktrace) {
      showToast(stacktrace.toString());
    }
    return null;
  }

  ImageProvider _getProjectPreviewImageProvider(Uint8List img) {
    return Image.memory(
      img,
      fit: BoxFit.cover,
    ).image;
  }

  @override
  Widget build(BuildContext context) {
    final ioHandler = ref.watch(IOHandler.provider);
    final size = MediaQuery.of(context).size;
    Project? latestModifiedProject;

    return Scaffold(
      backgroundColor: lightColorScheme.primary,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _getProjects(),
        builder: (BuildContext context, AsyncSnapshot<List<Project>> snapshot) {
          if (snapshot.hasData) {
            BoxDecoration bigImg;
            if (snapshot.data!.isNotEmpty) {
              latestModifiedProject = snapshot.data![0];
              bigImg = BoxDecoration(
                color: Colors.white54,
                image: DecorationImage(
                  image: _getProjectPreviewImageProvider(
                    _getProjectPreview(
                        latestModifiedProject!.imagePreviewPath!)!,
                  ),
                ),
              );
            } else {
              bigImg = const BoxDecoration(color: Colors.white54);
            }
            return Column(
              children: [
                SizedBox(
                  height: size.height / 3,
                  child: Stack(
                    children: [
                      Material(
                        child: InkWell(
                          onTap: () async {
                            if (latestModifiedProject != null) {
                              bool loaded = await _loadProject(
                                ioHandler,
                                latestModifiedProject!,
                              );
                              if (loaded) _navigateToPocketPaint();
                            }
                          },
                          child: Container(
                            decoration: bigImg,
                          ),
                        ),
                      ),
                      Center(
                        child: IconButton(
                          iconSize: 264,
                          onPressed: () async {
                            if (latestModifiedProject != null) {
                              bool loaded = await _loadProject(
                                ioHandler,
                                latestModifiedProject!,
                              );
                              if (loaded) _navigateToPocketPaint();
                            }
                          },
                          icon: SvgPicture.asset(
                            "assets/svg/ic_edit_circle.svg",
                            height: 264,
                            width: 264,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  child: Container(
                    color: lightColorScheme.primaryContainer,
                    width: size.width,
                    padding: const EdgeInsets.all(20),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "My Projects",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFFFFFFFF)),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    itemBuilder: (context, position) {
                      Project project = snapshot.data![position];
                      if (project != latestModifiedProject) {
                        BoxDecoration imagePreview;
                        Uint8List? img =
                            _getProjectPreview(project.imagePreviewPath);
                        if (img != null) {
                          // decodeImageFromList(img).then((value) =>
                          //     print("${value.height} X ${value.width}"));
                          imagePreview = BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              image: _getProjectPreviewImageProvider(img),
                            ),
                          );
                        } else {
                          imagePreview =
                              const BoxDecoration(color: Colors.white);
                        }
                        final DateFormat formatter = DateFormat('dd-MM-yyyy');
                        final String lastModified =
                            formatter.format(project.lastModified);

                        void _handleSelectedOption(
                            ProjectOverflowMenuOption option) {
                          switch (option) {
                            case ProjectOverflowMenuOption.deleteProject:
                              _deleteProject(project);
                              break;
                            case ProjectOverflowMenuOption.getDetails:
                              print('details');
                              break;
                          }
                        }

                        return Card(
                          // margin: const EdgeInsets.all(5),
                          child: ListTile(
                            leading: Container(
                              width: 80,
                              decoration: imagePreview,
                            ),
                            dense: false,
                            title: Text(
                              project.name,
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                            subtitle: Text(
                              'last modified: $lastModified',
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                            trailing: PopupMenuButton(
                              color: Theme.of(context).colorScheme.background,
                              icon: const Icon(Icons.more_vert),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onSelected: _handleSelectedOption,
                              itemBuilder: (BuildContext context) =>
                                  ProjectOverflowMenuOption.values
                                      .map((option) => PopupMenuItem(
                                          value: option,
                                          child: Text(option.label)))
                                      .toList(),
                            ),
                            // trailing: const Icon(Icons.more_vert),
                            enabled: true,
                            onTap: () async {
                              bool loaded =
                                  await _loadProject(ioHandler, project);
                              if (loaded) _navigateToPocketPaint();
                            },
                          ),
                        );
                      } else {
                        return const Card();
                      }
                    },
                    itemCount: snapshot.data?.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(0xFFFFDAD6),
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            backgroundColor: const Color(0xFFFFAB08),
            foregroundColor: const Color(0xFFFFFFFF),
            child: const Icon(Icons.file_download),
            onPressed: () async {
              final bool imageLoaded =
                  await ioHandler.loadImage(context, this, false);
              if (imageLoaded && mounted) {
                _navigateToPocketPaint();
              }
            },
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            heroTag: "btn2",
            backgroundColor: const Color(0xFFFFAB08),
            foregroundColor: const Color(0xFFFFFFFF),
            child: const Icon(Icons.add),
            onPressed: () async {
              ref.read(CanvasState.provider.notifier)
                ..clearBackgroundImageAndResetDimensions()
                ..resetCanvasWithNewCommands([]);
              ref
                  .read(WorkspaceState.provider.notifier)
                  .updateLastSavedCommandCount();
              _navigateToPocketPaint();
            },
          ),
        ],
      ),
    );
  }
}

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    Key? key,
    required this.thumbnail,
    required this.title,
    required this.lastModified,
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final int lastModified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: thumbnail,
          ),
          Expanded(
            flex: 3,
            child: ProjectDescription(
              title: title,
              lastModified: lastModified,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              print('more_vert clicked');
            },
            child: Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              child: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectDescription extends StatelessWidget {
  const ProjectDescription({
    Key? key,
    required this.title,
    required this.lastModified,
  }) : super(key: key);

  final String title;
  final int lastModified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            "last modified: $lastModified",
            style: const TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}
