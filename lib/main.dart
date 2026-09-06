import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_pages.dart';
import 'marketplace_service.dart';
import 'models.dart';

const primary = Color(0xFF6438D7);
const background = Color(0xFFF7F6FA);
const ink = Color(0xFF19151F);
const muted = Color(0xFF716B78);

void main() => runApp(const OneFiApp());

class OneFiApp extends StatefulWidget {
  const OneFiApp({super.key, this.service, this.appState});
  final MarketplaceService? service;
  final MarketplaceAppState? appState;

  @override
  State<OneFiApp> createState() => _OneFiAppState();
}

class _OneFiAppState extends State<OneFiApp> {
  late final MarketplaceService service;
  late final MarketplaceAppState appState;

  @override
  void initState() {
    super.initState();
    service = widget.service ?? MockMarketplaceService();
    appState = widget.appState ?? MarketplaceAppState();
  }

  @override
  void dispose() {
    if (widget.appState == null) appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '1Fi Marketplace',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
        bodyLarge: TextStyle(color: ink, height: 1.4),
        bodyMedium: TextStyle(color: muted, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE8E3EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE8E3EC)),
        ),
      ),
    ),
    home: AnimatedBuilder(
      animation: appState,
      builder: (context, _) => AppShell(service: service, appState: appState),
    ),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.service, required this.appState});

  final MarketplaceService service;
  final MarketplaceAppState appState;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: selectedIndex,
      children: [
        HomeScreen(
          service: widget.service,
          appState: widget.appState,
          openShop: () => setState(() => selectedIndex = 2),
        ),
        MoneyScreen(
          appState: widget.appState,
          openShop: () => setState(() => selectedIndex = 2),
        ),
        ShopScreen(service: widget.service, appState: widget.appState),
        ProfileScreen(appState: widget.appState),
      ],
    ),
    bottomNavigationBar: _BottomBar(
      selectedIndex: selectedIndex,
      onChanged: (value) => setState(() => selectedIndex = value),
    ),
  );
}

