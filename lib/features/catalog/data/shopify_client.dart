import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../domain/models/product.dart';
import 'mock_catalog_data.dart';

/// Client for communicating with Shopify Storefront API (GraphQL/REST) or mock catalog.
class ShopifyClient {
  final Dio _dio;
  final String? shopDomain;
  final String? storefrontAccessToken;

  ShopifyClient({
    Dio? dio,
    this.shopDomain,
    this.storefrontAccessToken,
  }) : _dio = dio ?? Dio();

  /// Fetches products from Storefront API with fallback to offline mock data.
  Future<List<Product>> getProducts({String? query, String? category}) async {
    // If shopDomain or token is missing, seamlessly serve verified mock fashion inventory
    if (shopDomain == null || storefrontAccessToken == null) {
      await Future.delayed(const Duration(milliseconds: 250)); // simulate network latency
      var results = List<Product>.from(MockCatalogData.sampleProducts);

      if (category != null && category.isNotEmpty && category != 'All') {
        results = results.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        results = results.where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }
      return results;
    }

    try {
      final response = await _dio.post(
        'https://$shopDomain/api/2024-01/graphql.json',
        options: Options(
          headers: {
            'X-Shopify-Storefront-Access-Token': storefrontAccessToken,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'query': '''
            query GetProducts(\$first: Int!) {
              products(first: \$first) {
                edges {
                  node {
                    id
                    title
                    vendor
                    description
                    variants(first: 1) {
                      edges {
                        node {
                          id
                          price {
                            amount
                            currencyCode
                          }
                          barcode
                        }
                      }
                    }
                    images(first: 2) {
                      edges {
                        node {
                          url
                        }
                      }
                    }
                  }
                }
              }
            }
          ''',
          'variables': {'first': 20},
        },
      );

      final data = response.data['data']['products']['edges'] as List;
      return data.map((edge) {
        final node = edge['node'];
        final variant = node['variants']['edges'][0]['node'];
        final images = node['images']['edges'] as List;
        final imgUrl = images.isNotEmpty ? images[0]['node']['url'] as String : '';

        return Product(
          id: node['id'] as String,
          title: node['title'] as String,
          brand: node['vendor'] as String? ?? 'Brand',
          description: node['description'] as String? ?? '',
          price: double.tryParse(variant['price']['amount'] as String) ?? 0.0,
          currency: variant['price']['currencyCode'] as String? ?? 'USD',
          transparentCutoutUrl: imgUrl,
          modelPhotoUrl: imgUrl,
          barcode: variant['barcode'] as String? ?? '',
          variantId: variant['id'] as String,
          checkoutUrl: 'https://$shopDomain/products/${node['handle'] ?? ''}',
          category: 'Apparel',
        );
      }).toList();
    } catch (e) {
      debugPrint('[ShopifyClient] Storefront GraphQL error, falling back to mock catalog: $e');
      return MockCatalogData.sampleProducts;
    }
  }

  /// Searches the catalog for a product matching an in-store scanned barcode (UPC / EAN-13).
  Future<Product?> getProductByBarcode(String barcode) async {
    final products = await getProducts();
    try {
      return products.firstWhere(
        (p) => p.barcode.trim() == barcode.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Generates direct checkout session URL with custom cart attributes.
  Future<String> createCheckoutSessionUrl({
    required String variantId,
    Map<String, String>? customAttributes,
  }) async {
    if (shopDomain == null) {
      return 'https://shop.fitpreview.com/cart/$variantId:1';
    }
    // Shopify cart permalink format
    return 'https://$shopDomain/cart/$variantId:1';
  }
}
