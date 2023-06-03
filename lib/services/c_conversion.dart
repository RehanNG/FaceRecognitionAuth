import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:exif/exif.dart';

// ignore: camel_case_types
typedef convert_func = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);
//conversion service code for c++ files
class ConversionService {
  final DynamicLibrary convertImageLib = Platform.isAndroid
      ? DynamicLibrary.open("libconvertImage.so")
      : DynamicLibrary.process();
  late Convert conv;

  void initialize() {
    // Load the convertImage() function from the library
    conv = convertImageLib
        .lookup<NativeFunction<convert_func>>('convertImage')
        .asFunction<Convert>();
  }

  Future<List<int>?> convertImage(CameraImage inputImage) async {
    imglib.Image img;
    if (Platform.isAndroid) {
      // Allocate memory for the 3 planes of the image
      Pointer<Uint8> p = malloc.allocate(inputImage.planes[0].bytes.length);
      Pointer<Uint8> p1 = malloc.allocate(inputImage.planes[1].bytes.length);
      Pointer<Uint8> p2 = malloc.allocate(inputImage.planes[2].bytes.length);

      // Assign the planes data to the pointers of the image
      Uint8List pointerList = p.asTypedList(inputImage.planes[0].bytes.length);
      Uint8List pointerList1 =
          p1.asTypedList(inputImage.planes[1].bytes.length);
      Uint8List pointerList2 =
          p2.asTypedList(inputImage.planes[2].bytes.length);
      pointerList.setRange(
          0, inputImage.planes[0].bytes.length, inputImage.planes[0].bytes);
      pointerList1.setRange(
          0, inputImage.planes[1].bytes.length, inputImage.planes[1].bytes);
      pointerList2.setRange(
          0, inputImage.planes[2].bytes.length, inputImage.planes[2].bytes);

      // Call the convertImage function and convert the YUV to RGB
      Pointer<Uint32> imgP = conv(
          p,
          p1,
          p2,
          inputImage.planes[1].bytesPerRow,
          inputImage.planes[1].bytesPerPixel!,
          inputImage.planes[0].bytesPerRow,
          inputImage.height);

      // Get the pointer of the data returned from the function to a List
      Uint32List imgData = imgP
          .asTypedList((inputImage.planes[0].bytesPerRow * inputImage.height));
      // Generate image from the converted data
      img = imglib.Image.fromBytes(
          inputImage.height, inputImage.planes[0].bytesPerRow, imgData);

      // Free the memory space allocated
      // from the planes and the converted data
      malloc.free(p);
      malloc.free(p1);
      malloc.free(p2);
      malloc.free(imgP);

      var orientation = await fixExifRotation(imglib.encodeJpg(img));
      return orientation;
    } else if (Platform.isIOS) {
      img = imglib.Image.fromBytes(
        inputImage.planes[0].bytesPerRow,
        inputImage.height,
        inputImage.planes[0].bytes,
        format: imglib.Format.bgra,
      );
      var orientation = await fixExifRotation(imglib.encodeJpg(img));
      return orientation;
    }
    return null;
  }

  Future<List<int>?> fixExifRotation(List<int> bytes) async {
    List<int> imageBytes = bytes;
    final originalImage = imglib.decodeImage(imageBytes);
    imglib.Image fixedImage;
    fixedImage = imglib.copyRotate(originalImage!, 180);
    // fixedImage = imglib.copyRotate(originalImage!, -90);
    // fixedImage = imglib.copyRotate(originalImage!, 0);
    return imglib.encodeJpg(fixedImage);
  }

  Future<File?> fixExifRotation1(String imagePath) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = imglib.decodeImage(imageBytes);
    final height = originalImage!.height;
    final width = originalImage.width;

    // Let's check for the image size
    if (height >= width) {
      // I'm interested in portrait photos so
      // I'll just return here
      return originalFile;
    }

    // We'll use the exif package to read exif data
    // This is map of several exif properties
    // Let's check 'Image Orientation'
    final exifData = await readExifFromBytes(imageBytes);

    imglib.Image fixedImage;

    if (height < width) {
      // rotate
      if (exifData['Image Orientation']!.printable.contains('Horizontal')) {
        fixedImage = imglib.copyRotate(originalImage, 90);
      } else if (exifData['Image Orientation']!.printable.contains('180')) {
        fixedImage = imglib.copyRotate(originalImage, -90);
      } else {
        fixedImage = imglib.copyRotate(originalImage, 0);
      }
      final fixedFile =
          await originalFile.writeAsBytes(imglib.encodeJpg(fixedImage));
      return fixedFile;
    }
    return null;
  }
}
