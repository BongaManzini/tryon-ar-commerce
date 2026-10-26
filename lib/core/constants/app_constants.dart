/// Application-wide constants for TryOn.
class AppConstants {
  static const String appName = 'TryOn';
  static const String appVersion = '1.0.0';
  
  // Storage Box Names
  static const String wishlistStorageBox = 'wishlist_box';
  static const String userPreferencesBox = 'user_prefs_box';
  static const String cachedCatalogBox = 'cached_catalog_box';

  // Affiliate & Tracking Defaults
  static const String defaultAffiliateRef = 'fitpreview';
  static const String defaultSubId = 'app_v1';
  static const String analyticsEndpoint = 'https://api.tryon-vision.com/v1/analytics/click';

  // Segmentation Engine Defaults
  static const double defaultCutoutConfidenceThreshold = 0.65;
  static const double canvasMinScale = 0.2;
  static const double canvasMaxScale = 4.0;
}
