# 1Fi Marketplace

A complete Flutter finance-shopping experience spanning Home, Money, Shop, and Profile: browse a mock-service-backed catalog, manage a cart, buy products, choose transparent EMI plans, and review orders and purchases.

This app was built from scratch because no 1Fi source code, design system, or backend was supplied. Product and EMI records are simulated behind an asynchronous typed service and are not embedded in UI widgets.

## Features

- Shop shell with promotional banner, search, bottom navigation, and three-section selector
- Functional Home dashboard with spending limit, quick actions, recommendations, and recent purchases
- Functional Money dashboard with active EMI plans and monthly commitments
- Functional Profile with account activity, cart, orders, help, and app information
- Intentionally blank Top Brands and Nearby Stores sections
- Ten-product catalog spanning phones, laptops, audio, wearables, televisions, washing machines, refrigerators, air conditioners, kitchen appliances, and home care
- Responsive Marketplace catalog with loading, retryable error, and no-results states
- Product details, variant-specific price and EMI loading
- Shared cart with quantities, removal, totals, and full-payment demo checkout
- Exclusive EMI selection with tenure, installment, total, rate, and fee disclosure
- Order history for both EMI and full-payment purchases
- Accessible selected/disabled semantics and safe purchase confirmation
- Deterministic service and widget tests

## Run

Prerequisite: Flutter 3.35+ with an Android/iOS device, emulator, or Chrome target.

```bash
flutter pub get
flutter run
```

## Verify

```bash
flutter analyze
flutter test
flutter build web
```

## Architecture

`lib/models.dart` owns typed catalog records and INR formatting. `lib/marketplace_service.dart` defines the replaceable service boundary, mock fixtures, deliberate latency, recoverable errors, catalog filtering, and variant-specific EMI lookup. `lib/app_state.dart` owns cart, order, purchase, and EMI state. `lib/app_pages.dart` contains Home, Money, Profile, Cart, Orders, and purchase-success experiences. `lib/main.dart` owns the app shell, Shop, catalog, product, and EMI flow. No third-party runtime package is needed.

For a controlled retry-state demo, set `failNextRequest = true` on `MockMarketplaceService` before the next request.

## Scope

This is a product demonstration with local mock checkout. Authentication, real credit underwriting, payment processing, fulfillment, inventory, store discovery, persistence, and production APIs remain intentionally out of scope. Product artwork uses neutral icon illustrations and does not imply merchant affiliation.

See [SRS.md](SRS.md) and [IMPLEMENTATION.md](IMPLEMENTATION.md) for acceptance scope and delivery decisions.
