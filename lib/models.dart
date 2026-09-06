class Money {
  const Money(this.amount);

  final int amount;
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.label,
    required this.price,
    this.available = true,
  });

  final String id;
  final String label;
  final Money price;
  final bool available;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.variants,
    required this.specifications,
    required this.emoji,
    required this.accent,
    this.emiEligible = true,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final Money price;
  final Money? originalPrice;
  final List<ProductVariant> variants;
  final Map<String, String> specifications;
  final String emoji;
  final int accent;
  final bool emiEligible;
}

class EmiPlan {
  const EmiPlan({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.tenureMonths,
    required this.monthlyInstallment,
    required this.totalPayable,
    required this.annualInterestRate,
    required this.processingFee,
    required this.providerLabel,
    this.isNoCost = false,
  });

  final String id;
  final String productId;
  final String? variantId;
  final int tenureMonths;
  final Money monthlyInstallment;
  final Money totalPayable;
  final double annualInterestRate;
  final Money processingFee;
  final String providerLabel;
  final bool isNoCost;
}

String formatCurrency(Money money) {
  final digits = money.amount.toString();
  if (digits.length <= 3) return '₹$digits';
  final tail = digits.substring(digits.length - 3);
  var head = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (head.length > 2) {
    groups.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) groups.insert(0, head);
  return '₹${groups.join(',')},$tail';
}
