import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistItem {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String description;

  WishlistItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      title: json['title'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }
}

class WishlistModel extends ChangeNotifier {
  List<WishlistItem> _items = [];
  late SharedPreferences _prefs;
  bool _initialized = false;

  WishlistModel() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadWishlist();
    _initialized = true;
  }

  Future<void> _loadWishlist() async {
    final String? wishlistJson = _prefs.getString('wishlist');
    if (wishlistJson != null) {
      final List<dynamic> wishlistList = json.decode(wishlistJson);
      _items = wishlistList.map((item) => WishlistItem.fromJson(item)).toList();
    }
  }

  Future<void> _saveWishlist() async {
    if (!_initialized) return;
    final String wishlistJson = json.encode(_items.map((item) => item.toJson()).toList());
    await _prefs.setString('wishlist', wishlistJson);
  }

  List<WishlistItem> get items => [..._items];
  int get itemCount => _items.length;

  void toggleWishlist(Map<String, dynamic> product) {
    final existingIndex = _items.indexWhere((item) => item.id == product['id']);

    if (existingIndex >= 0) {
      _items.removeAt(existingIndex);
    } else {
      _items.add(
        WishlistItem(
          id: product['id'],
          title: product['title'],
          price: double.parse(product['price'].toString()),
          imageUrl: product['imageUrl'],
          description: product['description'] ?? '',
        ),
      );
    }

    _saveWishlist();
    notifyListeners();
  }

  void removeFromWishlist(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveWishlist();
    notifyListeners();
  }

  void clearWishlist() {
    _items.clear();
    _saveWishlist();
    notifyListeners();
  }

  bool isInWishlist(String id) {
    return _items.any((item) => item.id == id);
  }
} 