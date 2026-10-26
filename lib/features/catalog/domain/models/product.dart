/// Product entity model representing retail garments with transparent try-on cuts and commerce metadata.
class Product {
  final String id;
  final String title;
  final String brand;
  final String description;
  final double price;
  final String currency;
  final String transparentCutoutUrl;
  final String modelPhotoUrl;
  final String barcode;
  final String variantId;
  final String checkoutUrl;
  final String category;
  final List<String> tags;
  final bool isAvailable;

  const Product({
    required this.id,
    required this.title,
    required this.brand,
    required this.description,
    required this.price,
    this.currency = 'USD',
    required this.transparentCutoutUrl,
    required this.modelPhotoUrl,
    required this.barcode,
    required this.variantId,
    required this.checkoutUrl,
    required this.category,
    this.tags = const [],
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brand': brand,
      'description': description,
      'price': price,
      'currency': currency,
      'transparentCutoutUrl': transparentCutoutUrl,
      'modelPhotoUrl': modelPhotoUrl,
      'barcode': barcode,
      'variantId': variantId,
      'checkoutUrl': checkoutUrl,
      'category': category,
      'tags': tags,
      'isAvailable': isAvailable,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      brand: json['brand'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      transparentCutoutUrl: json['transparentCutoutUrl'] as String,
      modelPhotoUrl: json['modelPhotoUrl'] as String? ?? json['transparentCutoutUrl'] as String,
      barcode: json['barcode'] as String,
      variantId: json['variantId'] as String,
      checkoutUrl: json['checkoutUrl'] as String,
      category: json['category'] as String? ?? 'General',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
