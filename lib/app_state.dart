import 'package:flutter/foundation.dart';

import 'models.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.variant,
    this.quantity = 1,
  });

  final Product product;
  final ProductVariant? variant;
  final int quantity;

  String get key => '${product.id}:${variant?.id ?? 'default'}';
  Money get unitPrice => variant?.price ?? product.price;
  Money get total => Money(unitPrice.amount * quantity);

  CartItem copyWith({int? quantity}) => CartItem(
    product: product,
    variant: variant,
    quantity: quantity ?? this.quantity,
  );
}

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.product,
    required this.variant,
    required this.quantity,
    required this.total,
    required this.paymentLabel,
    required this.createdAt,
    this.emiPlan,
  });

  final String id;
  final Product product;
  final ProductVariant? variant;
  final int quantity;
  final Money total;
  final String paymentLabel;
  final DateTime createdAt;
  final EmiPlan? emiPlan;
}

class MarketplaceAppState extends ChangeNotifier {
  final List<CartItem> _cart = [];
  final List<PurchaseOrder> _orders = [];
  int _orderSequence = 1042;

  List<CartItem> get cart => List.unmodifiable(_cart);
  List<PurchaseOrder> get orders => List.unmodifiable(_orders.reversed);
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  Money get cartTotal =>
      Money(_cart.fold(0, (sum, item) => sum + item.total.amount));
  List<PurchaseOrder> get emiOrders =>
      orders.where((order) => order.emiPlan != null).toList(growable: false);

  void addToCart(Product product, ProductVariant? variant) {
    final key = '${product.id}:${variant?.id ?? 'default'}';
    final index = _cart.indexWhere((item) => item.key == key);
    if (index == -1) {
      _cart.add(CartItem(product: product, variant: variant));
    } else {
      _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
    }
    notifyListeners();
  }

  void updateQuantity(String key, int quantity) {
    final index = _cart.indexWhere((item) => item.key == key);
    if (index == -1) return;
    if (quantity <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index] = _cart[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  PurchaseOrder purchaseWithEmi(
    Product product,
    ProductVariant? variant,
    EmiPlan plan,
  ) {
    final order = _newOrder(
      product: product,
      variant: variant,
      quantity: 1,
      total: plan.totalPayable,
      paymentLabel: '${plan.tenureMonths}-month EMI',
      emiPlan: plan,
    );
    _orders.add(order);
    notifyListeners();
    return order;
  }

  List<PurchaseOrder> purchaseCart() {
    final purchased = _cart
        .map(
          (item) => _newOrder(
            product: item.product,
            variant: item.variant,
            quantity: item.quantity,
            total: item.total,
            paymentLabel: 'Paid in full',
          ),
        )
        .toList(growable: false);
    _orders.addAll(purchased);
    _cart.clear();
    notifyListeners();
    return purchased;
  }

  PurchaseOrder _newOrder({
    required Product product,
    required ProductVariant? variant,
    required int quantity,
    required Money total,
    required String paymentLabel,
    EmiPlan? emiPlan,
  }) {
    _orderSequence += 1;
    return PurchaseOrder(
      id: '1FI-$_orderSequence',
      product: product,
      variant: variant,
      quantity: quantity,
      total: total,
      paymentLabel: paymentLabel,
      createdAt: DateTime.now(),
      emiPlan: emiPlan,
    );
  }
}
