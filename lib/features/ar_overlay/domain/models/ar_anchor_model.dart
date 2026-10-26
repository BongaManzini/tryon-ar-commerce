import 'package:vector_math/vector_math_64.dart';

/// Data model representing a 3D anchor position in ARCore / ARKit space.
class ARAnchorModel {
  final String id;
  final Vector3 position;
  final Vector4 rotation;
  final double scale;
  final String? attachedProductId;
  final DateTime createdAt;

  const ARAnchorModel({
    required this.id,
    required this.position,
    required this.rotation,
    this.scale = 1.0,
    this.attachedProductId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': [position.x, position.y, position.z],
      'rotation': [rotation.x, rotation.y, rotation.z, rotation.w],
      'scale': scale,
      'attachedProductId': attachedProductId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ARAnchorModel.fromJson(Map<String, dynamic> json) {
    final posList = (json['position'] as List).map((e) => (e as num).toDouble()).toList();
    final rotList = (json['rotation'] as List).map((e) => (e as num).toDouble()).toList();
    return ARAnchorModel(
      id: json['id'] as String,
      position: Vector3(posList[0], posList[1], posList[2]),
      rotation: Vector4(rotList[0], rotList[1], rotList[2], rotList[3]),
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      attachedProductId: json['attachedProductId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
