import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class InteractiveTryOnCanvas extends StatefulWidget {
  final ImageProvider baseProductImage;
  final ui.Image? userCutout;
  final bool isCutoutOnTop;
  final double overlayOpacity;
  final TransformationController? transformationController;
  final GlobalKey? repaintBoundaryKey;
  final ValueChanged<Matrix4>? onTransformChanged;

  const InteractiveTryOnCanvas({
    super.key,
    required this.baseProductImage,
    required this.userCutout,
    this.isCutoutOnTop = false,
    this.overlayOpacity = 1.0,
    this.transformationController,
    this.repaintBoundaryKey,
    this.onTransformChanged,
  });

  @override
  State<InteractiveTryOnCanvas> createState() => _InteractiveTryOnCanvasState();
}

class _InteractiveTryOnCanvasState extends State<InteractiveTryOnCanvas> {
  late final TransformationController _transformController;
  bool _internalControllerCreated = false;

  @override
  void initState() {
    super.initState();
    if (widget.transformationController != null) {
      _transformController = widget.transformationController!;
    } else {
      _transformController = TransformationController();
      _internalControllerCreated = true;
    }
    _transformController.addListener(_handleTransformChanged);
  }

  @override
  void didUpdateWidget(covariant InteractiveTryOnCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transformationController != widget.transformationController) {
      if (_internalControllerCreated) {
        _transformController.removeListener(_handleTransformChanged);
        _transformController.dispose();
      }
      if (widget.transformationController != null) {
        _transformController = widget.transformationController!;
        _internalControllerCreated = false;
      } else {
        _transformController = TransformationController();
        _internalControllerCreated = true;
      }
      _transformController.addListener(_handleTransformChanged);
    }
  }

  void _handleTransformChanged() {
    widget.onTransformChanged?.call(_transformController.value);
  }

  @override
  void dispose() {
    _transformController.removeListener(_handleTransformChanged);
    if (_internalControllerCreated) {
      _transformController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Static base clothing/product photo or cutout layer
    final Widget productLayer = Image(
      image: widget.baseProductImage,
      fit: BoxFit.contain,
      errorBuilder: (ctx, err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checkroom_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Garment Preview',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );

    // 2. Transformed cut-out layer (Reposition, Scale, Rotate)
    final Widget cutoutLayer = widget.userCutout != null
        ? RawImage(
            image: widget.userCutout,
            fit: BoxFit.contain,
          )
        : Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_outlined, color: Colors.white70),
                  SizedBox(width: 8),
                  Text(
                    'No User Cutout Loaded\nTap "Add Silhouette" below',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          );

    final transformedCutoutWidget = InteractiveViewer(
      transformationController: _transformController,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.2,
      maxScale: 4.0,
      child: Opacity(
        opacity: widget.overlayOpacity.clamp(0.0, 1.0),
        child: cutoutLayer,
      ),
    );

    // If cutout is on top, product is the base, cutout is manipulated on top.
    // If garment is on top, user silhouette is static underneath, and garment can be manipulated or vice versa.
    final List<Widget> layerStack = widget.isCutoutOnTop
        ? [
            productLayer,
            transformedCutoutWidget,
          ]
        : [
            // User silhouette at base, product manipulated on top
            InteractiveViewer(
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.2,
              maxScale: 4.0,
              child: Opacity(
                opacity: widget.overlayOpacity.clamp(0.0, 1.0),
                child: productLayer,
              ),
            ),
            if (widget.userCutout != null)
              IgnorePointer(
                child: RawImage(
                  image: widget.userCutout,
                  fit: BoxFit.contain,
                ),
              ),
          ];

    return RepaintBoundary(
      key: widget.repaintBoundaryKey,
      child: Container(
        color: const Color(0xFF121214),
        child: Stack(
          fit: StackFit.expand,
          children: layerStack,
        ),
      ),
    );
  }
}
