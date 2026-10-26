import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tryon/features/ar_overlay/domain/models/ar_anchor_model.dart';
import 'package:tryon/features/catalog/domain/models/product.dart';
import 'package:tryon/features/try_on/domain/models/overlay_transform.dart';
import 'package:tryon/features/wishlist/domain/models/wishlist_item.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('Domain Models Serialization Tests', () {
    test('Product toJson and fromJson round-trip', () {
      const product = Product(
        id: 'p1',
        title: 'Denim Overshirt',
        brand: 'A.P.C.',
        description: 'Indigo rinsed overshirt',
        price: 190.0,
        currency: 'EUR',
        transparentCutoutUrl: 'https://cdn.example.com/overshirt.png',
        modelPhotoUrl: 'https://cdn.example.com/model.jpg',
        barcode: '3601234567890',
        variantId: 'v101',
        checkoutUrl: 'https://apc.fr/buy',
        category: 'Tops',
        tags: ['Denim', 'Overshirt'],
      );

      final json = product.toJson();
      final fromJson = Product.fromJson(json);

      expect(fromJson.id, equals(product.id));
      expect(fromJson.title, equals(product.title));
      expect(fromJson.price, equals(product.price));
      expect(fromJson.barcode, equals(product.barcode));
    });

    test('OverlayTransform serialization preserves matrix and layer ordering', () {
      final transform = OverlayTransform(
        matrixValues: List.generate(16, (i) => i.toDouble()),
        scale: 1.8,
        translation: const Offset(12.5, 34.5),
        rotation: 0.45,
        isCutoutOnTop: false,
        opacity: 0.85,
      );

      final json = transform.toJson();
      final restored = OverlayTransform.fromJson(json);

      expect(restored.scale, equals(1.8));
      expect(restored.translation.dx, equals(12.5));
      expect(restored.translation.dy, equals(34.5));
      expect(restored.isCutoutOnTop, isFalse);
      expect(restored.opacity, equals(0.85));
    });

    test('WishlistItem serialization with base64 snapshot', () {
      const product = Product(
        id: 'p2',
        title: 'Minimalist Tee',
        brand: 'Uniqlo U',
        description: 'Crewneck tee',
        price: 19.90,
        transparentCutoutUrl: 'https://cdn.example.com/tee.png',
        modelPhotoUrl: 'https://cdn.example.com/tee.png',
        barcode: '200000000001',
        variantId: 'v202',
        checkoutUrl: 'https://uniqlo.com/buy',
        category: 'Tops',
      );

      final item = WishlistItem(
        id: 'w1',
        title: 'Summer Outfit',
        product: product,
        overlayTransform: OverlayTransform.identity(),
        snapshotBytes: null,
        createdAt: DateTime(2026, 10, 26, 12, 0, 0),
      );

      final json = item.toJson();
      final restored = WishlistItem.fromJson(json);

      expect(restored.id, equals(item.id));
      expect(restored.title, equals('Summer Outfit'));
      expect(restored.product.id, equals(product.id));
    });

    test('ARAnchorModel serialization preserves 3D vector coordinates', () {
      final anchor = ARAnchorModel(
        id: 'anchor_01',
        position: Vector3(1.2, -0.5, 3.4),
        rotation: Vector4(0.0, 0.0, 0.0, 1.0),
        scale: 0.8,
        attachedProductId: 'p1',
        createdAt: DateTime(2026, 10, 26, 12, 0, 0),
      );

      final json = anchor.toJson();
      final restored = ARAnchorModel.fromJson(json);

      expect(restored.position.x, closeTo(1.2, 0.001));
      expect(restored.position.y, closeTo(-0.5, 0.001));
      expect(restored.position.z, closeTo(3.4, 0.001));
      expect(restored.scale, equals(0.8));
      expect(restored.attachedProductId, equals('p1'));
    });
  });
}
