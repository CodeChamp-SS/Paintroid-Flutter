import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:oxidized/oxidized.dart';
import 'package:paintroid/command/command.dart' show CommandManager;
import 'package:paintroid/io/io.dart';
import 'package:paintroid/workspace/workspace.dart';

class IOHandler {
  final Ref ref;

  const IOHandler(this.ref);

  static final provider = Provider((ref) => IOHandler(ref));

  Future<bool> loadImage(ImageLocation location) async {
    switch (location) {
      case ImageLocation.photos:
        return await _loadFromPhotos();
      case ImageLocation.files:
        return await _loadFromFiles();
    }
  }

  Future<bool> _loadFromPhotos() async {
    final loadImage = ref.read(LoadImageFromPhotoLibrary.provider);
    final result = await loadImage();
    return result.when(
      ok: (img) async {
        ref.read(CanvasState.provider.notifier).clearCanvasAndCommandHistory();
        ref.read(WorkspaceState.provider.notifier).setBackgroundImage(img);
        return true;
      },
      err: (failure) {
        if (failure != LoadImageFailure.userCancelled) {
          showToast(failure.message);
        }
        return false;
      },
    );
  }

  Future<bool> _loadFromFiles() async {
    final loadImage = ref.read(LoadImageFromFileManager.provider);
    final result = await loadImage();
    return result.when(
      ok: (imageFromFile) async {
        ref.read(CanvasState.provider.notifier).clearCanvasAndCommandHistory();
        if (imageFromFile.catrobatImage != null) {
          final commands = imageFromFile.catrobatImage!.commands;
          ref.read(CommandManager.provider).clearHistory(newCommands: commands);
          ref.read(CanvasState.provider.notifier).reCacheImageForAllCommands();
        }
        final workspaceNotifier = ref.read(WorkspaceState.provider.notifier);
        imageFromFile.rasterImage == null
            ? workspaceNotifier.clearBackgroundImageAndResetDimensions()
            : workspaceNotifier.setBackgroundImage(imageFromFile.rasterImage!);
        return true;
      },
      err: (failure) {
        if (failure != LoadImageFailure.userCancelled) {
          showToast(failure.message);
        }
        return false;
      },
    );
  }

  Future<Uint8List> _getProviderFromImage(Image image) async {
    final ByteData? bytedata =
        await image.toByteData(format: ImageByteFormat.png);
    if (bytedata == null) {
      return Future.error("some error msg");
    }
    final Uint8List headedIntList = Uint8List.view(bytedata.buffer);
    return headedIntList;
  }

  Future<File?> saveImage(ImageMetaData imageData) async {
    File? savedFile;
    if (imageData is JpgMetaData || imageData is PngMetaData) {
      await _saveAsRasterImage(imageData);
    } else if (imageData is CatrobatImageMetaData) {
      savedFile = await _saveAsCatrobatImage(imageData);
    }
    return savedFile;
  }

  Future<void> _saveAsRasterImage(ImageMetaData imageData) async {
    final image = await ref
        .read(RenderImageForExport.provider)
        .call(keepTransparency: imageData.format != ImageFormat.jpg);
    await ref.read(SaveAsRasterImage.provider).call(imageData, image).when(
          ok: (_) => showToast("Saved to Photos"),
          err: (failure) => showToast(failure.message),
        );
  }

  Future<Uint8List?> getPreview(ImageMetaData imageData) async {
    final image = await ref
        .read(RenderImageForExport.provider)
        .call(keepTransparency: imageData.format != ImageFormat.jpg);
    final pngImage = await ref.read(IImageService.provider).exportAsPng(image);
    final img = pngImage.when(
      ok: (img) => img,
      err: (failure) {
        showToast(failure.message);
        return null;
      },
    );
    return img;
  }

  Future<File?> _saveAsCatrobatImage(CatrobatImageMetaData imageData) async {
    final commands = ref.read(CommandManager.provider).history;
    final workspaceState = ref.read(WorkspaceState.provider);
    final imgWidth = workspaceState.exportSize.width.toInt();
    final imgHeight = workspaceState.exportSize.height.toInt();
    final catrobatImage = CatrobatImage(
        commands, imgWidth, imgHeight, workspaceState.backgroundImage);
    final saveAsCatrobatImage = ref.read(SaveAsCatrobatImage.provider);
    final result = await saveAsCatrobatImage(imageData, catrobatImage);
    File? savedFile;
    result.when(
      ok: (file) {
        showToast("Saved successfully");
        savedFile = file;
      },
      err: (failure) => showToast(failure.message),
    );
    return savedFile;
  }
}
