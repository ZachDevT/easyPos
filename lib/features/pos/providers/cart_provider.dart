import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final int productId;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
  
  double get total => price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(int productId, String name, double price) {
    final existingIndex = state.indexWhere((item) => item.productId == productId);
    
    if (existingIndex >= 0) {
      // Increase quantity
      final existingItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(quantity: existingItem.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new
      state = [...state, CartItem(productId: productId, name: name, price: price)];
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.productId == productId)
          item.copyWith(quantity: quantity)
        else
          item
    ];
  }

  void removeProduct(int productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void clearCart() {
    state = [];
  }

  double get subtotal => state.fold(0, (sum, item) => sum + item.total);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
