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
    return MaterialApp(
      title: 'Pocket Paint',
      theme: ThemeData.from(useMaterial3: true, colorScheme: lightColorScheme),
      home: Scaffold(
        backgroundColor: lightColorScheme.primary,
        appBar: AppBar(
          title: const Text("Pocket Paint"),
        ),
        body: SizedBox(
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
