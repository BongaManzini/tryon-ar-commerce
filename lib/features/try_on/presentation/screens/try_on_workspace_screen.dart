import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../catalog/data/mock_catalog_data.dart';
import '../../../catalog/presentation/controllers/catalog_controller.dart';
import '../../../segmentation/presentation/controllers/segmentation_controller.dart';
import '../../../wishlist/presentation/controllers/wishlist_controller.dart';
import '../controllers/try_on_controller.dart';
import '../widgets/interactive_clothing_canvas.dart';
import '../widgets/layer_control_toolbar.dart';
import '../widgets/outfit_preview_modal.dart';

class TryOnWorkspaceScreen extends ConsumerStatefulWidget {
  final String? initialProductId;

  const TryOnWorkspaceScreen({super.key, this.initialProductId});

  @override
  ConsumerState<TryOnWorkspaceScreen> createState() => _TryOnWorkspaceScreenState();
}

class _TryOnWorkspaceScreenState extends ConsumerState<TryOnWorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWorkspace();
    });
  }

  void _initWorkspace() {
    final tryOnNotifier = ref.read(tryOnControllerProvider.notifier);
    final catalogState = ref.read(catalogControllerProvider);

    // If an initial product ID was passed, find and select it
    if (widget.initialProductId != null) {
      final product = catalogState.products.firstWhere(
        (p) => p.id == widget.initialProductId,
        orElse: () => MockCatalogData.sampleProducts.first,
      );
      tryOnNotifier.selectProduct(product);
    } else {
      // Default to first product if none selected yet
      final currentSelected = ref.read(tryOnControllerProvider).selectedProduct;
      if (currentSelected == null && catalogState.products.isNotEmpty) {
        tryOnNotifier.selectProduct(catalogState.products.first);
      } else if (currentSelected == null) {
        tryOnNotifier.selectProduct(MockCatalogData.sampleProducts.first);
      }
    }

    // Auto-load a mock cutout if no user cutout exists yet for immediate interactivity
    final segState = ref.read(segmentationControllerProvider);
    final tryOnCutout = ref.read(tryOnControllerProvider).userCutout;
    if (tryOnCutout == null) {
      if (segState.cutout != null) {
        tryOnNotifier.setUserCutout(segState.cutout!);
      } else {
        ref.read(segmentationControllerProvider.notifier).loadMockCutout().then((_) {
          final loaded = ref.read(segmentationControllerProvider).cutout;
          if (loaded != null && mounted) {
            tryOnNotifier.setUserCutout(loaded);
          }
        });
      }
    }
  }

  void _showSilhouetteSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Silhouette Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Capture your photo to run on-device ML Kit selfie segmentation.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF6C63FF)),
                  ),
                  title: const Text('Live Camera Selfie', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Capture full-body or upper-body photo',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(segmentationControllerProvider.notifier).captureFromCamera();
                    final cutout = ref.read(segmentationControllerProvider).cutout;
                    if (cutout != null) {
                      ref.read(tryOnControllerProvider.notifier).setUserCutout(cutout);
                    }
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Colors.tealAccent),
                  ),
                  title: const Text('Upload from Gallery', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Select an existing photo from device album',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(segmentationControllerProvider.notifier).pickFromGallery();
                    final cutout = ref.read(segmentationControllerProvider).cutout;
                    if (cutout != null) {
                      ref.read(tryOnControllerProvider.notifier).setUserCutout(cutout);
                    }
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.accessibility_new_rounded, color: Colors.amberAccent),
                  ),
                  title: const Text('Use Mock Model Silhouette', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Instant procedural test cutout for development',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(segmentationControllerProvider.notifier).loadMockCutout();
                    final cutout = ref.read(segmentationControllerProvider).cutout;
                    if (cutout != null) {
                      ref.read(tryOnControllerProvider.notifier).setUserCutout(cutout);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductSelectorModal() {
    final catalogState = ref.read(catalogControllerProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Change Garment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF00E676)),
                        tooltip: 'Scan Barcode in Store',
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push(RouteConstants.barcodeScannerPath);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: catalogState.products.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                      itemBuilder: (context, idx) {
                        final product = catalogState.products[idx];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.transparentCutoutUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.checkroom),
                            ),
                          ),
                          title: Text(
                            product.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${product.brand} • \$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                          onTap: () {
                            ref.read(tryOnControllerProvider.notifier).selectProduct(product);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleCaptureLook() async {
    final tryOnNotifier = ref.read(tryOnControllerProvider.notifier);
    final tryOnState = ref.read(tryOnControllerProvider);

    final snapshotBytes = await tryOnNotifier.captureCompositeSnapshot();
    if (snapshotBytes == null || !mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => OutfitPreviewModal(
        snapshotBytes: snapshotBytes,
        selectedProduct: tryOnState.selectedProduct,
        onSaveToWishlist: (title) async {
          if (tryOnState.selectedProduct != null) {
            await ref.read(wishlistControllerProvider.notifier).saveOutfit(
              title: title,
              product: tryOnState.selectedProduct!,
              overlayTransform: tryOnState.overlayTransform,
              snapshotBytes: snapshotBytes,
            );
          }
        },
        onCheckout: () {
          if (tryOnState.selectedProduct != null) {
            ref
                .read(catalogControllerProvider.notifier)
                .checkoutProduct(tryOnState.selectedProduct!);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tryOnState = ref.watch(tryOnControllerProvider);
    final tryOnNotifier = ref.read(tryOnControllerProvider.notifier);
    final segState = ref.watch(segmentationControllerProvider);

    // Sync cutout when segmentation controller updates
    ref.listen<SegmentationState>(segmentationControllerProvider, (prev, next) {
      if (next.cutout != null && next.cutout != tryOnState.userCutout) {
        tryOnNotifier.setUserCutout(next.cutout!);
      }
    });

    final currentProduct = tryOnState.selectedProduct;
    final ImageProvider productImage = currentProduct != null
        ? NetworkImage(currentProduct.transparentCutoutUrl)
        : const AssetImage('assets/images/trench_coat_base.png') as ImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GestureDetector(
          onTap: _showProductSelectorModal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  currentProduct?.title ?? 'Try-On Studio',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white70),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_in_ar_outlined),
            tooltip: 'Live AR View',
            onPressed: () => context.push(RouteConstants.arLiveViewPath),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded),
            tooltip: 'Wishlist',
            onPressed: () => context.push(RouteConstants.wishlistPath),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Core 2D Canvas Compositing Engine
          InteractiveTryOnCanvas(
            baseProductImage: productImage,
            userCutout: tryOnState.userCutout?.image,
            isCutoutOnTop: tryOnState.overlayTransform.isCutoutOnTop,
            overlayOpacity: tryOnState.overlayTransform.opacity,
            transformationController: tryOnNotifier.transformationController,
            repaintBoundaryKey: tryOnNotifier.repaintBoundaryKey,
            onTransformChanged: (matrix) {
              tryOnNotifier.onTransformChanged(matrix);
            },
          ),

          // Loading overlay during ML Kit processing
          if (segState.isLoading || tryOnState.isCapturing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    SizedBox(height: 16),
                    Text(
                      'Processing Vision Cutout...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // Top Badge: Product Price & Fast Buy Button
          if (currentProduct != null)
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
                      '${currentProduct.brand} • \$${currentProduct.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(catalogControllerProvider.notifier).checkoutProduct(currentProduct);
                    },
                    icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black),
                    label: const Text('Buy Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Controls & Floating Toolbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Layer & Matrix Gesture Toolbar
                LayerControlToolbar(
                  isCutoutOnTop: tryOnState.overlayTransform.isCutoutOnTop,
                  opacity: tryOnState.overlayTransform.opacity,
                  onToggleLayerOrder: () => tryOnNotifier.toggleLayerOrder(),
                  onOpacityChanged: (val) => tryOnNotifier.setOpacity(val),
                  onResetTransform: () => tryOnNotifier.resetTransform(),
                  onFitCenter: () {
                    final size = MediaQuery.of(context).size;
                    tryOnNotifier.fitCenter(viewportSize: size);
                  },
                  onCaptureSnapshot: _handleCaptureLook,
                ),
                const SizedBox(height: 8),

                // Silhouette Ingestion & Garment Switch Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showSilhouetteSourcePicker,
                          icon: const Icon(Icons.person_outline, size: 18),
                          label: Text(
                            tryOnState.userCutout != null ? 'Change Silhouette' : 'Add Silhouette',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showProductSelectorModal,
                          icon: const Icon(Icons.checkroom_outlined, size: 18),
                          label: const Text('Change Garment', style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
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
