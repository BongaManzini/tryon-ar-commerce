import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

/// Utility functions for 2D/3D transformation matrix manipulation, serialization, and decomposition.
class MatrixUtilsHelper {
  /// Converts a [Matrix4] to a serialized List of 16 double values.
  static List<double> matrix4ToList(Matrix4 matrix) {
    return List<double>.from(matrix.storage);
  }

  /// Restores a [Matrix4] from a 16-element List of double values.
  static Matrix4 listToMatrix4(List<dynamic> list) {
    assert(list.length == 16, 'Matrix4 list must have exactly 16 elements');
    final doubleList = list.map((e) => (e as num).toDouble()).toList();
    return Matrix4.fromList(doubleList);
  }

  /// Decomposes [Matrix4] into 2D translation offset.
  static Offset getTranslation(Matrix4 matrix) {
    return Offset(matrix.storage[12], matrix.storage[13]);
  }

  /// Extracts the uniform scale factor from [Matrix4].
  static double getScale(Matrix4 matrix) {
    final sx = matrix.storage[0];
    final sy = matrix.storage[5];
    return math.sqrt(sx * sx + sy * sy) / math.sqrt(2);
  }

  /// Extracts the rotation around Z axis in radians.
  static double getRotationZ(Matrix4 matrix) {
    return math.atan2(matrix.storage[1], matrix.storage[0]);
  }

  /// Builds a [Matrix4] from 2D translation, uniform scale, and rotation angle (in radians).
  static Matrix4 composeTransform({
    Offset translation = Offset.zero,
    double scale = 1.0,
    double rotation = 0.0,
    Offset origin = Offset.zero,
  }) {
    final matrix = Matrix4.identity();
    matrix.translate(translation.dx + origin.dx, translation.dy + origin.dy);
    if (rotation != 0.0) {
      matrix.rotateZ(rotation);
    }
    matrix.scale(scale, scale, 1.0);
    matrix.translate(-origin.dx, -origin.dy);
    return matrix;
  }

  /// Calculates a transform that centers and fits a child of [childSize] within [viewportSize] with padding factor.
  static Matrix4 fitCenter({
    required Size viewportSize,
    required Size childSize,
    double paddingRatio = 0.85,
  }) {
    if (childSize.width == 0 || childSize.height == 0) {
      return Matrix4.identity();
    }

    final double scaleX = (viewportSize.width * paddingRatio) / childSize.width;
    final double scaleY = (viewportSize.height * paddingRatio) / childSize.height;
    final double targetScale = math.min(scaleX, scaleY);

    final double scaledW = childSize.width * targetScale;
    final double scaledH = childSize.height * targetScale;

    final double dx = (viewportSize.width - scaledW) / 2.0;
    final double dy = (viewportSize.height - scaledH) / 2.0;

    final matrix = Matrix4.identity();
    matrix.translate(dx, dy);
    matrix.scale(targetScale, targetScale, 1.0);
    return matrix;
  }
}
