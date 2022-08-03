import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paintroid/data/model/project.dart';
import 'package:paintroid/data/project_database.dart';
import 'package:paintroid/ui/pocket_paint.dart';
import 'package:intl/intl.dart';

import '../io/src/entity/image_location.dart';
import '../io/src/ui/load_image_dialog.dart';
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

class _LandingPageState extends ConsumerState<LandingPage> {
  late ProjectDatabase database;

  @override
  void initState() {
    super.initState();
    $FloorProjectDatabase.databaseBuilder("project_database.db").build().then(
      (db) {
        setState(() => database = db);
      },
    );
  }

  Future<List<Project>> _getProjects() async {
    return await database.projectDAO.getProjects();
  }

  _navigateToPocketPaint() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PocketPaint(),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ioHandler = ref.watch(IOHandler.provider);
    final size = MediaQuery.of(context).size;
    setState(() {});

    return Scaffold(
      backgroundColor: lightColorScheme.primary,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _getProjects(),
        builder: (BuildContext context, AsyncSnapshot<List<Project>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                SizedBox(
                  height: size.height / 3,
                  child: Stack(
                    children: [
                      Material(
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: IconButton(
                          iconSize: 264,
                          onPressed: () {},
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
                  height: size.height / 12,
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
                      // todo: use snapshot to fill the list
                      Project project = snapshot.data![position];
                      print(project);
                      BoxDecoration imagePreview;
                      Uint8List? img = project.imagePreview;
                      if (img != null) {
                        imagePreview = BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(image: MemoryImage(img)));
                      } else {
                        imagePreview = const BoxDecoration(color: Colors.white);
                      }
                      final DateFormat formatter = DateFormat('dd-MM-yyyy');
                      final String lastModified =
                          formatter.format(project.lastModified);

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
                          trailing: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              print('more_vert clicked $position');
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              child: const Icon(Icons.more_vert),
                            ),
                          ),
                          // trailing: const Icon(Icons.more_vert),
                          enabled: true,
                          onTap: () {
                            print('clicked $position');
                          },
                        ),
                      );
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
              late final bool imageLoaded;
              if (Platform.isIOS) {
                final location = await showLoadImageDialog(context);
                if (location == null) return;
                imageLoaded = await ioHandler.loadImage(location);
              } else {
                imageLoaded = await ioHandler.loadImage(ImageLocation.files);
              }
              if (imageLoaded) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PocketPaint(),
                  ),
                );
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
            onPressed: () {
              ref
                  .read(CanvasState.provider.notifier)
                  .clearCanvasAndCommandHistory();
              ref.read(WorkspaceState.provider.notifier).resetWorkspace();
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
