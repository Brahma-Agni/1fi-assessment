# 1Fi Marketplace

A focused Flutter implementation of the 1Fi Shop assignment: browse a mock-service-backed catalog, search products, inspect variants and specifications, choose one transparent EMI plan, and review a non-payment confirmation.

This app was built from scratch because no 1Fi source code, design system, or backend was supplied. Product and EMI records are simulated behind an asynchronous typed service and are not embedded in UI widgets.

## Features

- Shop shell with promotional banner, search, bottom navigation, and three-section selector
- Intentionally blank Top Brands and Nearby Stores sections
- Responsive Marketplace catalog with loading, retryable error, and no-results states
- Product details, variant-specific price and EMI loading
- Exclusive EMI selection with tenure, installment, total, rate, and fee disclosure
- Accessible selected/disabled semantics and a safe confirmation handoff
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

`lib/models.dart` owns typed domain records and INR formatting. `lib/marketplace_service.dart` defines the replaceable service boundary, mock fixtures, deliberate latency, recoverable errors, catalog filtering, and variant-specific EMI lookup. `lib/main.dart` owns the compact UI and local screen state. No global store or third-party runtime package is needed for this assignment.

For a controlled retry-state demo, set `failNextRequest = true` on `MockMarketplaceService` before the next request.

## Scope

This is a product-selection demonstration, not a checkout. Authentication, credit underwriting, payments, fulfillment, real inventory, store discovery, and production APIs are intentionally out of scope. Product artwork is neutral emoji-based placeholder art and does not imply merchant affiliation.

See [SRS.md](SRS.md) and [IMPLEMENTATION.md](IMPLEMENTATION.md) for acceptance scope and delivery decisions.
