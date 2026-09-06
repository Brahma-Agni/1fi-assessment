# 1Fi Marketplace — Implementation

The supplied repository was already a Flutter application, so delivery stays on Flutter rather than replacing the working native toolchain with Expo. This preserves the requested mobile targets while reducing dependencies and setup risk.

The implementation uses Material 3 and only Flutter SDK features. Domain types and INR formatting are in `lib/models.dart`; the replaceable API contract, deterministic fixtures, delay, errors, filtering, and EMI lookup are in `lib/marketplace_service.dart`; screens and focused reusable widgets are in `lib/main.dart`.

State remains local: Shop owns its selected section and debounced query; the catalog owns its request; details own selected variant and selected plan. Selecting a variant clears the plan and starts a new request. Navigation is a standard route stack for Shop → details → confirmation.

Delivery checks are `flutter analyze`, `flutter test`, and `flutter build web`. The test suite covers currency formatting, catalog filtering, variant-specific plans, Shop rendering, and disabled/enabled CTA behavior.
