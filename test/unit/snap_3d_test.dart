import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tryon/features/snap_3d/data/garment_extractor_service.dart';
import 'package:tryon/features/snap_3d/domain/models/snap_3d_state.dart';

void main() {
  group('Snap3D & GarmentExtractor Tests', () {
    test('bytesToDataUrl produces valid base64 data URL', () {
      final service = GarmentExtractorService();
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final dataUrl = service.bytesToDataUrl(dummyBytes);

      expect(dataUrl.startsWith('data:image/png;base64,'), isTrue);
      final rawB64 = dataUrl.replaceFirst('data:image/png;base64,', '');
      expect(base64Decode(rawB64), equals(dummyBytes));
    });

    test('Snap3DState copyWith preserves and updates fields correctly', () {
      const state = Snap3DState(
        clothingTitle: 'Sand Trench',
        personName: 'Alex',
        isAutoRotating: true,
        currentAngleDegrees: 45.0,
        isARMode: false,
      );

      final updated = state.copyWith(
        currentAngleDegrees: 180.0,
        isARMode: true,
        isAutoRotating: false,
      );

      expect(updated.clothingTitle, equals('Sand Trench'));
      expect(updated.personName, equals('Alex'));
      expect(updated.currentAngleDegrees, equals(180.0));
      expect(updated.isARMode, isTrue);
      expect(updated.isAutoRotating, isFalse);
    });
  });
}
