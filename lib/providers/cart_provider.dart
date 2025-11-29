import 'package:flutter/material.dart';
import 'package:finalboer/models/cart_item.dart';
import 'package:finalboer/models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  // Feature 3: Subtotal
  double get subtotal {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.product.price * item.quantity;
    });
    return total;
  }

  // Adicionar ao carrinho
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          id: existing.id,
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(id: product.id, product: product),
      );
    }
    notifyListeners();
  }

  // Feature 2: Remover item [cite: 561]
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Feature 1: Decrementar quantidade [cite: 558]
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (existing) => CartItem(
              id: existing.id,
              product: existing.product,
              quantity: existing.quantity - 1));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Feature 4: Limpar carrinho [cite: 568]
  void clear() {
    _items.clear();
    notifyListeners();
  }
}