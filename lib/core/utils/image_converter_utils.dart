import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Utility for converting between raw byte buffers, ML Kit masks, and Flutter [ui.Image] objects.
class ImageConverterUtils {
  /// Converts raw RGBA/BGRA byte buffer into a Flutter [ui.Image].
  static Future<ui.Image> rawBytesToUiImage({
    required Uint8List bytes,
    required int width,
    required int height,
    ui.PixelFormat pixelFormat = ui.PixelFormat.rgba8888,
  }) {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      width,
      height,
      pixelFormat,
      (ui.Image result) {
        completer.complete(result);
      },
    );
    return completer.future;
  }

  /// Encodes a [ui.Image] to PNG bytes.
  static Future<Uint8List?> uiImageToPngBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// Blends an original [img.Image] with a ML Kit confidence mask buffer.
  ///
  /// For every pixel:
  /// - Reads confidence value (0.0 to 1.0)
  /// - If confidence < [confidenceThreshold], alpha = 0 (transparent background)
  /// - If confidence >= [confidenceThreshold], alpha = smooth step / full opacity
  static Uint8List applySegmentationMask({
    required img.Image originalImage,
    required List<double> confidenceList,
    required int maskWidth,
    required int maskHeight,
    double confidenceThreshold = 0.65,
  }) {
    final int origWidth = originalImage.width;
    final int origHeight = originalImage.height;

    // Output buffer in RGBA8888 format (4 bytes per pixel)
    final Uint8List rgbaOutput = Uint8List(origWidth * origHeight * 4);

    final double scaleX = maskWidth / origWidth;
    final double scaleY = maskHeight / origHeight;

    int outOffset = 0;
    for (int y = 0; y < origHeight; y++) {
      final int maskY = (y * scaleY).toInt().clamp(0, maskHeight - 1);
      final int maskRowOffset = maskY * maskWidth;

      for (int x = 0; x < origWidth; x++) {
        final int maskX = (x * scaleX).toInt().clamp(0, maskWidth - 1);
        final double confidence = confidenceList[maskRowOffset + maskX];

        final pixel = originalImage.getPixel(x, y);

        if (confidence >= confidenceThreshold) {
          // Smooth alpha transition around edges
          final double edgeSmooth = ((confidence - confidenceThreshold) / (1.0 - confidenceThreshold)).clamp(0.0, 1.0);
          final int alpha = (edgeSmooth * 255).toInt();

          rgbaOutput[outOffset] = pixel.r.toInt();     // R
          rgbaOutput[outOffset + 1] = pixel.g.toInt(); // G
          rgbaOutput[outOffset + 2] = pixel.b.toInt(); // B
          rgbaOutput[outOffset + 3] = alpha;           // A
        } else {
          // Transparent background
          rgbaOutput[outOffset] = 0;
          rgbaOutput[outOffset + 1] = 0;
          rgbaOutput[outOffset + 2] = 0;
          rgbaOutput[outOffset + 3] = 0;
        }
        outOffset += 4;
      }
    }

    return rgbaOutput;
  }

  /// Creates a procedural mock silhouette cutout [ui.Image] for simulators / testing.
  static Future<ui.Image> createMockPersonCutout({
    int width = 400,
    int height = 800,
    Color personColor = const Color(0xFF6C63FF),
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final Paint paint = Paint()
      ..color = personColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final centerX = width / 2.0;

    // Draw Head
    final headCenter = Offset(centerX, height * 0.18);
    final headRadius = width * 0.16;
    canvas.drawCircle(headCenter, headRadius, paint);
    canvas.drawCircle(headCenter, headRadius, borderPaint);

    // Draw Torso & Body
    final Path bodyPath = Path();
    bodyPath.moveTo(centerX - width * 0.28, height * 0.35); // Left shoulder
    bodyPath.lineTo(centerX + width * 0.28, height * 0.35); // Right shoulder
    bodyPath.lineTo(centerX + width * 0.22, height * 0.70); // Right waist
    bodyPath.lineTo(centerX + width * 0.25, height * 0.95); // Right leg
    bodyPath.lineTo(centerX + width * 0.05, height * 0.95); // Inner right leg
    bodyPath.lineTo(centerX, height * 0.70);                // Inseam
    bodyPath.lineTo(centerX - width * 0.05, height * 0.95); // Inner left leg
    bodyPath.lineTo(centerX - width * 0.25, height * 0.95); // Left leg
    bodyPath.lineTo(centerX - width * 0.22, height * 0.70); // Left waist
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(bodyPath, borderPaint);

    // Draw stylized label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "MOCK SILHOUETTE",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - (textPainter.width / 2), height * 0.48),
    );

    final ui.Picture picture = recorder.endRecording();
    return picture.toImage(width, height);
  }
}
