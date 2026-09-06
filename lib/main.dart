import 'dart:async';

import 'package:flutter/material.dart';

import 'marketplace_service.dart';
import 'models.dart';

const primary = Color(0xFF6C35D5);
const background = Color(0xFFF8F6FB);
const ink = Color(0xFF211D29);
const muted = Color(0xFF736D7C);

void main() => runApp(const OneFiApp());

class OneFiApp extends StatelessWidget {
  const OneFiApp({super.key, this.service});
  final MarketplaceService? service;

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
    home: ShopScreen(service: service ?? MockMarketplaceService()),
  );
}

enum ShopSection { topBrands, nearbyStores, marketplace }

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.service});
  final MarketplaceService service;
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ShopSection section = ShopSection.marketplace;
  String query = '';
  Timer? debounce;

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  sliver: SliverList.list(
                    children: [
                      const _ShopHeader(),
                      const SizedBox(height: 18),
                      TextField(
                        onChanged: (value) {
                          debounce?.cancel();
                          debounce = Timer(
                            const Duration(milliseconds: 280),
                            () {
                              if (mounted) setState(() => query = value);
                            },
                          );
                        },
                        enabled: section == ShopSection.marketplace,
                        decoration: const InputDecoration(
                          hintText: 'Search products or categories',
                          prefixIcon: Icon(Icons.search_rounded),
                          suffixIcon: Icon(Icons.tune_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionPicker(
                        selected: section,
                        onChanged: (value) => setState(() => section = value),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                if (section == ShopSection.marketplace)
                  MarketplaceCatalog(service: widget.service, query: query)
                else
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _QuietSection(section: section),
                  ),
              ],
            ),
          ),
          const _BottomBar(),
        ],
      ),
    ),
  );
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(14),
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
          const Spacer(),
          IconButton.filledTonal(
            onPressed: () {},
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Text('Shop', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primary, Color(0xFF9A68EE)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade today.\nPay your way.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Flexible plans, clear costs, zero surprises.',
                    style: TextStyle(color: Color(0xFFEDE3FF)),
                  ),
                ],
              ),
            ),
            Text(
              '✨',
              style: TextStyle(fontSize: 46),
              semanticsLabel: 'Sparkles',
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
    required this.query,
  });
  final MarketplaceService service;
  final String query;
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
        return const SliverFillRemaining(
          child: _MessageState(
            icon: Icons.search_off_rounded,
            title: 'No products found',
            message: 'Try a different product or category.',
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
                childAspectRatio: columns == 1 ? 1.62 : .72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(
                  product: products[index],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductDetailsScreen(
                        service: widget.service,
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
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ProductArt(product: product, size: 116),
              const SizedBox(width: 16),
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
                      const SizedBox(height: 6),
                      const Text(
                        'Easy EMI available',
                        style: TextStyle(
                          color: Color(0xFF16794A),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: muted),
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
  Widget build(BuildContext context) => Semantics(
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
      child: Text(product.emoji, style: TextStyle(fontSize: size * .43)),
    ),
  );
}

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.service,
    required this.productId,
  });
  final MarketplaceService service;
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
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: planId == null ? null : () => _proceed(product),
                child: Text(
                  planId == null ? 'Select an EMI plan' : 'Proceed with plan',
                ),
              ),
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
        builder: (_) =>
            ConfirmationScreen(product: product, variant: variant, plan: plan),
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
    required this.product,
    required this.variant,
    required this.plan,
  });
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
              'Plan selected',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your selection is ready for the next step. No payment has been made.',
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
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to Marketplace'),
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
  const _BottomBar();
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E3EC))),
      ),
      child: NavigationBar(
        selectedIndex: 2,
        destinations: [
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
