import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxidized/oxidized.dart';
import 'package:paintroid/core/failure.dart';
import 'package:paintroid/core/loggable_mixin.dart';
import 'package:paintroid/io/io.dart';

extension on File {
  String? get extension {
    final list = path.split(".");
    if (list.isEmpty) return null;
    return list.last;
  }
}

class LoadImageFromFileManager with LoggableMixin {
  final IFileService fileService;
  final IImageService imageService;
  final CatrobatImageSerializer catrobatImageSerializer;

  LoadImageFromFileManager(
      this.fileService, this.imageService, this.catrobatImageSerializer);

  static final provider = Provider((ref) {
    final imageService = ref.watch(IImageService.provider);
    final fileService = ref.watch(IFileService.provider);
    const ver = CatrobatImage.latestVersion;
    final serializer = ref.watch(CatrobatImageSerializer.provider(ver));
    return LoadImageFromFileManager(fileService, imageService, serializer);
  });

  Future<Result<ImageFromFile, Failure>> call() {
    return fileService.pick().andThenAsync((file) async {
      try {
        switch (file.extension) {
          case "jpg":
          case "jpeg":
          case "png":
            return imageService
                .import(await file.readAsBytes())
                .map((img) => ImageFromFile.rasterImage(img));
          case "catrobat-image":
            final image =
                catrobatImageSerializer.fromBytes(await file.readAsBytes());
            final hasBackgroundImage = image.backgroundImageData != null &&
                image.backgroundImageData!.isNotEmpty;
            final Result<Option<Image>, Failure> backgroundImageResult =
                (hasBackgroundImage
                    ? await imageService
                        .import(image.backgroundImageData!)
                        .map(Option.some)
                    : Result.ok(Option.none()));
            return backgroundImageResult.map(
              (img) => ImageFromFile.catrobatImage(
                image,
                backgroundImage: img.toNullable(),
              ),
            );
          default:
            return Result.err(LoadImageFailure.invalidImage);
        }
      } on FileSystemException catch (err, stacktrace) {
        logger.severe("Failed to read file", err, stacktrace);
        return Result.err(LoadImageFailure.invalidImage);
      } catch (err, stacktrace) {
        logger.severe("Could not load image", err, stacktrace);
        return Result.err(LoadImageFailure.unidentified);
      }
    });
  }
}
