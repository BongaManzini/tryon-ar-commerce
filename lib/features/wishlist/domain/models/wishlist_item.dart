import 'dart:convert';
import 'dart:typed_data';
import '../../../features/catalog/domain/models/product.dart';
import '../../../features/try_on/domain/models/overlay_transform.dart';

/// Saved try-on outfit item persisted locally in Hive and syncable to cloud.
class WishlistItem {
  final String id;
  final String title;
  final Product product;
  final OverlayTransform overlayTransform;
  final Uint8List? snapshotBytes;
  final DateTime createdAt;

  const WishlistItem({
    required this.id,
    required this.title,
    required this.product,
    required this.overlayTransform,
    this.snapshotBytes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'product': product.toJson(),
      'overlayTransform': overlayTransform.toJson(),
      'snapshotBase64': snapshotBytes != null ? base64Encode(snapshotBytes!) : null,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    Uint8List? bytes;
    if (json['snapshotBase64'] != null) {
      bytes = base64Decode(json['snapshotBase64'] as String);
    }

    return WishlistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      product: Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
      overlayTransform: OverlayTransform.fromJson(
        Map<String, dynamic>.from(json['overlayTransform'] as Map),
      ),
      snapshotBytes: bytes,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
