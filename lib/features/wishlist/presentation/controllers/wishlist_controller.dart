import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../../catalog/domain/models/product.dart';
import '../../try_on/domain/models/overlay_transform.dart';
import '../data/wishlist_repository.dart';
import '../domain/models/wishlist_item.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return WishlistRepositoryImpl(storage);
});

class WishlistState {
  final bool isLoading;
  final List<WishlistItem> items;
  final String? errorMessage;

  const WishlistState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  WishlistState copyWith({
    bool? isLoading,
    List<WishlistItem>? items,
    String? errorMessage,
  }) {
    return WishlistState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

class WishlistController extends StateNotifier<WishlistState> {
  final WishlistRepository _repository;

  WishlistController(this._repository) : super(const WishlistState()) {
    loadWishlist();
  }

  void loadWishlist() {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = _repository.getItems();
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> saveOutfit({
    required String title,
    required Product product,
    required OverlayTransform overlayTransform,
    Uint8List? snapshotBytes,
  }) async {
    final item = WishlistItem(
      id: const Uuid().v4(),
      title: title.isEmpty ? '${product.title} Fit' : title,
      product: product,
      overlayTransform: overlayTransform,
      snapshotBytes: snapshotBytes,
      createdAt: DateTime.now(),
    );

    await _repository.saveItem(item);
    loadWishlist();
  }

  Future<void> removeItem(String id) async {
    await _repository.deleteItem(id);
    loadWishlist();
  }
}

final wishlistControllerProvider =
    StateNotifierProvider<WishlistController, WishlistState>((ref) {
  final repo = ref.watch(wishlistRepositoryProvider);
  return WishlistController(repo);
});
