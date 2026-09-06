import 'models.dart';

abstract interface class MarketplaceService {
  Future<List<Product>> getProducts([String query = '']);
  Future<Product> getProduct(String productId);
  Future<List<EmiPlan>> getEmiPlans(String productId, [String? variantId]);
}

class MarketplaceException implements Exception {
  const MarketplaceException(this.message);
  final String message;
  @override
  String toString() => message;
}

class MockMarketplaceService implements MarketplaceService {
  MockMarketplaceService({this.delay = const Duration(milliseconds: 450)});

  final Duration delay;
  bool failNextRequest = false;

  Future<void> _wait() async {
    await Future<void>.delayed(delay);
    if (failNextRequest) {
      failNextRequest = false;
      throw const MarketplaceException('The marketplace is taking a break.');
    }
  }

  @override
  Future<List<Product>> getProducts([String query = '']) async {
    await _wait();
    final term = query.trim().toLowerCase();
    return _products
        .where(
          (product) =>
              term.isEmpty ||
              '${product.name} ${product.category}'.toLowerCase().contains(
                term,
              ),
        )
        .toList(growable: false);
  }

  @override
  Future<Product> getProduct(String productId) async {
    await _wait();
    try {
      return _products.firstWhere((product) => product.id == productId);
    } on StateError {
      throw const MarketplaceException('Product not found.');
    }
  }

  @override
  Future<List<EmiPlan>> getEmiPlans(
    String productId, [
    String? variantId,
  ]) async {
    await _wait();
    return _plans
        .where(
          (plan) =>
              plan.productId == productId &&
              (plan.variantId == null || plan.variantId == variantId),
        )
        .toList(growable: false);
  }
}

const _products = <Product>[
  Product(
    id: 'phone-pro',
    name: 'Nova Pro 5G',
    category: 'Smartphones',
    description: 'A fast, all-day 5G phone with a vivid OLED display and pro-grade camera.',
    price: Money(54999),
    originalPrice: Money(59999),
    emoji: '📱',
    accent: 0xFF7451D8,
    variants: [
      ProductVariant(
        id: 'nova-128',
        label: '128 GB · Graphite',
        price: Money(54999),
      ),
      ProductVariant(
        id: 'nova-256',
        label: '256 GB · Violet',
        price: Money(59999),
      ),
    ],
    specifications: {
      'Display': '6.5-inch OLED, 120 Hz',
      'Camera': '50 MP triple camera',
      'Battery': '5,000 mAh',
      'Warranty': '1 year',
    },
  ),
  Product(
    id: 'laptop-air',
    name: 'Feather Air 14',
    category: 'Laptops',
    description: 'A slim performance laptop designed for focused work and effortless travel.',
    price: Money(74990),
    originalPrice: Money(82990),
    emoji: '💻',
    accent: 0xFF2D7E9D,
    variants: [
      ProductVariant(
        id: 'air-8',
        label: '8 GB · 512 GB SSD',
        price: Money(74990),
      ),
      ProductVariant(
        id: 'air-16',
        label: '16 GB · 512 GB SSD',
        price: Money(82990),
      ),
    ],
    specifications: {
      'Display': '14-inch 2.5K',
      'Processor': '8-core performance chip',
      'Battery': 'Up to 16 hours',
      'Weight': '1.24 kg',
    },
  ),
  Product(
    id: 'headphones',
    name: 'QuietBeat Studio',
    category: 'Audio',
    description:
        'Immersive wireless headphones with adaptive noise cancellation.',
    price: Money(12999),
    originalPrice: Money(15999),
    emoji: '🎧',
    accent: 0xFFBC5B80,
    variants: [
      ProductVariant(
        id: 'quiet-black',
        label: 'Midnight Black',
        price: Money(12999),
      ),
      ProductVariant(id: 'quiet-sand', label: 'Warm Sand', price: Money(12999)),
    ],
    specifications: {
      'Playback': 'Up to 40 hours',
      'Audio': 'Spatial sound',
      'Charging': 'USB-C fast charge',
      'Warranty': '1 year',
    },
  ),
  Product(
    id: 'watch-fit',
    name: 'Pulse Watch S',
    category: 'Wearables',
    description: 'A lightweight wellness watch for workouts, sleep, and everyday movement.',
    price: Money(8999),
    originalPrice: null,
    emoji: '⌚',
    accent: 0xFF38866C,
    variants: [],
    specifications: {
      'Display': '1.8-inch AMOLED',
      'Battery': 'Up to 10 days',
      'Water resistance': '5 ATM',
      'Sensors': 'Heart rate, SpO₂',
    },
  ),
];

const _plans = <EmiPlan>[
  EmiPlan(
    id: 'nova-128-3',
    productId: 'phone-pro',
    variantId: 'nova-128',
    tenureMonths: 3,
    monthlyInstallment: Money(18333),
    totalPayable: Money(54999),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Flex',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'nova-128-6',
    productId: 'phone-pro',
    variantId: 'nova-128',
    tenureMonths: 6,
    monthlyInstallment: Money(9583),
    totalPayable: Money(57498),
    annualInterestRate: 9.9,
    processingFee: Money(299),
    providerLabel: '1Fi Flex',
  ),
  EmiPlan(
    id: 'nova-256-6',
    productId: 'phone-pro',
    variantId: 'nova-256',
    tenureMonths: 6,
    monthlyInstallment: Money(10000),
    totalPayable: Money(60000),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Flex',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'nova-256-12',
    productId: 'phone-pro',
    variantId: 'nova-256',
    tenureMonths: 12,
    monthlyInstallment: Money(5333),
    totalPayable: Money(63996),
    annualInterestRate: 12.5,
    processingFee: Money(499),
    providerLabel: '1Fi Flex',
  ),
  EmiPlan(
    id: 'air-8-6',
    productId: 'laptop-air',
    variantId: 'air-8',
    tenureMonths: 6,
    monthlyInstallment: Money(12499),
    totalPayable: Money(74994),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Work',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'air-8-12',
    productId: 'laptop-air',
    variantId: 'air-8',
    tenureMonths: 12,
    monthlyInstallment: Money(6665),
    totalPayable: Money(79980),
    annualInterestRate: 11.5,
    processingFee: Money(499),
    providerLabel: '1Fi Work',
  ),
  EmiPlan(
    id: 'air-16-12',
    productId: 'laptop-air',
    variantId: 'air-16',
    tenureMonths: 12,
    monthlyInstallment: Money(7375),
    totalPayable: Money(88500),
    annualInterestRate: 12.0,
    processingFee: Money(499),
    providerLabel: '1Fi Work',
  ),
  EmiPlan(
    id: 'quiet-3',
    productId: 'headphones',
    variantId: null,
    tenureMonths: 3,
    monthlyInstallment: Money(4333),
    totalPayable: Money(12999),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Flex',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'quiet-6',
    productId: 'headphones',
    variantId: null,
    tenureMonths: 6,
    monthlyInstallment: Money(2267),
    totalPayable: Money(13602),
    annualInterestRate: 10.0,
    processingFee: Money(199),
    providerLabel: '1Fi Flex',
  ),
  EmiPlan(
    id: 'watch-3',
    productId: 'watch-fit',
    variantId: null,
    tenureMonths: 3,
    monthlyInstallment: Money(3000),
    totalPayable: Money(9000),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Flex',
    isNoCost: true,
  ),
];
