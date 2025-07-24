import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/shopify_service.dart';
import '../utils/constants.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/wishlist_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/location_provider.dart';
import '../screens/shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ShopifyService _shopifyService;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _productsData;

  final List<String> _promotions = [
    'END YEAR SALE UP TO 50% OFF',
    'SIGN UP AND GET 10% OFF YOUR FIRST ORDER',
    'FREE DELIVERY FOR ORDER OVER \$120',
  ];

  @override
  void initState() {
    super.initState();
    _shopifyService = Provider.of<ShopifyService>(context, listen: false);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _shopifyService.getProducts();
      
      if (mounted) {
        setState(() {
          _productsData = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
      print('Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCarousel(),
                    _buildPromotionBanner(),
                    _buildCategories(),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                'Error loading products: $_error',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProducts,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_productsData == null || 
                            _productsData!['products'] == null || 
                            (_productsData!['products']['edges'] as List).isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('No products found'),
                        ),
                      )
                    else ...[
                      _buildFeaturedProducts(),
                      _buildBestSellers(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 60, // Increased height for larger logo
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Image.asset(
          'assets/images/elefit_logo.png',
          height: 48, // Increased logo height
          fit: BoxFit.fitHeight,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppTheme.primaryColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeroCarousel() {
    return SizedBox(
      height: 400,
      child: FlutterCarousel(
        options: CarouselOptions(
          height: 400,
          showIndicator: true,
          slideIndicator: CircularSlideIndicator(),
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
        ),
        items: [1, 2, 3].map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Image.network(
                        AppConstants.placeholderImage,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Stay active together!',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'SERVE YOUR\nBEST GAME!',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'A balanced lifestyle leads to long-term success in fitness and well-being.',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryColor,
                            ),
                            child: Text(
                              'Shop and stay fit',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      height: 50,
      color: AppTheme.primaryColor,
      child: FlutterCarousel(
        options: CarouselOptions(
          height: 50,
          showIndicator: false,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
        ),
        items: _promotions.map((promo) {
          return Builder(
            builder: (BuildContext context) {
              return Center(
                child: Text(
                  promo,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': 'Gear Up', 'count': '4 Products', 'icon': Icons.fitness_center},
      {'name': 'Inspire', 'count': '2 Products', 'icon': Icons.card_giftcard},
      {'name': 'Sale', 'count': '6 Products', 'icon': Icons.local_offer},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHOP BY CATEGORY',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShopScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 32,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category['count'] as String,
                        style: GoogleFonts.poppins(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FEATURED',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShopScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    'Shop all',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: _productsData == null
                ? const Center(child: Text('No products found'))
                : _buildProductList(_productsData!),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(Map<String, dynamic> data) {
    final products = (data['products']['edges'] as List)
        .map((edge) => edge['node'] as Map<String, dynamic>)
        .take(5)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          width: 200,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/product-details',
                  arguments: {
                    'product': {
                      'id': product['id'],
                      'name': product['title'],
                      'price': double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0,
                      'image': product['images']['edges'].isNotEmpty 
                          ? product['images']['edges'][0]['node']['url'] 
                          : AppConstants.productPlaceholder,
                      'images': (product['images']['edges'] as List)
                          .map((edge) => edge['node']['url'] as String)
                          .toList(),
                      'description': product['description'],
                      'variants': product['variants'],  // Add this line to include variants
                    },
                  },
                );
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              product['images']['edges'].isNotEmpty 
                                  ? product['images']['edges'][0]['node']['url'] 
                                  : AppConstants.productPlaceholder,
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
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Consumer<WishlistModel>(
                                builder: (context, wishlist, child) {
                                  final isInWishlist = wishlist.isInWishlist(product['id']);
                                  return IconButton(
                                    icon: Icon(
                                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                                      color: isInWishlist ? Colors.red : null,
                                    ),
                                    onPressed: () {
                                      wishlist.toggleWishlist({
                                        'id': product['id'],
                                        'title': product['title'],
                                        'price': double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0,
                                        'imageUrl': product['images']['edges'].isNotEmpty 
                                            ? product['images']['edges'][0]['node']['url'] 
                                            : AppConstants.productPlaceholder,
                                        'description': product['description'],
                                      });
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title'] ?? '',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.read<LocationProvider>().formatPrice(
                                  double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0
                                ),
                                style: GoogleFonts.poppins(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  final variants = product['variants']['edges'];
                                  if (variants != null && variants.isNotEmpty) {
                                    // Extract just the numeric ID from the variant ID
                                    final variantId = variants[0]['node']['id'].toString();
                                    final numericId = variantId.split('/').last;
                                    context.read<CartModel>().addToCart(
                                      {
                                        'id': product['id'],
                                        'title': product['title'],
                                        'price': double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0,
                                        'imageUrl': product['images']['edges'].isNotEmpty 
                                            ? product['images']['edges'][0]['node']['url'] 
                                            : AppConstants.productPlaceholder,
                                        'description': product['description'],
                                      },
                                      numericId,
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
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Product variant not available'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBestSellers() {
    if (_productsData == null) {
      return const SizedBox.shrink();
    }

    final products = (_productsData!['products']['edges'] as List)
        .map((edge) => edge['node'] as Map<String, dynamic>)
        .take(4)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BEST-SELLING PRODUCTS',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Shop all',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/product-details',
                      arguments: {
                        'product': {
                          'id': product['id'],
                          'name': product['title'],
                          'price': double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0,
                          'image': product['images']['edges'].isNotEmpty 
                              ? product['images']['edges'][0]['node']['url'] 
                              : AppConstants.productPlaceholder,
                          'images': (product['images']['edges'] as List)
                              .map((edge) => edge['node']['url'] as String)
                              .toList(),
                          'description': product['description'],
                        },
                      },
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                product['images']['edges'].isNotEmpty 
                                    ? product['images']['edges'][0]['node']['url'] 
                                    : AppConstants.productPlaceholder,
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
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Consumer<WishlistModel>(
                                  builder: (context, wishlist, child) {
                                    final isInWishlist = wishlist.isInWishlist(product['id']);
                                    return IconButton(
                                      icon: Icon(
                                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                                        color: isInWishlist ? Colors.red : null,
                                      ),
                                      onPressed: () {
                                        wishlist.toggleWishlist({
                                          'id': product['id'],
                                          'title': product['title'],
                                          'price': double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0,
                                          'imageUrl': product['images']['edges'].isNotEmpty 
                                              ? product['images']['edges'][0]['node']['url'] 
                                              : AppConstants.productPlaceholder,
                                          'description': product['description'],
                                        });
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title'] ?? '',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    context.read<LocationProvider>().formatPrice(
                                      double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: IconButton(
                                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      context.read<CartModel>().addToCart(
                                        {
                                          'id': product['id'],
                                          'title': product['title'],
                                          'price': double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0,
                                          'imageUrl': product['images']['edges'].isNotEmpty 
                                              ? product['images']['edges'][0]['node']['url'] 
                                              : AppConstants.productPlaceholder,
                                          'description': product['description'],
                                          'variantId': product['variants']['edges'][0]['node']['id'], // Add the variant ID
                                        },
                                        product['variants']['edges'][0]['node']['id'], // Use the variant ID as the cart item ID
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
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 