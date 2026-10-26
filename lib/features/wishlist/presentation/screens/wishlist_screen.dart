import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../catalog/presentation/controllers/catalog_controller.dart';
import '../../../try_on/presentation/controllers/try_on_controller.dart';
import '../controllers/wishlist_controller.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistControllerProvider);
    final wishlistNotifier = ref.read(wishlistControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        title: const Text('Saved Looks & Outfits'),
        backgroundColor: const Color(0xFF121214),
        elevation: 0,
      ),
      body: wishlistState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : wishlistState.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark_border_rounded, size: 72, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text(
                        'No Saved Looks Yet',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Compose your silhouette over garments and tap "Save Look" in the Try-On studio.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go(RouteConstants.tryOnPath),
                        icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                        label: const Text('Open Studio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: wishlistState.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, idx) {
                    final item = wishlistState.items[idx];
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Snapshot preview
                          if (item.snapshotBytes != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Container(
                                height: 260,
                                color: Colors.black,
                                child: Image.memory(
                                  item.snapshotBytes!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                          // Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => wishlistNotifier.removeItem(item.id),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${item.product.brand} • \$${item.product.price.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                ),
                                const SizedBox(height: 16),

                                // Actions: Re-open in studio or Checkout
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          final tryOn = ref.read(tryOnControllerProvider.notifier);
                                          tryOn.selectProduct(item.product);
                                          tryOn.restoreTransform(item.overlayTransform);
                                          context.go('${RouteConstants.tryOnPath}?productId=${item.product.id}');
                                        },
                                        icon: const Icon(Icons.edit_outlined, size: 16),
                                        label: const Text('Re-Edit'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.white24),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          ref
                                              .read(catalogControllerProvider.notifier)
                                              .checkoutProduct(item.product);
                                        },
                                        icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black),
                                        label: const Text('Buy Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00E676),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
