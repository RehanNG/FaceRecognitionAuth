import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';

class FaceDetectorService {
  CameraService _cameraService = locator<CameraService>();

  late FaceDetector _faceDetector;
  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];
  List<Face> get faces => _faces;
  bool get faceDetected => _faces.isNotEmpty;

  void initialize() {
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        // enableContours: true,
        //    enableLandmarks: true,
          // minFaceSize:1.0,
        // enableClassification:true,
      ),
    );

  }


  ///for new version
  // Future<void> detectFacesFromImage(CameraImage image) async {
  //   // InputImageData _firebaseImageMetadata = InputImageData(
  //   //   imageRotation: _cameraService.cameraRotation ?? InputImageRotation.rotation0deg,
  //   //   inputImageFormat: InputImageFormatMethods ?? InputImageFormat.nv21,
  //   //   size: Size(image.width.toDouble(), image.height.toDouble()),
  //   //   planeData: image.planes.map(
  //   //     (Plane plane) {
  //   //       return InputImagePlaneMetadata(
  //   //         bytesPerRow: plane.bytesPerRow,
  //   //         height: plane.height,
  //   //         width: plane.width,
  //   //       );
  //   //     },
  //   //   ).toList(),
  //   // );
  //
  //   final WriteBuffer allBytes = WriteBuffer();
  //   for (Plane plane in image.planes) {
  //     allBytes.putUint8List(plane.bytes);
  //   }
  //   final bytes = allBytes.done().buffer.asUint8List();
  //
  //   final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
  //
  //   InputImageRotation imageRotation = _cameraService.cameraRotation ?? InputImageRotation.rotation0deg;
  //
  //   final inputImageData = InputImageData(
  //     size: imageSize,
  //     imageRotation: imageRotation,
  //     inputImageFormat: InputImageFormat.yuv420,
  //     planeData: image.planes.map(
  //           (Plane plane) {
  //         return InputImagePlaneMetadata(
  //           bytesPerRow: plane.bytesPerRow,
  //           height: plane.height,
  //           width: plane.width,
  //         );
  //       },
  //     ).toList(),
  //   );
  //
  //   InputImage _firebaseVisionImage = InputImage.fromBytes(
  //     bytes: bytes,
  //     inputImageData: inputImageData,
  //   );
  //
  //   _faces = await _faceDetector.processImage(_firebaseVisionImage);
  // }




  //Orignal

  Future<void> detectFacesFromImage(CameraImage image) async {
    InputImageData _firebaseImageMetadata = InputImageData(
      imageRotation:
          _cameraService.cameraRotation ?? InputImageRotation.rotation0deg,



      inputImageFormat: InputImageFormatValue.fromRawValue(image.format.raw)

          ??
          InputImageFormat.yuv_420_888,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      planeData: image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );


    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    InputImage _firebaseVisionImage = InputImage.fromBytes(

      bytes: bytes,
      inputImageData: _firebaseImageMetadata,
    );


    _faces = await _faceDetector.processImage(_firebaseVisionImage);
  }

  Future<List<Face>> detect(CameraImage image, InputImageRotation rotation) {
    final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        // performanceMode: FaceDetectorMode.accurate,
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        minFaceSize:0.8,
          // enableClassification:true,
      ),
    );
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.yuv_420_888;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: rotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return faceDetector.processImage(
      InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData),
    );
  }



  dispose() {
    _faceDetector.close();
  }
}
