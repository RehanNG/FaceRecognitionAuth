import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:face_net_authentication/pages/db/databse_helper.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/services/image_converter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

import 'c_conversion.dart';

class MLService {
  Interpreter? _interpreter;
  // double threshold = 0.5;
  //better accuracy
  // double threshold = 0.8;
  double threshold = 0.90;
  // double threshold = 0.75;
  List _predictedData = [];
  List get predictedData => _predictedData;
  final ConversionService _conversionService = ConversionService();
  Future initialize() async {
    late Delegate delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
          options: GpuDelegateOptionsV2 (
            isPrecisionLossAllowed: false,
            inferencePreference: TfLiteGpuInferenceUsage.preferenceSustainSpeed,
            inferencePriority1: TfLiteGpuInferencePriority.minLatency,
            inferencePriority2: TfLiteGpuInferencePriority.maxPrecision,
            inferencePriority3: TfLiteGpuInferencePriority.auto,
          ),
        );
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
              allowPrecisionLoss: true,
              waitType: TFLGpuDelegateWaitType.active),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      this._interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  void setCurrentPrediction(CameraImage cameraImage, Face? face) {
    if (_interpreter == null) throw Exception('Interpreter is null');
    if (face == null) throw Exception('Face is null');
    List input = _preProcess(cameraImage, face);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));
    this._interpreter?.run(input, output);
    output = output.reshape([192]);
    this._predictedData = List.from(output);
  }

  Future<User?> predict() /*async*/ {
    return _searchResult(this._predictedData);
  }

  //work with this modify this
   List/*new aded3 <double>*/<double> _preProcess (CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);
    //orgnal1
    // Float32List imageAsList = imageToByteListFloat32(img);
    // return imageAsList;

    //new added2
    Uint8List imageAsList = imageToByteListUint8(img);
    print("Imageaslist ka variable   $imageAsList");

    return imageAsList.map((e) => (e - 127.5) / 128).toList();
  }
  //new added1
  Uint8List imageToByteListUint8(imglib.Image image) {
    var convertedBytes = Uint8List(1 * 112 * 112 * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = imglib.getRed(pixel);
        buffer[pixelIndex++] = imglib.getGreen(pixel);
        buffer[pixelIndex++] = imglib.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img, -90);
    return img1;
  }

  //orignal
  Float32List imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 127.5) / 128;
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 127.5) / 128;
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 127.5) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  //users searching in model stored
  Future<User?> _searchResult(List predictedData) async {
    //for eucledian and cosine distance algorithm I used this
    // DatabaseHelper _dbHelper = DatabaseHelper.instance;
    // List<User> users = await _dbHelper. queryAllUsers();
    List<User> users = await DatabaseHelper.queryAllUsers();
    // double minDist = 999;
    double minDist = double.infinity;
    double currDist = 0.0;
    User? predictedResult;
    //`users.length` is used to print the number of users stored in the database
    print('users.length=> ${users.length}');
    for (User u in users) {
      currDist = _euclideanDistance(u.modelData, predictedData);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predictedResult = u;
      }
    }
    return predictedResult;
  }

  double _euclideanDistance(List? e1, List? e2) {

//Eucleadian Algorithm , its better accurate
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);



    //Eucledian v0

    // if (e1 == null || e2 == null) throw Exception("Null argument");
    //
    // double sum = 0.0;
    // double c = 0.0;
    // for (int i = 0; i < e1.length; i++) {
    //   double y = (e1[i] - e2[i]) * (e1[i] - e2[i]) - c;
    //   double t = sum + y;
    //   c = (t - sum) - y;
    //   sum = t;
    // }
    // return sqrt(sum);





    //cosine distance metric algorithm
    // if (e1 == null || e2 == null) throw Exception("Null argument");
    //
    // double dotProduct = 0.0;
    // double normE1 = 0.0;
    // double normE2 = 0.0;
    //
    // for (int i = 0; i < e1.length; i++) {
    //   dotProduct += e1[i] * e2[i];
    //   normE1 += pow(e1[i], 2);
    //   normE2 += pow(e2[i], 2);
    // }
    //
    // normE1 = sqrt(normE1);
    // normE2 = sqrt(normE2);
    //
    // return 1 - (dotProduct / (normE1 * normE2));


  }

  void setPredictedData(value) {
    this._predictedData = value;
  }

  dispose() {}
}
