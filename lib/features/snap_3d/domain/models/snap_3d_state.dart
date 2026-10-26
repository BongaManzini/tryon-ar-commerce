import 'dart:typed_data';

/// State representation for 3D 360° snap try-on studio.
class Snap3DState {
  final Uint8List? clothingImageBytes;
  final String? clothingDataUrl;
  final String clothingTitle;

  final Uint8List? personImageBytes;
  final String? personDataUrl;
  final String personName;

  final bool isAutoRotating;
  final double currentAngleDegrees;
  final bool isARMode;
  final bool isSceneReady;
  final bool isLoading;
  final String? statusMessage;

  const Snap3DState({
    this.clothingImageBytes,
    this.clothingDataUrl,
    this.clothingTitle = 'Scanned Garment',
    this.personImageBytes,
    this.personDataUrl,
    this.personName = 'Myself',
    this.isAutoRotating = true,
    this.currentAngleDegrees = 0.0,
    this.isARMode = false,
    this.isSceneReady = false,
    this.isLoading = false,
    this.statusMessage,
  });

  Snap3DState copyWith({
    Uint8List? clothingImageBytes,
    String? clothingDataUrl,
    String? clothingTitle,
    Uint8List? personImageBytes,
    String? personDataUrl,
    String? personName,
    bool? isAutoRotating,
    double? currentAngleDegrees,
    bool? isARMode,
    bool? isSceneReady,
    bool? isLoading,
    String? statusMessage,
  }) {
    return Snap3DState(
      clothingImageBytes: clothingImageBytes ?? this.clothingImageBytes,
      clothingDataUrl: clothingDataUrl ?? this.clothingDataUrl,
      clothingTitle: clothingTitle ?? this.clothingTitle,
      personImageBytes: personImageBytes ?? this.personImageBytes,
      personDataUrl: personDataUrl ?? this.personDataUrl,
      personName: personName ?? this.personName,
      isAutoRotating: isAutoRotating ?? this.isAutoRotating,
      currentAngleDegrees: currentAngleDegrees ?? this.currentAngleDegrees,
      isARMode: isARMode ?? this.isARMode,
      isSceneReady: isSceneReady ?? this.isSceneReady,
      isLoading: isLoading ?? this.isLoading,
      statusMessage: statusMessage,
    );
  }
}