enum ShopSection { topBrands, nearbyStores, marketplace }

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.service, required this.appState});
  final MarketplaceService service;
  final MarketplaceAppState appState;
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ShopSection section = ShopSection.marketplace;
  String query = '';
  Timer? debounce;
  final searchController = TextEditingController();

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void clearSearch() {
    debounce?.cancel();
    searchController.clear();
    setState(() => query = '');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            sliver: SliverList.list(
              children: [
                _ShopHeader(appState: widget.appState),
                const SizedBox(height: 18),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    debounce?.cancel();
                    debounce = Timer(const Duration(milliseconds: 280), () {
                      if (mounted) setState(() => query = value);
                    });
                  },
                  enabled: section == ShopSection.marketplace,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search products or categories',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            onPressed: clearSearch,
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded),
                          )
                        : const Icon(Icons.tune_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                _SectionPicker(
                  selected: section,
                  onChanged: (value) => setState(() => section = value),
                ),
                const SizedBox(height: 22),
                if (section == ShopSection.marketplace)
                  Row(
                    children: [
                      Text(
                        query.isEmpty
                            ? 'Recommended for you'
                            : 'Search results',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      const Text(
                        'Flexible EMI',
                        style: TextStyle(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                if (section == ShopSection.marketplace)
                  const SizedBox(height: 14),
              ],
            ),
          ),
          if (section == ShopSection.marketplace)
            MarketplaceCatalog(
              service: widget.service,
              appState: widget.appState,
              query: query,
              onClearSearch: clearSearch,
            )
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: _QuietSection(section: section),
            ),
        ],
      ),
    ),
  );
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.appState});
  final MarketplaceAppState appState;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x346438D7),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '1Fi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1Fi Marketplace',
                style: TextStyle(fontWeight: FontWeight.w800, color: ink),
              ),
              Text(
                'Smart purchases, simpler plans',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ],
          ),
          const Spacer(),
          CartButton(
            appState: appState,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CartScreen(appState: appState),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text('Shop smarter', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 4),
      const Text(
        'Find the right product and a payment plan that fits.',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 16),
      Container(
        height: 142,
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4D22BC), Color(0xFF8C5DE8)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A6438D7),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x2EFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      child: Text(
                        '1Fi EXCLUSIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Bring it home today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Transparent plans from ₹3,000/month',
                    style: TextStyle(color: Color(0xFFEDE3FF)),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 92,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: Color(0x1FFFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Transform.rotate(
                    angle: -.12,
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      size: 58,
                      color: Colors.white,
                      semanticLabel: 'Shopping bag',
                    ),
                  ),
                  const Positioned(
                    right: 5,
                    top: 13,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFD36B),
                      size: 23,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _SectionPicker extends StatelessWidget {
  const _SectionPicker({required this.selected, required this.onChanged});
  final ShopSection selected;
  final ValueChanged<ShopSection> onChanged;
  @override
  Widget build(BuildContext context) {
    const labels = {
      ShopSection.topBrands: 'Top Brands',
      ShopSection.nearbyStores: 'Nearby',
      ShopSection.marketplace: 'Marketplace',
    };
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAF4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: ShopSection.values.map((item) {
          final active = item == selected;
          return Expanded(
            child: Semantics(
              selected: active,
              button: true,
              child: InkWell(
                onTap: () => onChanged(item),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: active
                        ? const [
                            BoxShadow(color: Color(0x176C35D5), blurRadius: 10),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[item]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? primary : muted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MarketplaceCatalog extends StatefulWidget {
  const MarketplaceCatalog({
    super.key,
    required this.service,
    required this.appState,
    required this.query,
    required this.onClearSearch,
  });
  final MarketplaceService service;
  final MarketplaceAppState appState;
  final String query;
  final VoidCallback onClearSearch;
  @override
  State<MarketplaceCatalog> createState() => _MarketplaceCatalogState();
}

class _MarketplaceCatalogState extends State<MarketplaceCatalog> {
  late Future<List<Product>> request;
  @override
  void initState() {
    super.initState();
    request = widget.service.getProducts(widget.query);
  }

  @override
  void didUpdateWidget(covariant MarketplaceCatalog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      request = widget.service.getProducts(widget.query);
    }
  }

  void retry() =>
      setState(() => request = widget.service.getProducts(widget.query));

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Product>>(
    future: request,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (snapshot.hasError) {
        return SliverFillRemaining(
          child: _MessageState(
            icon: Icons.cloud_off_rounded,
            title: 'Couldn’t load products',
            message: 'Check your connection and try again.',
            action: 'Retry',
            onPressed: retry,
          ),
        );
      }
      final products = snapshot.data ?? const [];
      if (products.isEmpty) {
        return SliverFillRemaining(
          child: _MessageState(
            icon: Icons.search_off_rounded,
            title: 'No products found',
            message: 'Try a different product or category.',
            action: 'Clear search',
            onPressed: widget.onClearSearch,
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.crossAxisExtent < 540 ? 1 : 2;
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: columns == 1 ? 3.08 : 1.18,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(
                  product: products[index],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductDetailsScreen(
                        service: widget.service,
                        appState: widget.appState,
                        productId: products[index].id,
                      ),
                    ),
                  ),
                ),
                childCount: products.length,
              ),
            );
          },
        ),
      );
    },
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${product.name}, ${formatCurrency(product.price)}',
    child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFF0EDF3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ProductArt(product: product, size: 110),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(product.price),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: ink,
                      ),
                    ),
                    if (product.emiEligible) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F6EF),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'EMI available',
                          style: TextStyle(
                            color: Color(0xFF137248),
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2EDFC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ProductArt extends StatelessWidget {
  const ProductArt({super.key, required this.product, required this.size});
  final Product product;
  final double size;
  @override
  Widget build(BuildContext context) {
    final icon = switch (product.category) {
      'Smartphones' => Icons.smartphone_rounded,
      'Laptops' => Icons.laptop_mac_rounded,
      'Audio' => Icons.headphones_rounded,
      'Wearables' => Icons.watch_rounded,
      'Televisions' => Icons.tv_rounded,
      'Washing Machines' => Icons.local_laundry_service_rounded,
      'Refrigerators' => Icons.kitchen_rounded,
      'Air Conditioners' => Icons.ac_unit_rounded,
      'Kitchen Appliances' => Icons.microwave_rounded,
      'Home Care' => Icons.cleaning_services_rounded,
      _ => Icons.shopping_bag_rounded,
    };
    return Semantics(
      image: true,
      label: '${product.name} illustration',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(product.accent).withValues(alpha: .18),
              Color(product.accent).withValues(alpha: .06),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * .12,
              right: size * .12,
              child: Container(
                width: size * .18,
                height: size * .18,
                decoration: BoxDecoration(
                  color: Color(product.accent).withValues(alpha: .16),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Icon(icon, size: size * .48, color: Color(product.accent)),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.service,
    required this.appState,
    required this.productId,
  });
  final MarketplaceService service;
  final MarketplaceAppState appState;
  final String productId;
  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<Product> productRequest;
  Future<List<EmiPlan>>? planRequest;
  String? variantId;
  String? planId;
  @override
  void initState() {
    super.initState();
    productRequest = widget.service.getProduct(widget.productId);
  }

  void loadPlans(Product product) {
    variantId ??= product.variants
        .where((item) => item.available)
        .firstOrNull
        ?.id;
    planRequest ??= widget.service.getEmiPlans(product.id, variantId);
  }

  void chooseVariant(String id) => setState(() {
    variantId = id;
    planId = null;
    planRequest = widget.service.getEmiPlans(widget.productId, id);
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Product details'),
      backgroundColor: background,
    ),
    body: FutureBuilder<Product>(
      future: productRequest,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _MessageState(
            icon: Icons.inventory_2_outlined,
            title: 'Product unavailable',
            message: 'We couldn’t open this product.',
            action: 'Retry',
            onPressed: () => setState(
              () =>
                  productRequest = widget.service.getProduct(widget.productId),
            ),
          );
        }
        loadPlans(snapshot.data!);
        return _details(snapshot.data!);
      },
    ),
  );

  Widget _details(Product product) {
    final variant = product.variants
        .where((item) => item.id == variantId)
        .firstOrNull;
    final price = variant?.price ?? product.price;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              Center(child: ProductArt(product: product, size: 250)),
              const SizedBox(height: 22),
              Text(
                product.category.toUpperCase(),
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    formatCurrency(price),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: ink,
                    ),
                  ),
                  if (product.originalPrice case final original?) ...[
                    const SizedBox(width: 9),
                    Text(
                      formatCurrency(original),
                      style: const TextStyle(
                        color: muted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              if (product.variants.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  'Choose a variant',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: product.variants
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item.label),
                          selected: item.id == variantId,
                          onSelected: item.available
                              ? (_) => chooseVariant(item.id)
                              : null,
                          selectedColor: const Color(0xFFEDE5FF),
                          side: BorderSide(
                            color: item.id == variantId
                                ? primary
                                : const Color(0xFFE1DCE6),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 28),
              Text(
                'About this product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              ...product.specifications.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(color: muted),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 38),
              Text(
                'Choose your EMI plan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'One clear monthly payment. Select one to continue.',
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<EmiPlan>>(
                future: planRequest,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return _MessageState(
                      compact: true,
                      icon: Icons.error_outline_rounded,
                      title: 'Plans are unavailable',
                      message: 'Your product details are safe. Try loading plans again.',
                      action: 'Retry',
                      onPressed: () => setState(
                        () => planRequest = widget.service.getEmiPlans(
                          product.id,
                          variantId,
                        ),
                      ),
                    );
                  }
                  final plans = snapshot.data ?? const [];
                  if (plans.isEmpty) {
                    return const _MessageState(
                      compact: true,
                      icon: Icons.info_outline_rounded,
                      title: 'No EMI plans available',
                      message: 'This selection is not currently eligible.',
                    );
                  }
                  return Column(
                    children: plans
                        .map(
                          (plan) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: EmiPlanCard(
                              plan: plan,
                              selected: plan.id == planId,
                              onTap: () => setState(() => planId = plan.id),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE8E3EC))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final variant = product.variants
                            .where((item) => item.id == variantId)
                            .firstOrNull;
                        widget.appState.addToCart(product, variant);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to your cart')),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Add to cart'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: planId == null
                          ? null
                          : () => _proceed(product),
                      child: Text(planId == null ? 'Select EMI' : 'Continue'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _proceed(Product product) async {
    final plans = await planRequest;
    if (!mounted) return;
    final plan = plans?.where((item) => item.id == planId).firstOrNull;
    if (plan == null) return;
    final variant = product.variants
        .where((item) => item.id == variantId)
        .firstOrNull;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConfirmationScreen(
          appState: widget.appState,
          product: product,
          variant: variant,
          plan: plan,
        ),
      ),
    );
  }
}

class EmiPlanCard extends StatelessWidget {
  const EmiPlanCard({
    super.key,
    required this.plan,
    required this.selected,
    required this.onTap,
  });
  final EmiPlan plan;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label:
        '${plan.tenureMonths} months, ${formatCurrency(plan.monthlyInstallment)} monthly${selected ? ', selected' : ''}',
    child: Material(
      color: selected ? const Color(0xFFF3EEFF) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? primary : const Color(0xFFE5DFE9),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? primary : Colors.transparent,
                      border: Border.all(color: selected ? primary : muted),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${plan.tenureMonths} months',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '${formatCurrency(plan.monthlyInstallment)}/mo',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.isNoCost
                          ? 'Zero-cost EMI'
                          : '${plan.annualInterestRate}% p.a.',
                      style: TextStyle(
                        color: plan.isNoCost ? const Color(0xFF16794A) : muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Total ${formatCurrency(plan.totalPayable)}',
                    style: const TextStyle(color: muted),
                  ),
                ],
              ),
              if (plan.processingFee.amount > 0) ...[
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '+ ${formatCurrency(plan.processingFee)} processing fee',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({
    super.key,
    required this.appState,
    required this.product,
    required this.variant,
    required this.plan,
  });
  final MarketplaceAppState appState;
  final Product product;
  final ProductVariant? variant;
  final EmiPlan plan;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: background),
    body: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F5ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 46,
                color: Color(0xFF16794A),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Review your purchase',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Confirm the product and repayment plan below. This demo records the purchase without processing a real payment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  _SummaryRow('Product', product.name),
                  if (variant != null) _SummaryRow('Variant', variant!.label),
                  _SummaryRow('Plan', '${plan.tenureMonths} months'),
                  _SummaryRow(
                    'Monthly',
                    formatCurrency(plan.monthlyInstallment),
                  ),
                  _SummaryRow(
                    'Total payable',
                    formatCurrency(plan.totalPayable),
                    strong: true,
                  ),
                  _SummaryRow(
                    'Processing fee',
                    plan.processingFee.amount == 0
                        ? 'None'
                        : formatCurrency(plan.processingFee),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () {
                  final order = appState.purchaseWithEmi(
                    product,
                    variant,
                    plan,
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => PurchaseSuccessScreen(
                        appState: appState,
                        orders: [order],
                      ),
                    ),
                  );
                },
                child: const Text('Confirm purchase'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.strong = false});
  final String label;
  final String value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: muted)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: ink,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _QuietSection extends StatelessWidget {
  const _QuietSection({required this.section});
  final ShopSection section;
  @override
  Widget build(BuildContext context) => _MessageState(
    icon: section == ShopSection.nearbyStores
        ? Icons.storefront_outlined
        : Icons.diamond_outlined,
    title: section == ShopSection.nearbyStores ? 'Nearby Stores' : 'Top Brands',
    message: 'This space is intentionally left blank for this focused marketplace demo.',
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onPressed,
    this.compact = false,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onPressed;
  final bool compact;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(compact ? 12 : 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 34 : 48, color: primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted),
          ),
          if (action != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onPressed, child: Text(action!)),
          ],
        ],
      ),
    ),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.selectedIndex, required this.onChanged});
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E3EC))),
      ),
      child: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFECE5FC),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selectedIndex,
        onDestinationSelected: onChanged,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Money',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_rounded),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    ),
  );
}
