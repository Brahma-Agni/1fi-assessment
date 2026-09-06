# 1Fi Marketplace — Testing and Verification

This guide documents the automated suite, build verification, controlled failure testing, responsive checks, and manual acceptance walkthrough.

## 1. Quality gate

Run from the repository root:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

Expected outcome:

- formatting exits successfully;
- analyzer reports no issues;
- all eight tests pass;
- `build/web/` is generated;
- `build/app/outputs/flutter-apk/app-debug.apk` is generated.

## 2. Automated test inventory

All current tests live in `test/marketplace_test.dart`.

| Test | Type | What it protects |
| --- | --- | --- |
| Indian currency grouping | Unit | Major INR values render with Indian digit grouping |
| Product name/category filtering | Unit | Search finds names, categories, appliances, and all ten fixtures |
| Variant-specific plans | Unit | Plans for one product variant do not leak from sibling variants |
| Cart purchase state | Unit | Duplicate lines aggregate, checkout creates orders, cart clears |
| EMI purchase activity | Unit | EMI orders remain identifiable to the Money experience |
| Primary navigation | Widget | Home, Money, and Profile destinations are functional |
| Shop rendering | Widget | Shop selector and async catalog render successfully |
| EMI CTA state | Widget | Continue is disabled before plan selection and enabled afterward |

## 3. Test design

### Zero-delay service injection

Widget tests inject:

```dart
MockMarketplaceService(delay: Duration.zero)
```

This keeps behavior asynchronous without adding real-time delay to the suite.

### State isolation

Tests create a new `MarketplaceAppState` for each scenario. No test depends on order/cart data created by another test.

### Deterministic fixtures

Product IDs, variant IDs, plan IDs, prices, and plan terms are static. Tests do not require network access or external accounts.

## 4. Controlled error testing

`MockMarketplaceService` can fail exactly one request:

```dart
final service = MockMarketplaceService();
service.failNextRequest = true;
```

Recommended manual cases:

1. Set `failNextRequest` before the initial catalog request.
2. Verify catalog error copy and Retry.
3. Retry and verify products load normally.
4. Repeat before product lookup.
5. Repeat before EMI lookup.
6. Confirm that product details remain visible during an EMI failure.
7. Confirm that EMI continuation remains disabled until plans recover and a plan is selected.

The flag resets after throwing, so Retry is deterministic.

## 5. Manual acceptance walkthrough

### 5.1 Application shell

- [ ] App opens on Home.
- [ ] All four bottom destinations are present.
- [ ] Selected destination styling follows each tap.
- [ ] Returning to Shop preserves its section and scroll state.
- [ ] Back returns from secondary routes without trapping the user.

### 5.2 Home

- [ ] Spending limit shows ₹1,20,000 before EMI activity.
- [ ] Shop quick action changes to Shop.
- [ ] Cart quick action opens Cart.
- [ ] Orders quick action opens Orders.
- [ ] Recommendations scroll horizontally.
- [ ] No-purchase state is helpful.
- [ ] Recent purchase appears after checkout.

### 5.3 Shop and catalog

- [ ] Top Brands is selectable and intentionally empty.
- [ ] Nearby is selectable and intentionally empty.
- [ ] Marketplace shows ten products.
- [ ] Cards show category, name, price, artwork, and EMI availability.
- [ ] `TV` finds VisionView QLED TV.
- [ ] `washing` finds EcoWash Front Load.
- [ ] `audio` finds QuietBeat Studio.
- [ ] A nonexistent query shows No Products Found.
- [ ] Clear Search restores the full catalog.

### 5.4 Product and variants

- [ ] Product details show required content.
- [ ] Variant selection changes price where defined.
- [ ] Products without variants omit the selector.
- [ ] Changing variant clears an already selected EMI plan.
- [ ] Loading and Retry remain visually stable.

### 5.5 Cart

