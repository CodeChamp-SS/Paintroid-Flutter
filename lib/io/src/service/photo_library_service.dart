import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oxidized/oxidized.dart';
import 'package:paintroid/core/failure.dart';
import 'package:paintroid/core/loggable_mixin.dart';

import '../failure/load_image_failure.dart';
import '../failure/save_image_failure.dart';

abstract class IPhotoLibraryService {
  Future<Result<Unit, Failure>> save(String filename, Uint8List data);

  Future<Result<Uint8List, Failure>> pick();

  static final provider = Provider<IPhotoLibraryService>(
    (ref) {
      const photoLibraryChannel =
          MethodChannel("org.catrobat.paintroid/photo_library");
      return PhotoLibraryService(ImagePicker(), photoLibraryChannel);
    },
  );
}

class PhotoLibraryService with LoggableMixin implements IPhotoLibraryService {
  PhotoLibraryService(this.imagePicker, this.photoLibraryChannel);

  final ImagePicker imagePicker;
  final MethodChannel photoLibraryChannel;

  @override
  Future<Result<Unit, Failure>> save(String name, Uint8List data) async {
    try {
      final args = {"fileName": name, "data": data};
      await photoLibraryChannel.invokeMethod("saveToPhotos", args);
      return Result.ok(unit);
    } on PlatformException catch (err, stacktrace) {
      if (err.code == "PERMISSION_DENIED") {
        logger.warning("User explicitly denied permission to save images", err,
            stacktrace);
        return Result.err(SaveImageFailure.permissionDenied);
      } else {
        logger.severe("Could not save photo to library", err, stacktrace);
        return Result.err(SaveImageFailure.unidentified);
      }
    } catch (err, stacktrace) {
      logger.severe("Could not save photo to library", err, stacktrace);
      return Result.err(SaveImageFailure.unidentified);
    }
  }

  @override
  Future<Result<Uint8List, Failure>> pick() async {
    try {
      final file = await imagePicker.pickImage(source: ImageSource.gallery);
      return file == null
          ? Result.err(LoadImageFailure.userCancelled)
          : Result.ok(await file.readAsBytes());
    } on PlatformException catch (err, stacktrace) {
      // This error code is from ImagePicker
      if (err.code == "photo_access_denied") {
        logger.warning("User explicitly denied permission to load images", err,
            stacktrace);
        return Result.err(LoadImageFailure.permissionDenied);
      } else {
        logger.severe("Could not load photo from library", err, stacktrace);
        return Result.err(LoadImageFailure.unidentified);
      }
    } catch (err, stacktrace) {
      logger.severe("Could not load photo from library", err, stacktrace);
      return Result.err(LoadImageFailure.unidentified);
    }
  }
}
