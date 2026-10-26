import 'package:image_picker/image_picker.dart';
import '../../segmentation/domain/models/person_cutout.dart';
import 'cutout_engine.dart';

/// Repository interface and implementation for user silhouette segmentation.
abstract class SegmentationRepository {
  Future<PersonCutout?> captureAndSegmentFromCamera({double confidenceThreshold = 0.65});
  Future<PersonCutout?> pickAndSegmentFromGallery({double confidenceThreshold = 0.65});
  Future<PersonCutout> getMockCutout();
  void dispose();
}

class SegmentationRepositoryImpl implements SegmentationRepository {
  final CutoutEngine _cutoutEngine;
  final ImagePicker _imagePicker;

  SegmentationRepositoryImpl({
    CutoutEngine? cutoutEngine,
    ImagePicker? imagePicker,
  })  : _cutoutEngine = cutoutEngine ?? CutoutEngine(),
        _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<PersonCutout?> captureAndSegmentFromCamera({double confidenceThreshold = 0.65}) async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1200,
      maxHeight: 1800,
      imageQuality: 90,
    );

    if (photo == null) return null;
    return await _cutoutEngine.processCutoutFromFile(
      filePath: photo.path,
      confidenceThreshold: confidenceThreshold,
    );
  }

  @override
  Future<PersonCutout?> pickAndSegmentFromGallery({double confidenceThreshold = 0.65}) async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1800,
      imageQuality: 90,
    );

    if (photo == null) return null;
    return await _cutoutEngine.processCutoutFromFile(
      filePath: photo.path,
      confidenceThreshold: confidenceThreshold,
    );
  }

  @override
  Future<PersonCutout> getMockCutout() async {
    return await _cutoutEngine.generateMockCutout();
  }

  @override
  void dispose() {
    _cutoutEngine.dispose();
  }
}
