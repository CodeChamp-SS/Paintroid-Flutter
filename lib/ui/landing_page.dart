import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paintroid/ui/pocket_paint.dart';

import '../io/src/entity/image_location.dart';
import '../io/src/ui/load_image_dialog.dart';
import 'color_schemes.dart';
import 'io_handler.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ioHandler = ref.watch(IOHandler.provider);
    final size = MediaQuery.of(context).size;

    final tempList = [
      "project 1",
      "project 2",
      "project 3",
      "project 4",
      "project 5",
      "project 6"
    ];

    return MaterialApp(
      title: 'Pocket Paint',
      theme: ThemeData.from(useMaterial3: true, colorScheme: lightColorScheme),
      home: Scaffold(
        backgroundColor: lightColorScheme.primary,
        appBar: AppBar(
          title: const Text("Pocket Paint"),
        ),
        body: Column(
          children: [
            SizedBox(
              height: size.height / 3,
              child: Stack(
                children: [
                  Material(
                    child: InkWell(
                      onTap: () {},
                      child: const Placeholder(),
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
                  return Card(
                    // margin: const EdgeInsets.all(5),
                    child: ListTile(
                      leading:Container(
                        width: 80,
                        decoration: const BoxDecoration(color: Colors.white),
                      ),
                      dense: false,
                      title: Text(
                        tempList[position],
                        style: const TextStyle(color: Color(0xFFFFFFFF)),
                      ),
                      subtitle: const Text(
                        'last modified:',
                        style: TextStyle(color: Color(0xFFFFFFFF)),
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
                itemCount: tempList.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
              ),
            ),
          ],
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PocketPaint(),
                  ),
                );
                if (Platform.isIOS) {
                  final location = await showLoadImageDialog(context);
                  if (location == null) return;
                  ioHandler.loadImage(location);
                } else {
                  ioHandler.loadImage(ImageLocation.files);
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PocketPaint(),
                  ),
                );
              },
            ),
          ],
        ),
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
