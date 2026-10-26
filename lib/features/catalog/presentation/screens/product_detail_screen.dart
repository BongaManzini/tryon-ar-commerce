import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../try_on/presentation/controllers/try_on_controller.dart';
import '../controllers/catalog_controller.dart';
import '../domain/models/product.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogState = ref.watch(catalogControllerProvider);
    final Product? product = catalogState.products.cast<Product?>().firstWhere(
          (p) => p?.id == productId,
          orElse: () => null,
        );

    if (product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121214),
        appBar: AppBar(title: const Text('Product Detail')),
        body: const Center(
          child: Text('Product not found', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: const Color(0xFF1E1E24),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                product.transparentCutoutUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.checkroom, size: 80, color: Colors.grey),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.view_in_ar_outlined),
                tooltip: 'Live AR Placement',
                onPressed: () => context.push(RouteConstants.arLiveViewPath),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.brand.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    product.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)} ${product.currency}',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.grey.shade400, height: 1.5, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // In-Store Barcode Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E24),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, color: Colors.white70, size: 28),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'In-Store Product Tag',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'UPC / Barcode: ${product.barcode}',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(tryOnControllerProvider.notifier).selectProduct(product);
                            context.push('${RouteConstants.tryOnPath}?productId=${product.id}');
                          },
                          icon: const Icon(Icons.auto_fix_high_rounded),
                          label: const Text('Try On Look'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(catalogControllerProvider.notifier).checkoutProduct(product);
                          },
                          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                          label: const Text('Direct Buy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
