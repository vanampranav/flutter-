import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/shopify_service.dart';
import 'auth_screen.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/wishlist_model.dart';
import '../models/fitness_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ShopifyService _shopifyService = ShopifyService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        final userData = await _shopifyService.getCurrentUser(token);
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      // Clear cart and wishlist
      context.read<CartModel>().clearCart();
      context.read<WishlistModel>().clearWishlist();
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userData == null) {
      return const AuthScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserHeader(),
              const SizedBox(height: 24),
              _buildDashboardStats(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
              const SizedBox(height: 24),
              _buildWorkoutProgress(),
              const SizedBox(height: 24),
              _buildAccountSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            _userData!['firstName'][0].toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_userData!['firstName']} ${_userData!['lastName']}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _userData!['email'],
                style: GoogleFonts.poppins(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Orders',
          '${_userData!['orders']?.length ?? 0}',
          Icons.shopping_bag_outlined,
        ),
        _buildStatCard(
          'Wishlist',
          context.watch<WishlistModel>().items.length.toString(),
          Icons.favorite_outline,
        ),
        _buildStatCard(
          'Workouts',
          context.watch<FitnessModel>().workoutPlans.length.toString(),
          Icons.fitness_center,
        ),
        _buildStatCard(
          'Goals',
          context.watch<FitnessModel>().goals.length.toString(),
          Icons.flag_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    index == 0 ? Icons.shopping_bag_outlined :
                    index == 1 ? Icons.fitness_center :
                    Icons.favorite_outline,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(
                  index == 0 ? 'Order #1234 Delivered' :
                  index == 1 ? 'Completed Workout' :
                  'Added item to wishlist',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '2 hours ago',
                  style: GoogleFonts.poppins(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppTheme.secondaryTextColor,
                ),
                onTap: () {
                  // TODO: Navigate to activity detail
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Progress',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weekly Goal',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '4/5 workouts',
                      style: GoogleFonts.poppins(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.8,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    final settings = [
      {'title': 'Edit Profile', 'icon': Icons.person_outline},
      {'title': 'Order History', 'icon': Icons.history},
      {'title': 'Shipping Addresses', 'icon': Icons.location_on_outlined},
      {'title': 'Payment Methods', 'icon': Icons.payment},
      {'title': 'Notifications', 'icon': Icons.notifications_outlined},
      {'title': 'Privacy Settings', 'icon': Icons.privacy_tip_outlined},
      {'title': 'Help & Support', 'icon': Icons.help_outline},
      {'title': 'Logout', 'icon': Icons.logout},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settings.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final setting = settings[index];
              return ListTile(
                leading: Icon(
                  setting['icon'] as IconData,
                  color: setting['title'] == 'Logout' ? Colors.red : AppTheme.primaryColor,
                ),
                title: Text(
                  setting['title'] as String,
                  style: GoogleFonts.poppins(
                    color: setting['title'] == 'Logout' ? Colors.red : null,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppTheme.secondaryTextColor,
                ),
                onTap: () {
                  if (setting['title'] == 'Logout') {
                    _logout();
                  }
                  // TODO: Implement other settings
                },
              );
            },
          ),
        ),
      ],
    );
  }
} 