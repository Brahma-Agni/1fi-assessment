import 'package:flutter/material.dart';

import 'app_state.dart';
import 'marketplace_service.dart';
import 'models.dart';

const _primary = Color(0xFF6438D7);
const _ink = Color(0xFF19151F);
const _muted = Color(0xFF716B78);
const _background = Color(0xFFF7F6FA);

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.service,
    required this.appState,
    required this.openShop,
  });

  final MarketplaceService service;
  final MarketplaceAppState appState;
  final VoidCallback openShop;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<Product>> products = widget.service.getProducts();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          _TopHeader(
            eyebrow: 'GOOD EVENING',
            title: 'Welcome to 1Fi',
            trailing: CartButton(
              appState: widget.appState,
              onPressed: () => _openCart(context, widget.appState),
            ),
          ),
          const SizedBox(height: 24),
          _CreditCard(appState: widget.appState),
          const SizedBox(height: 26),
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.storefront_rounded,
                  label: 'Shop',
                  onTap: widget.openShop,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.shopping_cart_rounded,
                  label: 'Cart',
                  badge: widget.appState.cartCount,
                  onTap: () => _openCart(context, widget.appState),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  badge: widget.appState.orders.length,
                  onTap: () => _openOrders(context, widget.appState),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Text(
                'Popular right now',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.openShop,
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 186,
            child: FutureBuilder<List<Product>>(
              future: products,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _FeaturedProduct(
                    product: snapshot.data![index],
                    onTap: widget.openShop,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Text(
                'Recent purchases',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (widget.appState.orders.isNotEmpty)
                TextButton(
                  onPressed: () => _openOrders(context, widget.appState),
                  child: const Text('See orders'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.appState.orders.isEmpty)
            _EmptyCard(
              icon: Icons.shopping_bag_outlined,
              title: 'Nothing here yet',
              message: 'Your completed purchases will appear here.',
              action: 'Start shopping',
              onTap: widget.openShop,
            )
          else
            OrderCard(order: widget.appState.orders.first),
        ],
      ),
    ),
  );
}

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({
    super.key,
    required this.appState,
    required this.openShop,
  });
  final MarketplaceAppState appState;
  final VoidCallback openShop;

  @override
  Widget build(BuildContext context) {
    final monthly = appState.emiOrders.fold(
      0,
      (sum, order) => sum + (order.emiPlan?.monthlyInstallment.amount ?? 0),
    );
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            const _TopHeader(eyebrow: 'YOUR FINANCES', title: 'Money'),
            const SizedBox(height: 24),
            _CreditCard(appState: appState, compact: true),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Active plans',
                    value: '${appState.emiOrders.length}',
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Monthly EMI',
                    value: formatCurrency(Money(monthly)),
                    icon: Icons.payments_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Your EMI plans',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (appState.emiOrders.isEmpty)
              _EmptyCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No active EMI plans',
                message: 'Choose a transparent monthly plan from any eligible product.',
                action: 'Explore products',
                onTap: openShop,
              )
            else
              ...appState.emiOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EmiAccountCard(order: order),
                ),
              ),
            const SizedBox(height: 22),
            Text('Money tools', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const _InfoTile(
              icon: Icons.calculate_outlined,
              title: 'EMI calculator',
              subtitle: 'Compare monthly costs before you buy',
            ),
            const SizedBox(height: 10),
            const _InfoTile(
              icon: Icons.shield_outlined,
              title: 'Payment protection',
              subtitle: 'Understand your plan and repayment safety',
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.appState});
  final MarketplaceAppState appState;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFECE5FC),
                  child: Text(
                    'GS',
                    style: TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guest Shopper',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text('Demo account', style: TextStyle(color: _muted)),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: Color(0xFF16794A)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  value: '${appState.orders.length}',
                  label: 'Orders',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  value: '${appState.cartCount}',
                  label: 'In cart',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  value: '${appState.emiOrders.length}',
                  label: 'EMIs',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Your activity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.receipt_long_rounded,
            title: 'Orders & purchases',
            subtitle: 'Track everything you have bought',
            onTap: () => _openOrders(context, appState),
          ),
          _MenuTile(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart',
            subtitle:
                '${appState.cartCount} item${appState.cartCount == 1 ? '' : 's'} waiting',
            onTap: () => _openCart(context, appState),
          ),
          const SizedBox(height: 22),
          Text('Account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Purchase and repayment reminders',
            onTap: () => _comingSoon(context),
          ),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
            subtitle: 'Answers and contact options',
            onTap: () => _comingSoon(context),
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            title: 'About 1Fi Marketplace',
            subtitle: 'Version 1.0.0',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: '1Fi Marketplace',
              applicationVersion: '1.0.0',
            ),
          ),
        ],
      ),
    ),
  );
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.appState});
  final MarketplaceAppState appState;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: appState,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text('Your cart (${appState.cartCount})'),
        backgroundColor: _background,
      ),
      body: appState.cart.isEmpty
          ? _EmptyCard(
              icon: Icons.remove_shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Add a product from the Marketplace to see it here.',
              action: 'Back to shop',
              onTap: () => Navigator.of(context).pop(),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 170),
              itemCount: appState.cart.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _CartLine(item: appState.cart[index], appState: appState),
            ),
      bottomNavigationBar: appState.cart.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE8E3EC))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PriceRow(
                      label: 'Subtotal',
                      value: formatCurrency(appState.cartTotal),
                      strong: true,
                    ),
                    const SizedBox(height: 4),
                    const _PriceRow(label: 'Delivery', value: 'Free'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: () {
                          final orders = appState.purchaseCart();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => PurchaseSuccessScreen(
                                appState: appState,
                                orders: orders,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Place order · ${formatCurrency(appState.cartTotal)}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Demo checkout — no real payment is processed',
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
    ),
  );
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, required this.appState});
  final MarketplaceAppState appState;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: appState,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Orders & purchases'),
        backgroundColor: _background,
      ),
      body: appState.orders.isEmpty
          ? _EmptyCard(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Your EMI and full-payment purchases will appear here.',
              action: 'Start shopping',
              onTap: () => Navigator.of(context).pop(),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              itemCount: appState.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  OrderCard(order: appState.orders[index], detailed: true),
            ),
    ),
  );
}

