import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Service responsible for capturing physical garment photos and isolating the garment
/// with transparent background for 3D texture mapping.
class GarmentExtractorService {
  final ImagePicker _picker;

  GarmentExtractorService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Captures a photo of clothing using the device camera.
  Future<File?> snapClothingFromCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.back,
      maxWidth: 1400,
      maxHeight: 1400,
      imageQuality: 92,
    );
    if (file == null) return null;
    return File(file.path);
  }

  /// Picks clothing photo from the gallery.
  Future<File?> pickClothingFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1400,
      maxHeight: 1400,
      imageQuality: 92,
    );
    if (file == null) return null;
    return File(file.path);
  }

  /// Extracts the garment and removes flat background edges, returning transparent PNG bytes.
  Future<Uint8List> extractGarmentSilhouette(File imageFile) async {
    final rawBytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) return rawBytes;

    // Isolate garment: compute background color from corners and apply threshold mask
    final cornerPixel1 = decoded.getPixel(0, 0);
    final cornerPixel2 = decoded.getPixel(decoded.width - 1, 0);
    final avgBgR = (cornerPixel1.r + cornerPixel2.r) / 2.0;
    final avgBgG = (cornerPixel1.g + cornerPixel2.g) / 2.0;
    final avgBgB = (cornerPixel1.b + cornerPixel2.b) / 2.0;

    final output = img.Image(width: decoded.width, height: decoded.height, numChannels: 4);

    for (int y = 0; y < decoded.height; y++) {
      for (int x = 0; x < decoded.width; x++) {
        final pixel = decoded.getPixel(x, y);
        final diffR = (pixel.r - avgBgR).abs();
        final diffG = (pixel.g - avgBgG).abs();
        final diffB = (pixel.b - avgBgB).abs();
        final colorDistance = diffR + diffG + diffB;

        // If pixel is significantly different from background, keep with full alpha
        if (colorDistance > 45) {
          output.setPixelRgba(x, y, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), 255);
        } else {
          output.setPixelRgba(x, y, 0, 0, 0, 0); // Transparent
        }
      }
    }

    return Uint8List.fromList(img.encodePng(output));
  }

  /// Converts image bytes into a data URL for Three.js TextureLoader.
  String bytesToDataUrl(Uint8List bytes) {
    final b64 = base64Encode(bytes);
    return 'data:image/png;base64,$b64';
  }
}
