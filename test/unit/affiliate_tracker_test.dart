import 'package:flutter_test/flutter_test.dart';
import 'package:tryon/features/catalog/data/affiliate_tracker.dart';
import 'package:tryon/features/catalog/domain/models/product.dart';

void main() {
  group('AffiliateTracker Tests', () {
    const testProduct = Product(
      id: 'test_prod_1',
      title: 'Silk Bomber Jacket',
      brand: 'Acne Studios',
      description: 'Luxe bomber jacket',
      price: 650.0,
      currency: 'USD',
      transparentCutoutUrl: 'https://example.com/jacket.png',
      modelPhotoUrl: 'https://example.com/model.jpg',
      barcode: '123456789012',
      variantId: 'var_9988',
      checkoutUrl: 'https://store.fitpreview.com/checkout/step1',
      category: 'Outerwear',
    );

    test('buildAttributedCheckoutUri appends affiliate parameters correctly', () {
      final tracker = AffiliateTracker(
        affiliateRef: 'custom_ref',
        subId: 'campaign_alpha',
      );

      final uri = tracker.buildAttributedCheckoutUri(
        product: testProduct,
        trackingClickId: 'mock_click_123',
      );

      expect(uri.queryParameters['ref'], equals('custom_ref'));
      expect(uri.queryParameters['subid'], equals('campaign_alpha'));
      expect(uri.queryParameters['click_id'], equals('mock_click_123'));
      expect(uri.queryParameters['variant_id'], equals('var_9988'));
      expect(uri.queryParameters['source'], equals('tryon_flutter_app'));
      expect(uri.queryParameters.containsKey('t'), isTrue);
    });
  });
}
