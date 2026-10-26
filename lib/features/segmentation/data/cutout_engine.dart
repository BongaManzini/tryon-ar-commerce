import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../../../core/utils/image_converter_utils.dart';
import '../domain/models/person_cutout.dart';

/// On-device selfie segmentation engine using Google ML Kit.
class CutoutEngine {
  final _segmenter = SelfieSegmenter(
    mode: SegmenterMode.single,
    enableRawSizeMask: true,
  );

  /// Generates the raw ML Kit segmentation mask from an [InputImage].
  Future<SegmentationMask?> generateMask(InputImage inputImage) async {
    return await _segmenter.processImage(inputImage);
  }

  /// Processes an image from [filePath], runs ML Kit selfie segmentation,
  /// blends with the confidence mask to create an alpha cutout, and returns [PersonCutout].
  Future<PersonCutout> processCutoutFromFile({
    required String filePath,
    double confidenceThreshold = 0.65,
  }) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final mask = await generateMask(inputImage);

      if (mask == null) {
        throw Exception('Segmentation mask generation returned null');
      }

      final fileBytes = await File(filePath).readAsBytes();
      final decodedImage = img.decodeImage(fileBytes);
      if (decodedImage == null) {
        throw Exception('Could not decode image at $filePath');
      }

      // Extract confidences from mask
      final List<double> confidences = mask.confidences;

      final rgbaBytes = ImageConverterUtils.applySegmentationMask(
        originalImage: decodedImage,
        confidenceList: confidences,
        maskWidth: mask.width,
        maskHeight: mask.height,
        confidenceThreshold: confidenceThreshold,
      );

      final uiImage = await ImageConverterUtils.rawBytesToUiImage(
        bytes: rgbaBytes,
        width: decodedImage.width,
        height: decodedImage.height,
      );

      final pngBytes = await ImageConverterUtils.uiImageToPngBytes(uiImage);

      return PersonCutout(
        id: const Uuid().v4(),
        image: uiImage,
        pngBytes: pngBytes,
        width: decodedImage.width,
        height: decodedImage.height,
        capturedAt: DateTime.now(),
        confidenceThreshold: confidenceThreshold,
        isMock: false,
      );
    } catch (e) {
      debugPrint('[CutoutEngine] Fallback to procedural mock cutout due to: $e');
      return generateMockCutout();
    }
  }

  /// Procedural fallback cutout for testing without ML Kit / Camera hardware.
  Future<PersonCutout> generateMockCutout() async {
    final uiImage = await ImageConverterUtils.createMockPersonCutout(
      width: 400,
      height: 800,
      personColor: const Color(0xFF6C63FF),
    );
    final pngBytes = await ImageConverterUtils.uiImageToPngBytes(uiImage);

    return PersonCutout(
      id: const Uuid().v4(),
      image: uiImage,
      pngBytes: pngBytes,
      width: 400,
      height: 800,
      capturedAt: DateTime.now(),
      confidenceThreshold: 1.0,
      isMock: true,
    );
  }

  void dispose() {
    _segmenter.close();
  }
}