class PurchaseSuccessScreen extends StatelessWidget {
  const PurchaseSuccessScreen({
    super.key,
    required this.appState,
    required this.orders,
  });
  final MarketplaceAppState appState;
  final List<PurchaseOrder> orders;

  @override
  Widget build(BuildContext context) {
    final total = orders.fold(0, (sum, order) => sum + order.total.amount);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F6ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: Color(0xFF137248),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Purchase recorded',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${orders.length} item${orders.length == 1 ? '' : 's'} · ${formatCurrency(Money(total))}',
                style: const TextStyle(color: _muted, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                orders.map((order) => order.id).join('  •  '),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              const _InfoTile(
                icon: Icons.local_shipping_outlined,
                title: 'Order confirmed',
                subtitle: 'This demo order is ready for fulfillment',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => OrdersScreen(appState: appState),
                    ),
                  ),
                  child: const Text('View orders'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Continue shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartButton extends StatelessWidget {
  const CartButton({
    super.key,
    required this.appState,
    required this.onPressed,
  });
  final MarketplaceAppState appState;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: appState.cartCount > 0,
    label: Text('${appState.cartCount}'),
    child: IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: 'Open cart',
      icon: const Icon(Icons.shopping_cart_outlined),
    ),
  );
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.detailed = false});
  final PurchaseOrder order;
  final bool detailed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFF0EDF3)),
    ),
    child: Row(
      children: [
        _ProductIcon(product: order.product, size: 66),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.product.name,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const _StatusPill(),
                ],
              ),
              if (order.variant != null)
                Text(
                  order.variant!.label,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              const SizedBox(height: 7),
              Text(
                '${order.paymentLabel} · ${formatCurrency(order.total)}',
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (detailed) ...[
                const SizedBox(height: 5),
                Text(
                  '${order.id} · ${_date(order.createdAt)} · Qty ${order.quantity}',
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.eyebrow, required this.title, this.trailing});
  final String eyebrow;
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          '1Fi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.appState, this.compact = false});
  final MarketplaceAppState appState;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final committed = appState.emiOrders.fold(
      0,
      (sum, order) => sum + (order.emiPlan?.totalPayable.amount ?? 0),
    );
    final available = 120000 - committed.clamp(0, 120000);
    return Container(
      height: compact ? 176 : 194,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F1AA8), Color(0xFF8052E6)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x306438D7),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x2AFFFFFF),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'PRE-APPROVED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Available spending limit',
            style: TextStyle(color: Color(0xFFDCCFFF)),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(Money(available)),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: available / 120000,
              minHeight: 6,
              backgroundColor: const Color(0x33FFFFFF),
              color: const Color(0xFFFFD36B),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Total limit ₹1,20,000',
            style: TextStyle(color: Color(0xFFDCCFFF), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FeaturedProduct extends StatelessWidget {
  const _FeaturedProduct({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 154,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _ProductIcon(product: product, size: 90)),
              const Spacer(),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                formatCurrency(product.price),
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ProductIcon extends StatelessWidget {
  const _ProductIcon({required this.product, required this.size});
  final Product product;
  final double size;
  @override
  Widget build(BuildContext context) {
    final icon = switch (product.category) {
      'Smartphones' => Icons.smartphone_rounded,
      'Laptops' => Icons.laptop_mac_rounded,
      'Audio' => Icons.headphones_rounded,
      'Wearables' => Icons.watch_rounded,
      _ => Icons.shopping_bag_rounded,
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(product.accent).withValues(alpha: .11),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, size: size * .46, color: Color(product.accent)),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Badge(
              isLabelVisible: badge > 0,
              label: Text('$badge'),
              child: Icon(icon, color: _primary, size: 27),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.item, required this.appState});
  final CartItem item;
  final MarketplaceAppState appState;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
    ),
    child: Row(
      children: [
        _ProductIcon(product: item.product, size: 78),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (item.variant != null)
                Text(
                  item.variant!.label,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              const SizedBox(height: 8),
              Text(
                formatCurrency(item.total),
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              onPressed: () => appState.updateQuantity(item.key, 0),
              tooltip: 'Remove item',
              icon: const Icon(Icons.delete_outline_rounded, color: _muted),
            ),
            Container(
              decoration: BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onTap: () =>
                        appState.updateQuantity(item.key, item.quantity - 1),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    onTap: () =>
                        appState.updateQuantity(item.key, item.quantity + 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
    padding: EdgeInsets.zero,
    iconSize: 17,
    icon: Icon(icon),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primary),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    ),
  );
}

class _EmiAccountCard extends StatelessWidget {
  const _EmiAccountCard({required this.order});
  final PurchaseOrder order;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Row(
          children: [
            _ProductIcon(product: order.product, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.product.name,
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    order.paymentLabel,
                    style: const TextStyle(color: _muted),
                  ),
                ],
              ),
            ),
            const _StatusPill(),
          ],
        ),
        const Divider(height: 26),
        Row(
          children: [
            const Text('Monthly payment', style: TextStyle(color: _muted)),
            const Spacer(),
            Text(
              formatCurrency(order.emiPlan!.monthlyInstallment),
              style: const TextStyle(
                color: _primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFE5F6ED),
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Text(
      'Confirmed',
      style: TextStyle(
        color: Color(0xFF137248),
        fontSize: 9,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _primary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
      ],
    ),
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBFC),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: _primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBFC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _primary),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _primary, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted),
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    ),
  );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.strong = false,
  });
  final String label;
  final String value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          color: strong ? _ink : _muted,
          fontWeight: strong ? FontWeight.w800 : FontWeight.w400,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: TextStyle(
          color: _ink,
          fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
          fontSize: strong ? 18 : 14,
        ),
      ),
    ],
  );
}

void _openCart(BuildContext context, MarketplaceAppState state) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => CartScreen(appState: state)));
void _openOrders(BuildContext context, MarketplaceAppState state) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OrdersScreen(appState: state)),
    );
void _comingSoon(BuildContext context) => ScaffoldMessenger.of(context)
    .showSnackBar(
      const SnackBar(
        content: Text('This account option is ready for backend integration.'),
      ),
    );
String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
