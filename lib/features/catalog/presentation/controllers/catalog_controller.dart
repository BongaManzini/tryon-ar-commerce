import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/affiliate_tracker.dart';
import '../data/shopify_client.dart';
import '../domain/models/product.dart';

class CatalogState {
  final bool isLoading;
  final List<Product> products;
  final String selectedCategory;
  final String searchQuery;
  final String? errorMessage;
  final Product? matchedBarcodeProduct;

  const CatalogState({
    this.isLoading = false,
    this.products = const [],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.errorMessage,
    this.matchedBarcodeProduct,
  });

  CatalogState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
    Product? matchedBarcodeProduct,
  }) {
    return CatalogState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      matchedBarcodeProduct: matchedBarcodeProduct,
    );
  }
}

class CatalogController extends StateNotifier<CatalogState> {
  final ShopifyClient _shopifyClient;
  final AffiliateTracker _affiliateTracker;

  CatalogController(this._shopifyClient, this._affiliateTracker)
      : super(const CatalogState()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final products = await _shopifyClient.getProducts(
        category: state.selectedCategory,
        query: state.searchQuery,
      );
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    loadProducts();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadProducts();
  }

  Future<Product?> lookupBarcode(String barcode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final product = await _shopifyClient.getProductByBarcode(barcode);
      state = state.copyWith(isLoading: false, matchedBarcodeProduct: product);
      return product;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> checkoutProduct(Product product) async {
    return await _affiliateTracker.launchAttributedCheckout(product);
  }
}

final shopifyClientProvider = Provider<ShopifyClient>((ref) {
  return ShopifyClient();
});

final affiliateTrackerProvider = Provider<AffiliateTracker>((ref) {
  return AffiliateTracker();
});

final catalogControllerProvider =
    StateNotifierProvider<CatalogController, CatalogState>((ref) {
  final shopify = ref.watch(shopifyClientProvider);
  final tracker = ref.watch(affiliateTrackerProvider);
  return CatalogController(shopify, tracker);
});
