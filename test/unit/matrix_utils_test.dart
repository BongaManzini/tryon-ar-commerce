import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tryon/core/utils/matrix_utils.dart';

void main() {
  group('MatrixUtilsHelper Tests', () {
    test('matrix4ToList and listToMatrix4 preserve values', () {
      final matrix = Matrix4.identity();
      matrix.translate(10.0, 20.0, 0.0);
      matrix.scale(2.5, 2.5, 1.0);

      final list = MatrixUtilsHelper.matrix4ToList(matrix);
      expect(list.length, equals(16));

      final restored = MatrixUtilsHelper.listToMatrix4(list);
      expect(restored, equals(matrix));
    });

    test('getTranslation extracts correct 2D offset', () {
      final matrix = Matrix4.identity();
      matrix.translate(45.0, 90.0, 0.0);

      final translation = MatrixUtilsHelper.getTranslation(matrix);
      expect(translation.dx, equals(45.0));
      expect(translation.dy, equals(90.0));
    });

    test('composeTransform produces expected Matrix4', () {
      final matrix = MatrixUtilsHelper.composeTransform(
        translation: const Offset(50, 100),
        scale: 1.5,
        rotation: 0.0,
      );

      final translation = MatrixUtilsHelper.getTranslation(matrix);
      expect(translation.dx, equals(50.0));
      expect(translation.dy, equals(100.0));
    });

    test('fitCenter calculates valid scale and centered translation', () {
      const viewport = Size(400, 800);
      const child = Size(200, 400);

      final matrix = MatrixUtilsHelper.fitCenter(
        viewportSize: viewport,
        childSize: child,
        paddingRatio: 1.0,
      );

      final translation = MatrixUtilsHelper.getTranslation(matrix);
      expect(translation.dx, equals(0.0));
      expect(translation.dy, equals(0.0));
    });
  });
}
