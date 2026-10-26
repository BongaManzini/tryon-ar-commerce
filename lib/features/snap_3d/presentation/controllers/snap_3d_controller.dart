import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../catalog/data/mock_catalog_data.dart';
import '../../../catalog/domain/models/product.dart';
import '../../../core/utils/image_converter_utils.dart';
import '../../segmentation/data/segmentation_repository.dart';
import '../data/garment_extractor_service.dart';
import '../domain/models/snap_3d_state.dart';

final garmentExtractorServiceProvider = Provider<GarmentExtractorService>((ref) {
  return GarmentExtractorService();
});

class Snap3DController extends StateNotifier<Snap3DState> {
  final GarmentExtractorService _garmentService;
  final SegmentationRepository _segmentationRepo;

  Snap3DController(this._garmentService, this._segmentationRepo)
      : super(const Snap3DState()) {
    loadDemoScene();
  }

  /// Ingests clothing by snapping a real-world photo with the camera
  Future<void> snapClothingPhoto() async {
    state = state.copyWith(isLoading: true, statusMessage: 'Snapping physical clothing photo...');
    try {
      final File? imageFile = await _garmentService.snapClothingFromCamera();
      if (imageFile == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = state.copyWith(statusMessage: 'Extracting clothing silhouette...');
      final Uint8List transparentPng = await _garmentService.extractGarmentSilhouette(imageFile);
      final dataUrl = _garmentService.bytesToDataUrl(transparentPng);

      state = state.copyWith(
        isLoading: false,
        clothingImageBytes: transparentPng,
        clothingDataUrl: dataUrl,
        clothingTitle: 'Snapped Garment',
        statusMessage: 'Clothing mapped to 3D avatar',
      );
    } catch (e) {
      debugPrint('[Snap3DController] Clothing snap error: $e');
      state = state.copyWith(isLoading: false, statusMessage: 'Failed to extract clothing photo');
    }
  }

  /// Ingests clothing from device gallery
  Future<void> pickClothingFromGallery() async {
    state = state.copyWith(isLoading: true, statusMessage: 'Selecting clothing image...');
    try {
      final File? imageFile = await _garmentService.pickClothingFromGallery();
      if (imageFile == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = state.copyWith(statusMessage: 'Extracting clothing silhouette...');
      final Uint8List transparentPng = await _garmentService.extractGarmentSilhouette(imageFile);
      final dataUrl = _garmentService.bytesToDataUrl(transparentPng);

      state = state.copyWith(
        isLoading: false,
        clothingImageBytes: transparentPng,
        clothingDataUrl: dataUrl,
        clothingTitle: 'Uploaded Garment',
        statusMessage: 'Clothing mapped to 3D avatar',
      );
    } catch (e) {
      debugPrint('[Snap3DController] Clothing gallery error: $e');
      state = state.copyWith(isLoading: false, statusMessage: 'Failed to extract clothing photo');
    }
  }

  /// Ingests the person (myself or chosen person) to wear the clothing
  Future<void> snapPersonPhoto() async {
    state = state.copyWith(isLoading: true, statusMessage: 'Capturing person silhouette...');
    try {
      final cutout = await _segmentationRepo.captureAndSegmentFromCamera();
      if (cutout != null && cutout.pngBytes != null) {
        final dataUrl = 'data:image/png;base64,${base64Encode(cutout.pngBytes!)}';
        state = state.copyWith(
          isLoading: false,
          personImageBytes: cutout.pngBytes,
          personDataUrl: dataUrl,
          personName: 'Snapped Silhouette',
          statusMessage: 'Person placed inside 3D clothing',
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('[Snap3DController] Person snap error: $e');
      state = state.copyWith(isLoading: false, statusMessage: 'Failed to segment person');
    }
  }

  /// Ingests person photo from gallery
  Future<void> pickPersonFromGallery() async {
    state = state.copyWith(isLoading: true, statusMessage: 'Selecting person photo...');
    try {
      final cutout = await _segmentationRepo.pickAndSegmentFromGallery();
      if (cutout != null && cutout.pngBytes != null) {
        final dataUrl = 'data:image/png;base64,${base64Encode(cutout.pngBytes!)}';
        state = state.copyWith(
          isLoading: false,
          personImageBytes: cutout.pngBytes,
          personDataUrl: dataUrl,
          personName: 'Selected Person',
          statusMessage: 'Person placed inside 3D clothing',
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('[Snap3DController] Person gallery error: $e');
      state = state.copyWith(isLoading: false, statusMessage: 'Failed to segment person');
    }
  }

  /// Applies a catalog product garment directly to 3D avatar
  void applyProductGarment(Product product) {
    state = state.copyWith(
      clothingTitle: product.title,
      clothingDataUrl: product.transparentCutoutUrl,
      statusMessage: 'Loaded ${product.title}',
    );
  }

  void setViewingAngle(double angle) {
    state = state.copyWith(currentAngleDegrees: angle);
  }

  void toggleAutoRotate(bool enabled) {
    state = state.copyWith(isAutoRotating: enabled);
  }

  void toggleARMode(bool enabled) {
    state = state.copyWith(isARMode: enabled);
  }

  /// Loads starter demo textures so the 3D scene is immediately rotatable and interactive
  Future<void> loadDemoScene() async {
    final defaultProduct = MockCatalogData.sampleProducts[2]; // Vintage Moto Leather Jacket
    state = state.copyWith(
      clothingTitle: defaultProduct.title,
      clothingDataUrl: defaultProduct.transparentCutoutUrl,
      personName: 'Studio Model',
      isAutoRotating: true,
      currentAngleDegrees: 0.0,
      statusMessage: '360° Studio Active',
    );
  }
}

final snap3DControllerProvider =
    StateNotifierProvider<Snap3DController, Snap3DState>((ref) {
  final garmentService = ref.watch(garmentExtractorServiceProvider);
  final segmentationRepo = ref.watch(segmentationRepositoryProvider);
  return Snap3DController(garmentService, segmentationRepo);
});
