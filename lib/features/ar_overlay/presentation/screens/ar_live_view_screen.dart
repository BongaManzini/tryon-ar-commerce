import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../catalog/presentation/controllers/catalog_controller.dart';
import '../../../try_on/presentation/controllers/try_on_controller.dart';

class ARLiveViewScreen extends ConsumerStatefulWidget {
  const ARLiveViewScreen({super.key});

  @override
  ConsumerState<ARLiveViewScreen> createState() => _ARLiveViewScreenState();
}

class _ARLiveViewScreenState extends ConsumerState<ARLiveViewScreen> {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  bool _isARInitialized = false;
  bool _arErrorFallback = false;
  String _statusMessage = 'Scanning for store racks & vertical surfaces...';
  int _anchoredItemCount = 0;

  @override
  void dispose() {
    _arSessionManager?.dispose();
    super.dispose();
  }

  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;

    try {
      _arSessionManager!.onInitialize(
        showFeaturePoints: false,
        showPlanes: true,
        planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
        showWorldOrigin: false,
      );
      _arObjectManager!.onInitialize();

      setState(() {
        _isARInitialized = true;
        _statusMessage = 'Plane detected! Tap anywhere to place garment';
      });
    } catch (e) {
      debugPrint('[ARLiveView] AR init exception: $e');
      setState(() {
        _arErrorFallback = true;
        _statusMessage = 'AR hardware unavailable. Using simulated AR view.';
      });
    }
  }

  void _handleSimulatedPlacement() {
    setState(() {
      _anchoredItemCount++;
      _statusMessage = 'Garment quad anchored in AR space.';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anchored garment onto detected vertical plane!'),
        backgroundColor: Color(0xFF00E676),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tryOnState = ref.watch(tryOnControllerProvider);
    final currentProduct = tryOnState.selectedProduct;
    final catalogState = ref.watch(catalogControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AR Live Placement'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Anchors',
            onPressed: () {
              setState(() {
                _anchoredItemCount = 0;
                _statusMessage = 'Cleared anchors. Tap to place garment.';
              });
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. AR Core / ARKit Hardware View or Graceful Fallback
          if (!_arErrorFallback)
            ARView(
              onARViewCreated: _onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            )
          else
            // Simulated AR Viewport for Simulators or Devices without ARCore
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF18181B), Color(0xFF09090B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 320,
                      height: 480,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.view_in_ar, size: 72, color: Color(0xFF6C63FF)),
                          const SizedBox(height: 16),
                          const Text(
                            'Vertical Plane Simulator',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Detected: Store Clothing Rack\nAnchors placed: $_anchoredItemCount',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _handleSimulatedPlacement,
                            icon: const Icon(Icons.add_location_alt_outlined),
                            label: const Text('Anchor Garment Quad'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. Status Banner
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar_rounded, color: Color(0xFF00E676), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Garment Selector and Buy Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Selection Strip
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: catalogState.products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final product = catalogState.products[idx];
                      final isSelected = currentProduct?.id == product.id;
                      return GestureDetector(
                        onTap: () {
                          ref.read(tryOnControllerProvider.notifier).selectProduct(product);
                        },
                        child: Container(
                          width: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF00E676) : Colors.white24,
                              width: isSelected ? 2.5 : 1,
                            ),
                            color: const Color(0xFF1E1E24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.transparentCutoutUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.checkroom),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Controls row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to 2D Studio'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      if (currentProduct != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(catalogControllerProvider.notifier)
                                  .checkoutProduct(currentProduct);
                            },
                            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                            label: const Text('Buy in AR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
