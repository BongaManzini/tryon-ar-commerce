import 'dart:typed_data';
import 'dart:ui' as ui;

/// Model representing a segmented human silhouette ready for try-on compositing.
class PersonCutout {
  final String id;
  final ui.Image? image;
  final Uint8List? pngBytes;
  final int width;
  final int height;
  final DateTime capturedAt;
  final double confidenceThreshold;
  final bool isMock;

  const PersonCutout({
    required this.id,
    required this.image,
    this.pngBytes,
    required this.width,
    required this.height,
    required this.capturedAt,
    this.confidenceThreshold = 0.65,
    this.isMock = false,
  });

  PersonCutout copyWith({
    String? id,
    ui.Image? image,
    Uint8List? pngBytes,
    int? width,
    int? height,
    DateTime? capturedAt,
    double? confidenceThreshold,
    bool? isMock,
  }) {
    return PersonCutout(
      id: id ?? this.id,
      image: image ?? this.image,
      pngBytes: pngBytes ?? this.pngBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      capturedAt: capturedAt ?? this.capturedAt,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      isMock: isMock ?? this.isMock,
    );
  }
}
