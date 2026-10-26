import 'package:flutter/material.dart';
import '../../../../core/utils/matrix_utils.dart';

/// Data model representing the positioning, scale, rotation, and layer order of the virtual try-on overlay.
class OverlayTransform {
  final List<double> matrixValues;
  final double scale;
  final Offset translation;
  final double rotation;
  final bool isCutoutOnTop;
  final double opacity;

  const OverlayTransform({
    required this.matrixValues,
    this.scale = 1.0,
    this.translation = Offset.zero,
    this.rotation = 0.0,
    this.isCutoutOnTop = true,
    this.opacity = 1.0,
  });

  factory OverlayTransform.identity() {
    return OverlayTransform(
      matrixValues: MatrixUtilsHelper.matrix4ToList(Matrix4.identity()),
      scale: 1.0,
      translation: Offset.zero,
      rotation: 0.0,
      isCutoutOnTop: true,
      opacity: 1.0,
    );
  }

  factory OverlayTransform.fromMatrix4(Matrix4 matrix, {bool isCutoutOnTop = true, double opacity = 1.0}) {
    return OverlayTransform(
      matrixValues: MatrixUtilsHelper.matrix4ToList(matrix),
      scale: MatrixUtilsHelper.getScale(matrix),
      translation: MatrixUtilsHelper.getTranslation(matrix),
      rotation: MatrixUtilsHelper.getRotationZ(matrix),
      isCutoutOnTop: isCutoutOnTop,
      opacity: opacity,
    );
  }

  Matrix4 toMatrix4() {
    return MatrixUtilsHelper.listToMatrix4(matrixValues);
  }

  OverlayTransform copyWith({
    List<double>? matrixValues,
    double? scale,
    Offset? translation,
    double? rotation,
    bool? isCutoutOnTop,
    double? opacity,
  }) {
    return OverlayTransform(
      matrixValues: matrixValues ?? this.matrixValues,
      scale: scale ?? this.scale,
      translation: translation ?? this.translation,
      rotation: rotation ?? this.rotation,
      isCutoutOnTop: isCutoutOnTop ?? this.isCutoutOnTop,
      opacity: opacity ?? this.opacity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matrixValues': matrixValues,
      'scale': scale,
      'translationDx': translation.dx,
      'translationDy': translation.dy,
      'rotation': rotation,
      'isCutoutOnTop': isCutoutOnTop,
      'opacity': opacity,
    };
  }

  factory OverlayTransform.fromJson(Map<String, dynamic> json) {
    final list = (json['matrixValues'] as List).map((e) => (e as num).toDouble()).toList();
    final dx = (json['translationDx'] as num?)?.toDouble() ?? 0.0;
    final dy = (json['translationDy'] as num?)?.toDouble() ?? 0.0;
    return OverlayTransform(
      matrixValues: list,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      translation: Offset(dx, dy),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      isCutoutOnTop: (json['isCutoutOnTop'] as bool?) ?? true,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
