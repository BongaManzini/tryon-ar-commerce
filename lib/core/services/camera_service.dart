import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../errors/exceptions.dart';

/// Service abstraction for hardware camera control, image streaming, and capture.
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _availableCameras = [];
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized && _controller != null;
  List<CameraDescription> get availableCameras => _availableCameras;

  Future<void> initialize({CameraLensDirection preferredLens = CameraLensDirection.front}) async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        debugPrint('[CameraService] No physical cameras detected.');
        return;
      }

      final camera = _availableCameras.firstWhere(
        (cam) => cam.lensDirection == preferredLens,
        orElse: () => _availableCameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e, stack) {
      debugPrint('[CameraService] Initialization error: $e\n$stack');
      throw CameraServiceException('Failed to initialize camera', cause: e);
    }
  }

  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw CameraServiceException('Camera is not initialized');
    }
    try {
      return await _controller!.takePicture();
    } catch (e) {
      throw CameraServiceException('Failed to take picture', cause: e);
    }
  }

  Future<void> switchCamera() async {
    if (_availableCameras.length < 2 || _controller == null) return;
    
    final currentLens = _controller!.description.lensDirection;
    final targetLens = currentLens == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    await dispose();
    await initialize(preferredLens: targetLens);
  }

  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
  }
}
