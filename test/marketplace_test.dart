import 'package:onefi_marketplace/main.dart';
import 'package:onefi_marketplace/app_state.dart';
import 'package:onefi_marketplace/marketplace_service.dart';
import 'package:onefi_marketplace/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats Indian currency grouping', () {
    expect(formatCurrency(const Money(54999)), '₹54,999');
    expect(formatCurrency(const Money(1250000)), '₹12,50,000');
  });

  test('service filters by product name and category', () async {
    final service = MockMarketplaceService(delay: Duration.zero);
    expect((await service.getProducts('nova')).single.id, 'phone-pro');
    expect((await service.getProducts('audio')).single.id, 'headphones');
    expect(await service.getProducts('missing'), isEmpty);
  });

  test('service returns variant-specific plans', () async {
    final service = MockMarketplaceService(delay: Duration.zero);
    final plans = await service.getEmiPlans('phone-pro', 'nova-256');
    expect(plans, isNotEmpty);
    expect(plans.every((plan) => plan.variantId == 'nova-256'), isTrue);
  });

  test('cart purchase creates orders and clears the cart', () async {
    final service = MockMarketplaceService(delay: Duration.zero);
    final state = MarketplaceAppState();
    final product = (await service.getProducts()).first;
    state.addToCart(product, product.variants.first);
    state.addToCart(product, product.variants.first);
    expect(state.cartCount, 2);
    final orders = state.purchaseCart();
    expect(orders.single.quantity, 2);
    expect(state.cart, isEmpty);
    expect(state.orders, hasLength(1));
  });

  test('EMI purchase appears in finance activity', () async {
    final service = MockMarketplaceService(delay: Duration.zero);
    final state = MarketplaceAppState();
    final product = (await service.getProducts()).first;
    final variant = product.variants.first;
    final plan = (await service.getEmiPlans(product.id, variant.id)).first;
    state.purchaseWithEmi(product, variant, plan);
    expect(state.emiOrders, hasLength(1));
    expect(state.emiOrders.single.emiPlan, plan);
  });

  testWidgets('bottom navigation opens Home, Money, and Profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      OneFiApp(service: MockMarketplaceService(delay: Duration.zero)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome to 1Fi'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pump();
    expect(find.text('Your EMI plans'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pump();
    expect(find.text('Orders & purchases'), findsOneWidget);
  });

  testWidgets('shop exposes all sections and loads catalog', (tester) async {
    await tester.pumpWidget(
      OneFiApp(service: MockMarketplaceService(delay: Duration.zero)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_bag_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Top Brands'), findsOneWidget);
    expect(find.text('Nearby'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Nova Pro 5G'), findsOneWidget);
  });

  testWidgets('product flow requires a plan before proceeding', (tester) async {
    await tester.pumpWidget(
      OneFiApp(service: MockMarketplaceService(delay: Duration.zero)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_bag_rounded));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova Pro 5G'));
    await tester.pumpAndSettle();
    final disabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Select EMI'),
    );
    expect(disabled.onPressed, isNull);
    await tester.scrollUntilVisible(find.text('3 months'), 300);
    await tester.tap(find.text('3 months'));
    await tester.pump();
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
  });
}
