import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final int quantity;
  final String size;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.size,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    int? quantity,
    String? size,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
    );
  }

  double get total => price * quantity;
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  double _subtotal = 0;
  double _shipping = 5.99;
  double _tax = 0;

  List<CartItem> get items => [..._items];
  int get itemCount => _items.length;
  double get subtotal => _subtotal;
  double get shipping => _shipping;
  double get tax => _tax;
  double get total => _subtotal + _shipping + _tax;

  void addToCart(Map<String, dynamic> product, int quantity, {String size = 'M'}) {
    final existingIndex = _items.indexWhere((item) => 
      item.id == product['name'] && item.size == size
    );

    if (existingIndex >= 0) {
      // Update existing item
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item
      _items.add(
        CartItem(
          id: product['name'],
          name: product['name'],
          price: product['price'],
          image: product['image'],
          quantity: quantity,
          size: size,
        ),
      );
    }

    _updateTotals();
    notifyListeners();
  }

  void removeFromCart(String id, String size) {
    _items.removeWhere((item) => item.id == id && item.size == size);
    _updateTotals();
    notifyListeners();
  }

  void updateQuantity(String id, String size, int quantity) {
    final index = _items.indexWhere(
      (item) => item.id == id && item.size == size,
    );

    if (index >= 0) {
      if (quantity > 0) {
        _items[index] = _items[index].copyWith(quantity: quantity);
      } else {
        _items.removeAt(index);
      }
      _updateTotals();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _updateTotals();
    notifyListeners();
  }

  void _updateTotals() {
    _subtotal = _items.fold(0, (sum, item) => sum + item.total);
    _tax = _subtotal * 0.08; // 8% tax
  }
} 