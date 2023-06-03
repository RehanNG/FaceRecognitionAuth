// import 'dart:io';
// import 'dart:ui';
//
// import 'package:camera/camera.dart';
// import 'package:face_net_authentication/pages/sign-in.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:sqflite/sqflite.dart';
//
// class CameraService {
//   CameraController? _cameraController;
//   CameraController? get cameraController => this._cameraController;
//
//   InputImageRotation? _cameraRotation;
//   InputImageRotation? get cameraRotation => this._cameraRotation;
//
//   String? _imagePath;
//   String? get imagePath => this._imagePath;
//
//   Future<void> initialize() async {
//     if (_cameraController != null) return;
//     CameraDescription description = await _getCameraDescription();
//     await _setupCameraController(description: description);
//     this._cameraRotation = rotationIntToImageRotation(
//       description.sensorOrientation,
//     );
//   }
//
//   Future<CameraDescription> _getCameraDescription() async {
//     List<CameraDescription> cameras = await availableCameras();
//     return cameras.firstWhere((CameraDescription camera) =>
//         camera.lensDirection == CameraLensDirection.front);
//   }
//
//   Future _setupCameraController({
//     required CameraDescription description,
//   }) async {
//     this._cameraController = CameraController(
//       description,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//     await _cameraController?.initialize();
//   }
//
//   InputImageRotation rotationIntToImageRotation(int rotation) {
//     switch (rotation) {
//       case 90:
//         return InputImageRotation.rotation90deg;
//       case 180:
//         return InputImageRotation.rotation180deg;
//       case 270:
//         return InputImageRotation.rotation270deg;
//       default:
//         return InputImageRotation.rotation0deg;
//     }
//   }
//
//   Future<File> takePicture() async {
//
//     assert(_cameraController != null, 'Camera controller not initialized');
//     await _cameraController?.stopImageStream();
//     XFile? file = await _cameraController?.takePicture();
//     _imagePath = file?.path;
//
//
//
//     return File(file!.path) ;
//     // return file;
//   }
//
//
//   Future<dynamic> verifyRealTimeFace(String encodeImage) async {
//     // Open the database , my_database.db -> database name
//     final db = await openDatabase('my_database.db');
//
//     // Query the database for a matching face image
//     // registered -> my table name
//     // image -> column name
//     final result = await db.query(
//       'registered',
//       where: 'image = ?',
//       whereArgs: [encodeImage],
//     );
//
//     // Close the database
//     await db.close();
//
//     // Return the result
//     return result.isNotEmpty;
//   }
// /*
// In this example, we're opening the database, querying the `registered` table for a matching face image,
//  closing the database, and returning a boolean value indicating whether a match was found or not.
//   This is just one example of how we could modify the code to work with an sqflite database in Flutter.
// The specific implementation would depend on the structure of the database and the requirements of the application.
// * */
//
//
//   Size getImageSize() {
//     assert(_cameraController != null, 'Camera controller not initialized');
//     assert(
//         _cameraController!.value.previewSize != null, 'Preview size is null');
//     return Size(
//       _cameraController!.value.previewSize!.height,
//       _cameraController!.value.previewSize!.width,
//     );
//   }
//
//   dispose() async {
//     await this._cameraController?.dispose();
//     this._cameraController = null;
//   }
// }



import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:face_net_authentication/pages/sign-in.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class CameraService extends GetxService {
  CameraController? _cameraController;
  CameraController? get cameraController => this._cameraController;

  InputImageRotation? _cameraRotation;
  InputImageRotation? get cameraRotation => this._cameraRotation;

  String? _imagePath;
  String? get imagePath => this._imagePath;

  Future<void> initialize() async {
    if (_cameraController != null) return;
    CameraDescription description = await _getCameraDescription();
    await _setupCameraController(description: description);
    this._cameraRotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
  }

  Future<CameraDescription> _getCameraDescription() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere((CameraDescription camera) =>
    camera.lensDirection == CameraLensDirection.front);
  }

  Future _setupCameraController({
    required CameraDescription description,
  }) async {
    this._cameraController = CameraController(
      description,
      ResolutionPreset.low,
      enableAudio: false,
    );
    await _cameraController?.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<File> takePicture() async {
    assert(_cameraController != null, 'Camera controller not initialized');
    await _cameraController?.stopImageStream();
    XFile? file = await _cameraController?.takePicture();
    _imagePath = file?.path;
    return File(file!.path);
  }

  Future<dynamic> verifyRealTimeFace(String encodeImage) async {
    // Open the database , my_database.db -> database name
    final db = await openDatabase('my_database.db');

    // Query the database for a matching face image
    // registered -> my table name
    // image -> column name
    final result = await db.query(
      'registered',
      where: 'image = ?',
      whereArgs: [encodeImage],
    );

    // Close the database
    await db.close();

    // Return the result
    return result.isNotEmpty;
  }

  Size getImageSize() {
    assert(_cameraController != null, 'Camera controller not initialized');
    assert(
    _cameraController!.value.previewSize != null, 'Preview size is null');
    return Size(
      _cameraController!.value.previewSize!.height,
      _cameraController!.value.previewSize!.width,
    );
  }

  @override
  void onClose() async {
    await this._cameraController?.dispose();
    this._cameraController = null;
    super.onClose();
  }
}



