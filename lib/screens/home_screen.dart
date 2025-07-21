import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/shopify_service.dart';
import '../utils/constants.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/wishlist_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blog_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShopifyService _shopifyService = ShopifyService();
  final List<String> _promotions = [
    'END YEAR SALE UP TO 50% OFF',
    'SIGN UP AND GET 10% OFF YOUR FIRST ORDER',
    'FREE DELIVERY FOR ORDER OVER \$120',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
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
                    _buildFeaturedProducts(),
                    _buildBestSellers(),
                    _buildBlogSection(),
                    _buildNewsletterSection(),
                    const SizedBox(height: 24), // Bottom padding
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            AppConstants.appName,
            style: GoogleFonts.poppins(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
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
                child: InkWell(
                  onTap: () {},
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
                TextButton(
                  onPressed: () {
                    // Navigate to shop screen with featured filter
                  },
                  child: Text(
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
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _shopifyService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
  }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading products',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                final productsData = snapshot.data;
                if (productsData == null) {
                  return const Center(child: Text('No products found'));
                }

                final products = (productsData['products']['edges'] as List)
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
                                },
                              },
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
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
                                    ),
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
                                          '\$${(double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0).toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            color: AppTheme.accentColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_shopping_cart),
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
                                              },
                                              product['id'],
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
              );
            },
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildBestSellers() {
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
                onPressed: () {
                  // Navigate to shop screen with best sellers filter
                },
                child: Text(
                  'Shop all',
                  style: GoogleFonts.poppins(),
                ),
            ),
          ],
        ),
        const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>?>(
            future: _shopifyService.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading products',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              final productsData = snapshot.data;
              if (productsData == null) {
                return const Center(child: Text('No products found'));
              }

              final products = (productsData['products']['edges'] as List)
                  .map((edge) => edge['node'] as Map<String, dynamic>)
                  .take(4)
                  .toList();

              return GridView.builder(
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
                            Text(
                                      '\$${(double.tryParse(product['priceRange']['minVariantPrice']['amount'].toString()) ?? 0.0).toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                                        fontSize: 16,
                              ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_shopping_cart),
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
                                          },
                                          product['id'],
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
              );
            },
          ),
      ],
      ),
    );
  }

  Widget _buildBlogSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey.shade50,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Our amazing media',
            style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@ELEFITSTORE',
            style: GoogleFonts.poppins(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
          ),
        ),
          const SizedBox(height: 24),
          FutureBuilder<Map<String, dynamic>?>(
            future: _shopifyService.getBlogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading blogs',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              final blogsData = snapshot.data;
              if (blogsData == null) {
                return const Center(child: Text('No blogs found'));
              }

              final blogs = (blogsData['blogs']['edges'] as List)
                  .map((edge) => edge['node'] as Map<String, dynamic>)
                  .toList();

              if (blogs.isEmpty) {
                return Center(
                  child: Text(
                    'No blog posts available',
                    style: GoogleFonts.poppins(),
                  ),
                );
              }

              // Get the first blog's articles
              final articles = (blogs[0]['articles']['edges'] as List)
                  .map((edge) => edge['node'] as Map<String, dynamic>)
                  .take(4)
                  .toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  final imageUrl = article['image']?['url'] ?? AppConstants.blogPlaceholder;
                  final publishedAt = article['publishedAt'] != null
                      ? DateFormat.yMMMd().format(DateTime.parse(article['publishedAt']))
                      : null;

                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlogScreen(
                              title: article['title'],
                              imageUrl: imageUrl,
                              content: article['content'],
                              publishedAt: publishedAt,
                              authorName: article['author']?['name'],
                            ),
                          ),
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
                                    imageUrl,
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
                                  Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                colors: [
                                          Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                                      ),
              ),
            ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article['title'],
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (publishedAt != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            publishedAt,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                Text(
                                              'READ MORE',
                                              style: GoogleFonts.poppins(
                    color: Colors.white,
                                                fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward,
                    color: Colors.white,
                                              size: 16,
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
      ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsletterSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppTheme.primaryColor,
      child: Column(
      children: [
        Text(
            'Sign up & stay ahead.',
            style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: GoogleFonts.poppins(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: TextButton(
                onPressed: () {},
                child: Text(
                  'Subscribe',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 