# 1Fi Marketplace — Implementation

The supplied repository was already a Flutter application, so delivery stays on Flutter rather than replacing the working native toolchain with Expo. This preserves the requested mobile targets while reducing dependencies and setup risk.

The implementation uses Material 3 and only Flutter SDK features. Domain types and INR formatting are in `lib/models.dart`; the replaceable API contract, deterministic fixtures, delay, errors, filtering, and EMI lookup are in `lib/marketplace_service.dart`; screens and focused reusable widgets are in `lib/main.dart`.

The four-tab shell keeps Home, Money, Shop, and Profile available while preserving each tab's state. `MarketplaceAppState` is the single dependency-free source of truth for cart quantities, full-payment purchases, EMI purchases, and order history. Shop owns its selected section and debounced query; details own selected variant and selected plan. Selecting a variant clears the plan and starts a new request. Standard routes handle cart, details, confirmation, success, and orders.

Delivery checks are `flutter analyze`, `flutter test`, and `flutter build web`. The test suite covers currency formatting, catalog filtering, variant-specific plans, cart-to-order state, Shop rendering, and disabled/enabled EMI CTA behavior.
