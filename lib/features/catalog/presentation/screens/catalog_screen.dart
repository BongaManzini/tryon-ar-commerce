import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../try_on/presentation/controllers/try_on_controller.dart';
import '../controllers/catalog_controller.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Outerwear', 'Tops', 'Bottoms'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogControllerProvider);
    final catalogNotifier = ref.read(catalogControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121214),
        elevation: 0,
        title: const Text(
          'FitPreview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'In-Store Barcode Scan',
            onPressed: () => context.push(RouteConstants.barcodeScannerPath),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded),
            tooltip: 'Wishlist & Saved Looks',
            onPressed: () => context.push(RouteConstants.wishlistPath),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => catalogNotifier.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search styles, brands, garments...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          catalogNotifier.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final category = _categories[idx];
                final isSelected = catalogState.selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6C63FF),
                  backgroundColor: const Color(0xFF1E1E24),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => catalogNotifier.setCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Product Grid
          Expanded(
            child: catalogState.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                : catalogState.products.isEmpty
                    ? Center(
                        child: Text(
                          'No garments found.',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.64,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: catalogState.products.length,
                        itemBuilder: (context, idx) {
                          final product = catalogState.products[idx];
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E24),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Image with quick try-on badge
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                        child: Container(
                                          color: Colors.black26,
                                          width: double.infinity,
                                          child: Image.network(
                                            product.transparentCutoutUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Center(
                                              child: Icon(Icons.checkroom, color: Colors.grey, size: 40),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            product.category,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Metadata
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.brand.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Color(0xFF00E676),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Try-On CTA Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            ref.read(tryOnControllerProvider.notifier).selectProduct(product);
                                            context.push('${RouteConstants.tryOnPath}?productId=${product.id}');
                                          },
                                          icon: const Icon(Icons.auto_fix_high_rounded, size: 14),
                                          label: const Text('Try On'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6C63FF),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
