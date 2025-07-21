import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/shopify_service.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../models/wishlist_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopifyService _shopifyService = ShopifyService();
  List<Product> _products = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Accessories', 'Bags', 'Apparel', 'Equipment'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final productsData = await _shopifyService.getProducts();
      if (productsData != null) {
        final List<Product> products = (productsData['products']['edges'] as List)
            .map<Product>((edge) => Product.fromJson(edge))
            .toList();
        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to load products');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('An error occurred while loading products');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _buildCategories(),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      title: const Text('Shop'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final filteredProducts = _selectedCategory == 'All'
        ? _products
        : _products.where((p) => p.title.contains(_selectedCategory)).toList();

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = filteredProducts[index];
          return Hero(
            tag: 'product_${product.id}',
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/product-details',
                    arguments: {
                      'product': {
                        'id': product.id,
                        'name': product.title,
                        'price': product.price,
                        'image': product.imageUrl,
                        'images': product.images,
                        'description': product.description,
                        'compareAtPrice': product.compareAtPrice,
                      },
                    },
                  );
                },
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Stack(
                      children: [
                          Positioned.fill(
                          child: Image.network(
                              product.imageUrl,
                            fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          if (product.compareAtPrice != null && product.compareAtPrice! > product.price)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${(((product.compareAtPrice! - product.price) / product.compareAtPrice!) * 100).round()}% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                            child: Consumer<WishlistModel>(
                              builder: (context, wishlist, child) {
                                final isInWishlist = wishlist.items.any((item) => item.id == product.id);
                                return IconButton(
                                  icon: Icon(
                                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                                    color: isInWishlist ? Colors.red : null,
                                  ),
                                  onPressed: () {
                                    wishlist.toggleWishlist({
                                      'id': product.id,
                                      'title': product.title,
                                      'price': product.price,
                                      'imageUrl': product.imageUrl,
                                      'description': product.description,
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isInWishlist ? 'Removed from wishlist' : 'Added to wishlist',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        duration: const Duration(seconds: 2),
                                        action: SnackBarAction(
                                          label: 'VIEW WISHLIST',
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => const WishlistScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(8),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        ),
                    ),
                    Expanded(
                      child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              product.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (product.compareAtPrice != null && product.compareAtPrice! > product.price)
                                      Text(
                                        '\$${product.compareAtPrice!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          decoration: TextDecoration.lineThrough,
                                          fontSize: 12,
                                        ),
                                      ),
                          Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                                        color: product.compareAtPrice != null && product.compareAtPrice! > product.price
                                            ? AppTheme.saleColor
                                            : AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                                ),
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                                    onPressed: () {
                                      context.read<CartModel>().addToCart(
                                        {
                                          'id': product.id,
                                          'title': product.title,
                                          'price': product.price,
                                          'imageUrl': product.imageUrl,
                                          'description': product.description,
                                        },
                                        product.id,
                                        1,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added to cart',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: filteredProducts.length,
      ),
    );
  }
} 