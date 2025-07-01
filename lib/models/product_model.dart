class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final node = json['node'];
    final priceRange = node['priceRange']['minVariantPrice'];
    final images = node['images']['edges'];
    final variants = node['variants']['edges'] as List;

    return Product(
      id: node['id'],
      title: node['title'],
      description: node['description'],
      price: double.parse(priceRange['amount']),
      imageUrl: images.isNotEmpty ? images[0]['node']['url'] : 'https://via.placeholder.com/300',
      variants: variants.map((variant) => ProductVariant.fromJson(variant['node'])).toList(),
    );
  }
}

class ProductVariant {
  final String id;
  final String title;
  final double price;

  ProductVariant({
    required this.id,
    required this.title,
    required this.price,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      title: json['title'],
      price: double.parse(json['price']['amount']),
    );
  }
} 