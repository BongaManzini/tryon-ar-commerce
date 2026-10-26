import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../catalog/data/mock_catalog_data.dart';
import '../../../catalog/presentation/controllers/catalog_controller.dart';
import '../controllers/snap_3d_controller.dart';
import '../widgets/three_js_viewport.dart';
import '../widgets/turntable_controls.dart';

class Snap3DStudioScreen extends ConsumerStatefulWidget {
  const Snap3DStudioScreen({super.key});

  @override
  ConsumerState<Snap3DStudioScreen> createState() => _Snap3DStudioScreenState();
}

class _Snap3DStudioScreenState extends ConsumerState<Snap3DStudioScreen> {
  final GlobalKey<ThreeJSViewportState> _viewportKey = GlobalKey<ThreeJSViewportState>();
  CameraController? _arBackgroundCamera;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initArCamera();
  }

  Future<void> _initArCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final backCam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
        _arBackgroundCamera = CameraController(
          backCam,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _arBackgroundCamera!.initialize();
        if (mounted) {
          setState(() => _cameraInitialized = true);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _arBackgroundCamera?.dispose();
    super.dispose();
  }

  void _showClothingSourceDialog() {
    final controller = ref.read(snap3DControllerProvider.notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Snap Clothing Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Take a photo of physical clothing on a hanger, bed, rack, or mannequin.',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
                ),
                title: const Text('Take Picture of Clothing', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Isolates garment automatically into 3D', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.snapClothingPhoto();
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.tealAccent),
                ),
                title: const Text('Upload Clothing from Gallery', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Select a saved clothing image', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.pickClothingFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersonSourceDialog() {
    final controller = ref.read(snap3DControllerProvider.notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select Person / Model to Wear Clothes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Capture yourself or any photo of a person to place inside the 3D rotating garment.',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF00E676)),
                ),
                title: const Text('Snap Picture of Myself / Person', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Runs on-device selfie segmentation', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.snapPersonPhoto();
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_album, color: Colors.amberAccent),
                ),
                title: const Text('Pick Person from Gallery', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Use an existing photo of a friend or model', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.pickPersonFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCatalogGarmentsModal() {
    final controller = ref.read(snap3DControllerProvider.notifier);
    final catalogState = ref.read(catalogControllerProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sample Retail Garments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: catalogState.products.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                itemBuilder: (context, idx) {
                  final p = catalogState.products[idx];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(p.transparentCutoutUrl, width: 44, height: 44, fit: BoxFit.cover),
                    ),
                    title: Text(p.title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: Text('${p.brand} • \$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () {
                      controller.applyProductGarment(p);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapState = ref.watch(snap3DControllerProvider);
    final snapNotifier = ref.read(snap3DControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        title: const Text('3D 360° Snap & Try'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              snapState.isARMode ? Icons.view_in_ar : Icons.view_in_ar_outlined,
              color: snapState.isARMode ? const Color(0xFF00E676) : Colors.white,
            ),
            tooltip: 'Toggle AR Camera Passthrough',
            onPressed: () => snapNotifier.toggleARMode(!snapState.isARMode),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. AR Camera Feed Passthrough (when AR Mode is enabled)
          if (snapState.isARMode && _cameraInitialized && _arBackgroundCamera != null)
            CameraPreview(_arBackgroundCamera!),

          // 2. Interactive Three.js 3D WebGL Turntable Viewport
          ThreeJSViewport(
            key: _viewportKey,
            clothingDataUrl: snapState.clothingDataUrl,
            personDataUrl: snapState.personDataUrl,
            isAutoRotating: snapState.isAutoRotating,
            viewingAngleDegrees: snapState.currentAngleDegrees,
            isARMode: snapState.isARMode,
            onAngleChanged: (angle) => snapNotifier.setViewingAngle(angle),
          ),

          // 3. Top Info Pill: Active Clothing & Model
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    '${snapState.clothingTitle} • ${snapState.personName}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                if (snapState.statusMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      snapState.statusMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),

          // 4. Loading Overlay
          if (snapState.isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    const SizedBox(height: 16),
                    Text(
                      snapState.statusMessage ?? 'Processing 3D Extraction...',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Bottom Controls: Action Buttons & 360° Turntable Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Ingestion Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showClothingSourceDialog,
                          icon: const Icon(Icons.camera_alt_outlined, size: 16),
                          label: const Text('Snap Clothing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showPersonSourceDialog,
                          icon: const Icon(Icons.person_add_outlined, size: 16),
                          label: const Text('Snap Person'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E1E24),
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showCatalogGarmentsModal,
                        icon: const Icon(Icons.checkroom, color: Colors.white70),
                        tooltip: 'Catalog Garments',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E1E24),
                          side: const BorderSide(color: Colors.white24),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 360° Turntable Controls Panel
                TurntableControls(
                  currentAngle: snapState.currentAngleDegrees,
                  isAutoRotating: snapState.isAutoRotating,
                  isARMode: snapState.isARMode,
                  onAngleChanged: (angle) {
                    snapNotifier.setViewingAngle(angle);
                    _viewportKey.currentState?.setViewingAngle(angle);
                  },
                  onToggleAutoRotate: (enabled) {
                    snapNotifier.toggleAutoRotate(enabled);
                    _viewportKey.currentState?.setAutoRotate(enabled);
                  },
                  onToggleARMode: (enabled) {
                    snapNotifier.toggleARMode(enabled);
                    _viewportKey.currentState?.setARMode(enabled);
                  },
                  onResetCamera: () {
                    snapNotifier.setViewingAngle(0.0);
                    _viewportKey.currentState?.setViewingAngle(0.0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
