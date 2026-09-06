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
  Product(
    id: 'qled-tv',
    name: 'VisionView QLED TV',
    category: 'Televisions',
    description: 'A cinematic 4K smart TV with vivid quantum-dot colour and room-filling sound.',
    price: Money(49990),
    originalPrice: Money(64990),
    emoji: '📺',
    accent: 0xFF4766B0,
    variants: [
      ProductVariant(id: 'tv-55', label: '55 inch · 4K', price: Money(49990)),
      ProductVariant(id: 'tv-65', label: '65 inch · 4K', price: Money(69990)),
    ],
    specifications: {
      'Display': '4K QLED, Dolby Vision',
      'Refresh rate': '120 Hz',
      'Audio': '40 W Dolby Atmos',
      'Warranty': '2 years',
    },
  ),
  Product(
    id: 'washing-machine',
    name: 'EcoWash Front Load',
    category: 'Washing Machines',
    description: 'A quiet, water-efficient front-load washer with steam care and smart cycles.',
    price: Money(32990),
    originalPrice: Money(39990),
    emoji: '🧺',
    accent: 0xFF2E8B9B,
    variants: [
      ProductVariant(id: 'wash-8', label: '8 kg · White', price: Money(32990)),
      ProductVariant(
        id: 'wash-10',
        label: '10 kg · Graphite',
        price: Money(41990),
      ),
    ],
    specifications: {
      'Capacity': '8 kg',
      'Motor': 'Inverter direct drive',
      'Efficiency': '5-star energy rating',
      'Warranty': '10 years on motor',
    },
  ),
  Product(
    id: 'refrigerator',
    name: 'FrostFresh Refrigerator',
    category: 'Refrigerators',
    description: 'A spacious frost-free refrigerator with convertible storage and rapid cooling.',
    price: Money(38990),
    originalPrice: Money(45990),
    emoji: '❄️',
    accent: 0xFF3F829B,
    variants: [
      ProductVariant(
        id: 'fridge-340',
        label: '340 L · Steel',
        price: Money(38990),
      ),
      ProductVariant(
        id: 'fridge-420',
        label: '420 L · Black',
        price: Money(51990),
      ),
    ],
    specifications: {
      'Type': 'Double door, frost free',
      'Storage': 'Convertible freezer',
      'Efficiency': '3-star energy rating',
      'Warranty': '10 years on compressor',
    },
  ),
  Product(
    id: 'air-conditioner',
    name: 'BreezeMax Inverter AC',
    category: 'Air Conditioners',
    description: 'Fast, efficient cooling with smart temperature control and low-noise operation.',
    price: Money(36990),
    originalPrice: Money(44990),
    emoji: '🌬️',
    accent: 0xFF4A7FC1,
    variants: [
      ProductVariant(
        id: 'ac-3',
        label: '1.5 ton · 3 star',
        price: Money(36990),
      ),
      ProductVariant(
        id: 'ac-5',
        label: '1.5 ton · 5 star',
        price: Money(42990),
      ),
    ],
    specifications: {
      'Cooling': '1.5 ton inverter',
      'Coverage': 'Up to 180 sq. ft.',
      'Filter': 'PM 2.5 air filter',
      'Warranty': '10 years on compressor',
    },
  ),
  Product(
    id: 'microwave',
    name: 'QuickChef Microwave',
    category: 'Kitchen Appliances',
    description: 'A versatile convection microwave for reheating, grilling, baking, and everyday meals.',
    price: Money(12990),
    originalPrice: Money(15990),
    emoji: '🍽️',
    accent: 0xFFB36A42,
    variants: [],
    specifications: {
      'Capacity': '28 litres',
      'Modes': 'Convection and grill',
      'Programs': '100 auto-cook menus',
      'Warranty': '1 year',
    },
  ),
  Product(
    id: 'robot-vacuum',
    name: 'CleanBot Smart Vacuum',
    category: 'Home Care',
    description: 'Automated vacuuming and mopping with room mapping and app-based scheduling.',
    price: Money(24990),
    originalPrice: Money(29990),
    emoji: '🧹',
    accent: 0xFF69755A,
    variants: [
      ProductVariant(
        id: 'bot-white',
        label: 'Pearl White',
        price: Money(24990),
      ),
      ProductVariant(
        id: 'bot-black',
        label: 'Matte Black',
        price: Money(25990),
      ),
    ],
    specifications: {
      'Suction': '4,000 Pa',
      'Navigation': 'LiDAR room mapping',
      'Runtime': 'Up to 180 minutes',
      'Functions': 'Vacuum and mop',
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
  EmiPlan(
    id: 'tv-55-6',
    productId: 'qled-tv',
    variantId: 'tv-55',
    tenureMonths: 6,
    monthlyInstallment: Money(8332),
    totalPayable: Money(49992),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Home',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'tv-55-12',
    productId: 'qled-tv',
    variantId: 'tv-55',
    tenureMonths: 12,
    monthlyInstallment: Money(4416),
    totalPayable: Money(52992),
    annualInterestRate: 10.5,
    processingFee: Money(399),
    providerLabel: '1Fi Home',
  ),
  EmiPlan(
    id: 'tv-65-12',
    productId: 'qled-tv',
    variantId: 'tv-65',
    tenureMonths: 12,
    monthlyInstallment: Money(5833),
    totalPayable: Money(69996),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Home',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'wash-8-6',
    productId: 'washing-machine',
    variantId: 'wash-8',
    tenureMonths: 6,
    monthlyInstallment: Money(5499),
    totalPayable: Money(32994),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Home',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'wash-10-9',
    productId: 'washing-machine',
    variantId: 'wash-10',
    tenureMonths: 9,
    monthlyInstallment: Money(4899),
    totalPayable: Money(44091),
    annualInterestRate: 9.5,
    processingFee: Money(299),
    providerLabel: '1Fi Home',
  ),
  EmiPlan(
    id: 'fridge-340-6',
    productId: 'refrigerator',
    variantId: 'fridge-340',
    tenureMonths: 6,
    monthlyInstallment: Money(6499),
    totalPayable: Money(38994),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Home',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'fridge-420-12',
    productId: 'refrigerator',
    variantId: 'fridge-420',
    tenureMonths: 12,
    monthlyInstallment: Money(4583),
    totalPayable: Money(54996),
    annualInterestRate: 10.0,
    processingFee: Money(399),
    providerLabel: '1Fi Home',
  ),
  EmiPlan(
    id: 'ac-3-6',
    productId: 'air-conditioner',
    variantId: 'ac-3',
    tenureMonths: 6,
    monthlyInstallment: Money(6165),
    totalPayable: Money(36990),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Home',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'ac-5-12',
    productId: 'air-conditioner',
    variantId: 'ac-5',
    tenureMonths: 12,
    monthlyInstallment: Money(3783),
    totalPayable: Money(45396),
    annualInterestRate: 10.5,
    processingFee: Money(399),
    providerLabel: '1Fi Home',
  ),
  EmiPlan(
    id: 'microwave-3',
    productId: 'microwave',
    variantId: null,
    tenureMonths: 3,
    monthlyInstallment: Money(4330),
    totalPayable: Money(12990),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Home',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'bot-white-6',
    productId: 'robot-vacuum',
    variantId: 'bot-white',
    tenureMonths: 6,
    monthlyInstallment: Money(4165),
    totalPayable: Money(24990),
    annualInterestRate: 0,
    processingFee: Money(0),
    providerLabel: '1Fi Home',
    isNoCost: true,
  ),
  EmiPlan(
    id: 'bot-black-6',
    productId: 'robot-vacuum',
    variantId: 'bot-black',
    tenureMonths: 6,
    monthlyInstallment: Money(4549),
    totalPayable: Money(27294),
    annualInterestRate: 9.5,
    processingFee: Money(199),
    providerLabel: '1Fi Home',
  ),
];
