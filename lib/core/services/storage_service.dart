import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Abstraction layer over Hive for high-performance offline storage.
class StorageService {
  bool _initialized = false;
  late Box<dynamic> _wishlistBox;
  late Box<dynamic> _prefsBox;
  late Box<dynamic> _catalogBox;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _wishlistBox = await Hive.openBox(AppConstants.wishlistStorageBox);
      _prefsBox = await Hive.openBox(AppConstants.userPreferencesBox);
      _catalogBox = await Hive.openBox(AppConstants.cachedCatalogBox);
      _initialized = true;
      debugPrint('[StorageService] Hive initialized successfully.');
    } catch (e, stack) {
      debugPrint('[StorageService] Error initializing Hive: $e\n$stack');
      throw StorageException('Failed to initialize local storage', cause: e);
    }
  }

  // Wishlist Storage Operations
  Future<void> saveWishlistItem(String id, Map<String, dynamic> itemMap) async {
    _ensureInitialized();
    await _wishlistBox.put(id, itemMap);
  }

  Map<String, dynamic>? getWishlistItem(String id) {
    _ensureInitialized();
    final data = _wishlistBox.get(id);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  List<Map<String, dynamic>> getAllWishlistItems() {
    _ensureInitialized();
    return _wishlistBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> deleteWishlistItem(String id) async {
    _ensureInitialized();
    await _wishlistBox.delete(id);
  }

  // Catalog Cache Operations
  Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    _ensureInitialized();
    await _catalogBox.put('products', products);
  }

  List<Map<String, dynamic>>? getCachedProducts() {
    _ensureInitialized();
    final data = _catalogBox.get('products');
    if (data == null) return null;
    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // Generic Preferences Operations
  Future<void> setPreference(String key, dynamic value) async {
    _ensureInitialized();
    await _prefsBox.put(key, value);
  }

  dynamic getPreference(String key, {dynamic defaultValue}) {
    _ensureInitialized();
    return _prefsBox.get(key, defaultValue: defaultValue);
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StorageException('StorageService called before initialization');
    }
  }

  Future<void> clearAll() async {
    _ensureInitialized();
    await _wishlistBox.clear();
    await _prefsBox.clear();
    await _catalogBox.clear();
  }
}
