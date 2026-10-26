import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/matrix_utils.dart';
import '../../../catalog/domain/models/product.dart';
import '../../../segmentation/domain/models/person_cutout.dart';
import '../../domain/models/overlay_transform.dart';

class TryOnState {
  final Product? selectedProduct;
  final PersonCutout? userCutout;
  final OverlayTransform overlayTransform;
  final bool isCapturing;
  final String? errorMessage;

  const TryOnState({
    this.selectedProduct,
    this.userCutout,
    required this.overlayTransform,
    this.isCapturing = false,
    this.errorMessage,
  });

  TryOnState copyWith({
    Product? selectedProduct,
    PersonCutout? userCutout,
    OverlayTransform? overlayTransform,
    bool? isCapturing,
    String? errorMessage,
  }) {
    return TryOnState(
      selectedProduct: selectedProduct ?? this.selectedProduct,
      userCutout: userCutout ?? this.userCutout,
      overlayTransform: overlayTransform ?? this.overlayTransform,
      isCapturing: isCapturing ?? this.isCapturing,
      errorMessage: errorMessage,
    );
  }
}

class TryOnController extends StateNotifier<TryOnState> {
  final TransformationController transformationController = TransformationController();
  final GlobalKey repaintBoundaryKey = GlobalKey();

  TryOnController()
      : super(
          TryOnState(
            overlayTransform: OverlayTransform.identity(),
          ),
        ) {
    transformationController.value = state.overlayTransform.toMatrix4();
  }

  void selectProduct(Product product) {
    state = state.copyWith(selectedProduct: product);
  }

  void setUserCutout(PersonCutout cutout) {
    state = state.copyWith(userCutout: cutout);
  }

  void onTransformChanged(Matrix4 matrix) {
    final updated = OverlayTransform.fromMatrix4(
      matrix,
      isCutoutOnTop: state.overlayTransform.isCutoutOnTop,
      opacity: state.overlayTransform.opacity,
    );
    state = state.copyWith(overlayTransform: updated);
  }

  void toggleLayerOrder() {
    final newOrder = !state.overlayTransform.isCutoutOnTop;
    final updated = state.overlayTransform.copyWith(isCutoutOnTop: newOrder);
    state = state.copyWith(overlayTransform: updated);
  }

  void setOpacity(double opacity) {
    final updated = state.overlayTransform.copyWith(opacity: opacity);
    state = state.copyWith(overlayTransform: updated);
  }

  void resetTransform() {
    transformationController.value = Matrix4.identity();
    final updated = state.overlayTransform.copyWith(
      matrixValues: MatrixUtilsHelper.matrix4ToList(Matrix4.identity()),
      scale: 1.0,
      translation: Offset.zero,
      rotation: 0.0,
    );
    state = state.copyWith(overlayTransform: updated);
  }

  void fitCenter({required Size viewportSize}) {
    if (state.userCutout == null) {
      resetTransform();
      return;
    }

    final childSize = Size(
      state.userCutout!.width.toDouble(),
      state.userCutout!.height.toDouble(),
    );

    final fittedMatrix = MatrixUtilsHelper.fitCenter(
      viewportSize: viewportSize,
      childSize: childSize,
    );

    transformationController.value = fittedMatrix;
    final updated = state.overlayTransform.copyWith(
      matrixValues: MatrixUtilsHelper.matrix4ToList(fittedMatrix),
      scale: MatrixUtilsHelper.getScale(fittedMatrix),
      translation: MatrixUtilsHelper.getTranslation(fittedMatrix),
      rotation: MatrixUtilsHelper.getRotationZ(fittedMatrix),
    );
    state = state.copyWith(overlayTransform: updated);
  }

  void restoreTransform(OverlayTransform transform) {
    transformationController.value = transform.toMatrix4();
    state = state.copyWith(overlayTransform: transform);
  }

  /// Captures the rendered canvas compositing layer into high-resolution PNG bytes.
  Future<Uint8List?> captureCompositeSnapshot() async {
    try {
      state = state.copyWith(isCapturing: true);
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      state = state.copyWith(isCapturing: false);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      state = state.copyWith(isCapturing: false, errorMessage: e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }
}

final tryOnControllerProvider =
    StateNotifierProvider<TryOnController, TryOnState>((ref) {
  return TryOnController();
});
