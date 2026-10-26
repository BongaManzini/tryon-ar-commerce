import '../../../core/services/storage_service.dart';
import '../domain/models/wishlist_item.dart';

abstract class WishlistRepository {
  Future<void> saveItem(WishlistItem item);
  List<WishlistItem> getItems();
  Future<void> deleteItem(String id);
}

class WishlistRepositoryImpl implements WishlistRepository {
  final StorageService _storageService;

  WishlistRepositoryImpl(this._storageService);

  @override
  Future<void> saveItem(WishlistItem item) async {
    await _storageService.saveWishlistItem(item.id, item.toJson());
  }

  @override
  List<WishlistItem> getItems() {
    try {
      final rawList = _storageService.getAllWishlistItems();
      final items = rawList.map((e) => WishlistItem.fromJson(e)).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    await _storageService.deleteWishlistItem(id);
  }
}
