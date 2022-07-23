import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paintroid/ui/pocket_paint.dart';

import 'color_schemes.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      title: 'Pocket Paint',
      theme: ThemeData.from(useMaterial3: true, colorScheme: lightColorScheme),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Pocket Paint"),
        ),
        body: SizedBox(
          height: size.height / 3,
          child: Stack(
            children: [
              const Placeholder(),
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
              child: const Icon(Icons.file_download),
              onPressed: () {},
            ),
            const SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              heroTag: "btn2",
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
