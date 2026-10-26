import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/models/product.dart';

/// Service for intercepting checkout actions, injecting affiliate attribution parameters,
/// recording telemetry clicks, and launching the commerce checkout webview/browser.
class AffiliateTracker {
  final Dio _dio;
  final String affiliateRef;
  final String subId;

  AffiliateTracker({
    Dio? dio,
    this.affiliateRef = AppConstants.defaultAffiliateRef,
    this.subId = AppConstants.defaultSubId,
  }) : _dio = dio ?? Dio();

  /// Formats checkout URI by appending affiliate tracking query parameters.
  Uri buildAttributedCheckoutUri({
    required Product product,
    String? customSubId,
    String? trackingClickId,
  }) {
    final baseUri = Uri.parse(product.checkoutUrl);
    final clickId = trackingClickId ?? const Uuid().v4();

    final queryParams = Map<String, String>.from(baseUri.queryParameters);
    queryParams['ref'] = affiliateRef;
    queryParams['subid'] = customSubId ?? subId;
    queryParams['click_id'] = clickId;
    queryParams['variant_id'] = product.variantId;
    queryParams['source'] = 'tryon_flutter_app';
    queryParams['t'] = DateTime.now().millisecondsSinceEpoch.toString();

    return baseUri.replace(queryParameters: queryParams);
  }

  /// Logs click attribution event to telemetry backend.
  Future<void> recordClickEvent({
    required Product product,
    required String clickId,
  }) async {
    final payload = {
      'click_id': clickId,
      'product_id': product.id,
      'product_title': product.title,
      'brand': product.brand,
      'price': product.price,
      'currency': product.currency,
      'variant_id': product.variantId,
      'affiliate_ref': affiliateRef,
      'subid': subId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    debugPrint('[AffiliateTracker] Telemetry click recorded: $payload');

    try {
      // Fire-and-forget telemetry ping
      await _dio.post(
        AppConstants.analyticsEndpoint,
        data: payload,
        options: Options(
          sendTimeout: const Duration(milliseconds: 3000),
          receiveTimeout: const Duration(milliseconds: 3000),
        ),
      );
    } catch (e) {
      // Do not block user flow if analytics endpoint is offline / mock
      debugPrint('[AffiliateTracker] Telemetry ping skipped / failed (offline ok): $e');
    }
  }

  /// High-level method to handle product checkout with affiliate attribution.
  Future<bool> launchAttributedCheckout(Product product) async {
    final clickId = const Uuid().v4();
    final attributedUri = buildAttributedCheckoutUri(
      product: product,
      trackingClickId: clickId,
    );

    // Record internal click attribution event
    await recordClickEvent(product: product, clickId: clickId);

    debugPrint('[AffiliateTracker] Launching attributed checkout URL: $attributedUri');

    if (await canLaunchUrl(attributedUri)) {
      return await launchUrl(
        attributedUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint('[AffiliateTracker] Could not launch checkout URL: $attributedUri');
      return false;
    }
  }
}