- [ ] Add to Cart uses the selected variant.
- [ ] Cart badge increments.
- [ ] Adding the same variant aggregates quantity.
- [ ] Adding a different variant creates a separate line.
- [ ] Plus/minus updates line total and subtotal.
- [ ] Decrementing from one removes the line.
- [ ] Delete removes the line.
- [ ] Empty cart shows Back to Shop.
- [ ] Place Order creates order records and clears the cart.
- [ ] Checkout copy clearly says no payment is processed.

### 5.6 EMI

- [ ] Plans correspond to the selected variant.
- [ ] Tenure, monthly amount, total, interest/zero-cost, and fee are visible.
- [ ] Exactly one plan is selected at a time.
- [ ] Select EMI is disabled before selection.
- [ ] Continue appears after selection.
- [ ] Purchase Review matches the selected plan.
- [ ] Confirm Purchase creates an EMI order.

### 5.7 Orders and Money

- [ ] Purchase Success shows order references and total.
- [ ] Orders show newest purchases first.
- [ ] Full-payment orders say Paid in full.
- [ ] EMI orders show tenure.
- [ ] Money active-plan count increases after an EMI purchase.
- [ ] Monthly EMI equals the sum of recorded plan installments.
- [ ] Available limit decreases based on EMI total payable.

### 5.8 Profile

- [ ] Order, cart, and EMI metrics match shared state.
- [ ] Orders and Cart routes work.
- [ ] Placeholder account actions provide feedback.
- [ ] About shows the correct app name and version.

## 6. Responsive verification

At minimum, inspect:

| Viewport | Purpose |
| --- | --- |
| 320 × 640 | Small-phone wrapping and touch access |
| 390 × 844 | Typical modern phone |
| 430 × 932 | Large phone |
| ≥ 540 wide | Two-column catalog breakpoint |

Check every viewport for:

- clipped prices or tenure;
- overflowing variant labels;
- inaccessible cart quantity controls;
- content obscured by sticky actions or bottom navigation;
- scrollable confirmation/order content;
- readable empty and error messages.

## 7. Accessibility verification

- Enable TalkBack or VoiceOver on a physical device/simulator.
- Confirm product artwork has meaningful labels.
- Confirm product cards and plan cards are announced as controls.
- Confirm selected Shop section and EMI plan are announced.
- Confirm disabled EMI action is announced as disabled.
- Confirm focus can reach sticky actions after scrolling.
- Confirm cart icon badges do not replace the accessible cart label.
- Increase system text size and inspect essential money/plan wrapping.
- Verify plan selection remains understandable without relying only on color.

## 8. Performance checks

For this fixture scale, verify qualitatively:

- tab changes are immediate;
- catalog scroll remains smooth;
- quantity updates do not visibly lag;
- search results update after the intentional debounce;
- loading delay does not freeze navigation;
- no external image network requests affect first render.

For production-scale catalogs, add profiling, pagination, image caching, and automated performance budgets.

## 9. Platform verification

### Android

```bash
flutter build apk --debug
```

The native debug APK has been built successfully in the delivery environment.

Optional device installation:

```bash
flutter install
```

### Web

```bash
flutter build web
```

Review `build/web/` through a local web server or use `flutter run -d chrome`.

### iOS

Run on macOS with Xcode:

```bash
flutter build ios --release
```

Resolve signing team, bundle identifier, deployment target, and provisioning before distribution.

## 10. Regression policy

Before merging a change:

1. Add or update the smallest test that proves the changed behavior.
2. Run formatting, analysis, and tests.
3. Exercise the modified route at a narrow phone size.
4. Rebuild the affected native/web artifact when platform code or dependencies change.
5. Update README, SRS, implementation notes, or user guide when visible behavior or architecture changes.

## 11. Current verified status

| Check | Status |
| --- | --- |
| Dart formatting | Passing |
| Flutter static analysis | No issues |
| Automated tests | 8 passing |
| Web release build | Passing |
| Android debug APK | Passing |
| Phone-sized web walkthrough | Passing |
| iOS native build | Pending macOS/Xcode environment |
