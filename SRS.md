# 1Fi Marketplace — Software Requirements Specification

**Document version:** 2.0

**Application version:** 1.0.0+1

**Status:** Implemented assessment scope

**Primary platforms:** Android and iOS

**Secondary review platform:** Web

## 1. Purpose

This document defines the functional, experience, data, quality, and acceptance requirements for the standalone 1Fi Marketplace application. The product demonstrates a connected finance-shopping journey in which a shopper can discover products, understand pricing and EMI terms, manage a cart, record a simulated purchase, and review resulting order and finance activity.

The application was built from scratch because no 1Fi source repository, production API, authentication system, or official design system was supplied.

## 2. Product scope

The implemented application contains four primary destinations:

1. **Home** — spending-limit summary, quick actions, product discovery, and recent purchases.
2. **Money** — available limit, active EMI metrics, EMI purchase records, and finance-tool placeholders.
3. **Shop** — promotional shell, product search, Marketplace catalog, product details, variants, cart, and EMI purchase flow.
4. **Profile** — demo identity, activity metrics, cart, orders, support placeholders, and application information.

The Shop selector also contains **Top Brands** and **Nearby Stores**. These two sections remain deliberately empty to preserve the original assignment boundary.

## 3. Product objectives

- Present a polished, trustworthy, mobile-first finance-shopping experience.
- Help shoppers understand product cost before choosing a payment method.
- Make EMI terms explicit rather than hiding total payable or fees.
- Keep cart, purchase, order, and EMI activity synchronized across the app.
- Demonstrate maintainable Flutter engineering with typed data and clear ownership.
- Exercise realistic asynchronous loading, error, retry, and empty states.
- Avoid implying that a simulated checkout is a real payment or lending transaction.

## 4. Users and primary journeys

### 4.1 New shopper

1. Opens the app on Home.
2. Reviews the simulated available spending limit.
3. Opens Shop through quick actions or bottom navigation.
4. Searches or browses the catalog.
5. Opens a product and reviews its price, variants, description, and specifications.
6. Adds the selected variant to the cart or selects an EMI plan.

### 4.2 Cart shopper

1. Adds one or more product variants to the cart.
2. Opens the cart from Home, Shop, or Profile.
3. Changes quantities or removes lines.
4. Reviews line totals, subtotal, and delivery summary.
5. Places a simulated full-payment order.
6. Receives local order references and opens order history.

### 4.3 EMI shopper

1. Opens an EMI-eligible product.
2. Chooses a variant when applicable.
3. Waits for variant-appropriate plans to load.
4. Selects exactly one plan.
5. Reviews monthly installment, tenure, total payable, interest status, and fee.
6. Confirms the simulated purchase.
7. Sees the purchase in Orders, recent Home activity, Profile metrics, and Money activity.

### 4.4 Returning in-session shopper

1. Uses Home to review recent purchases.
2. Uses Money to review active EMI plans and monthly commitments.
3. Uses Profile to reopen the cart or order history.

## 5. Functional requirements

### 5.1 Application shell and navigation

- FR-001: The application shall display Home, Money, Shop, and Profile in persistent bottom navigation.
- FR-002: Selecting a destination shall update the active visual indicator.
- FR-003: Each destination shall preserve its widget state while another tab is active.
- FR-004: Product details, cart, confirmation, success, and orders shall use stack navigation with a standard back action.
- FR-005: Navigation shall not trap the user in checkout or success routes.
- FR-006: Cart badges shall reflect the total quantity across cart lines.

### 5.2 Home

- FR-100: Home shall show a 1Fi header and available spending-limit card.
- FR-101: Home shall provide direct actions for Shop, Cart, and Orders.
- FR-102: Quick-action badges shall reflect cart quantity and order count.
- FR-103: Home shall asynchronously display popular catalog products.
- FR-104: Home shall show the most recent purchase when one exists.
- FR-105: Home shall show a clear first-use state when no purchases exist.

### 5.3 Money

- FR-200: Money shall show the simulated available limit and total limit.
- FR-201: The available limit shall account for total payable on recorded EMI orders.
- FR-202: Money shall show active EMI-plan count.
- FR-203: Money shall sum monthly installments across active EMI records.
- FR-204: Money shall list each EMI product and its monthly payment.
- FR-205: Money shall show an empty state with a Shop action when there are no EMI purchases.
- FR-206: Finance tools that require a backend may be represented as non-transactional informational placeholders.

### 5.4 Shop shell

- FR-300: Shop shall show a branded header, promotional banner, search field, and three-section selector.
- FR-301: The selector shall expose Top Brands, Nearby Stores, and Marketplace.
- FR-302: The selected section shall have a visible, non-color-only selected state.
- FR-303: Top Brands and Nearby Stores shall remain stable, intentionally empty views.
- FR-304: Search shall be enabled only for Marketplace.
- FR-305: The Shop header shall provide cart access and a quantity badge.

### 5.5 Catalog and search

- FR-400: Marketplace shall request products through the typed catalog service.
- FR-401: Catalog requests shall be asynchronous.
- FR-402: Search shall match product names and categories without case sensitivity.
- FR-403: Search input shall be debounced to avoid a request on every keystroke.
- FR-404: A product card shall show category, name, current price, illustration, and EMI availability.
- FR-405: The catalog shall use one column on narrow phones and two columns when sufficient width is available.
- FR-406: Tapping a product shall open its details.
- FR-407: Catalog loading shall show progress rather than an empty flash.
- FR-408: Catalog failure shall show a friendly retry action.
- FR-409: No search matches shall show an explanation and Clear Search action.

### 5.6 Catalog content

- FR-450: The fixture catalog shall contain stable product identifiers.
- FR-451: It shall cover smartphones, laptops, audio, wearables, televisions, washing machines, refrigerators, air conditioners, kitchen appliances, and home care.
- FR-452: Product records shall include price, category, description, specifications, artwork metadata, eligibility, and optional variants.
- FR-453: Product and plan fixtures shall not be declared inside presentation widgets.

### 5.7 Product details and variants

- FR-500: Details shall load the product by stable identifier.
- FR-501: Details shall show illustration, category, name, current price, optional original price, description, and specifications.
- FR-502: Products with variants shall expose selectable variant chips.
- FR-503: Products without variants shall not display an empty selector.
- FR-504: A selected variant shall update the displayed price.
- FR-505: Unavailable variants shall not be selectable.
- FR-506: Changing a variant shall clear the selected EMI plan.
- FR-507: Product loading and failure shall have explicit progress and retry states.

### 5.8 Cart

- FR-600: Add to Cart shall use the currently selected variant.
- FR-601: Adding the same product/variant combination shall increment its quantity.
- FR-602: Different variants of one product shall be separate cart lines.
- FR-603: Cart lines shall show product, variant, quantity, and calculated line total.
- FR-604: Users shall be able to increment, decrement, and remove cart lines.
- FR-605: Decrementing below one shall remove the line.
- FR-606: Cart subtotal shall update immediately after quantity changes.
- FR-607: Checkout shall create one simulated order per cart line.
- FR-608: Successful checkout shall clear the cart.
- FR-609: Empty cart shall show a clear route back to shopping.
- FR-610: Checkout shall explicitly state that no real payment is processed.

### 5.9 EMI plans

- FR-700: EMI plans shall load asynchronously for the selected product and variant.
- FR-701: Each plan shall include tenure, monthly installment, total payable, annual interest rate, processing fee, provider label, and zero-cost status.
- FR-702: Only one plan may be selected at a time.
- FR-703: The selected plan shall be indicated by border, background, and checkmark.
- FR-704: Assistive technology shall receive the selected state.
- FR-705: The EMI continuation action shall remain disabled until a plan is selected.
- FR-706: EMI loading shall preserve already loaded product information.
- FR-707: EMI failures shall offer Retry and keep purchase continuation disabled.
- FR-708: No eligible plans shall show an informational empty state.

### 5.10 Purchase confirmation

- FR-800: Confirmation shall show product, optional variant, tenure, monthly installment, total payable, and processing fee.
- FR-801: Confirmation copy shall disclose that it is a demo and no real payment is processed.
- FR-802: Confirming shall create a simulated EMI order with a unique in-session reference.
- FR-803: A completed cart or EMI flow shall show a purchase-success screen.
- FR-804: Success shall show order count, total, and order reference identifiers.
- FR-805: Success shall offer View Orders and Continue Shopping actions.

### 5.11 Orders and purchases

- FR-900: Orders shall combine full-payment and EMI purchases in reverse chronological order.
- FR-901: Each order shall show product, optional variant, amount, quantity, payment method, reference, date, and confirmation status.
- FR-902: Empty order history shall show a route back to shopping.
- FR-903: Recent Home activity shall use the same order source as the Orders screen.

### 5.12 Profile

- FR-1000: Profile shall present a clearly labelled demo identity.
- FR-1001: Profile metrics shall reflect order count, cart quantity, and EMI count.
- FR-1002: Profile shall provide routes to Cart and Orders.
- FR-1003: About shall show application name and version.
- FR-1004: Backend-dependent Notifications and Support entries may show integration-ready feedback rather than broken screens.

## 6. Data requirements

### 6.1 Money

- All fixture money values shall use major INR units.
- Every displayed value shall use the shared Indian currency formatter.
- Total payable and monthly installment values returned by the service shall be treated as authoritative fixture data.

### 6.2 Product identity

- Product, variant, plan, and order IDs shall be stable within their relevant lifecycle.
- EMI records shall be keyed by product ID and optionally variant ID.
- Cart identity shall combine product and variant identifiers.

### 6.3 Service behavior

- Service methods shall return `Future` values.
- Mock calls shall include a short deliberate delay.
- Missing products shall produce a recoverable typed exception.
- A deterministic one-shot failure mechanism shall be available for UI demonstrations and tests.

### 6.4 State lifetime

- Catalog fixtures are immutable.
- Shop/query/detail selection is local presentation state.
- Cart and order activity is shared in-memory state.
- Shared state resets when the application process restarts.

## 7. User experience requirements

- UX-001: The visual language shall use a light tinted background, white surfaces, rounded cards, and purple interactive accents.
- UX-002: Financial figures shall have stronger hierarchy than supporting metadata.
- UX-003: Essential money and tenure information shall wrap rather than be clipped.
- UX-004: Content shall remain scrollable above persistent actions.
- UX-005: Interactive controls shall target at least 44 logical pixels where practical.
- UX-006: Empty states shall explain why no content is present and, when possible, provide recovery.
- UX-007: Destructive cart removal shall be visually distinct from purchase actions.
- UX-008: Product illustrations shall use neutral assets that do not imply merchant affiliation.
- UX-009: Checkout language shall avoid claiming that a real payment or loan was completed.

## 8. Accessibility requirements

- A11Y-001: Product imagery shall expose informative semantic labels.
- A11Y-002: Buttons shall expose their interactive role.
- A11Y-003: Section and plan selections shall expose selected state.
- A11Y-004: Disabled actions shall expose disabled state through the native button implementation.
- A11Y-005: Selection shall not rely on color alone.
- A11Y-006: Primary text and controls shall maintain readable contrast.
- A11Y-007: Safe areas shall prevent controls from colliding with system UI.

## 9. Non-functional requirements

### 9.1 Responsiveness

- Support phone widths from approximately 320 logical pixels through large phones.
- Use flexible dimensions and scrolling rather than fixed screen heights.
- Catalog columns shall adapt to available width.

### 9.2 Performance

- Keep fixture payloads small and immutable.
- Use stable product identifiers and lazy list/grid builders.
- Avoid external image downloads in the core demo.
- Avoid a global rebuild architecture more complex than required for the current data size.

### 9.3 Reliability

- All async product surfaces shall handle loading and failure.
- Dependent selections shall reset when their upstream selection changes.
- Checkout operations shall update cart and order state atomically from the user's perspective.

### 9.4 Maintainability

- Use Dart null safety and typed domain records.
- Keep fixture records behind a service interface.
- Keep shared commerce state separate from local presentation state.
- Require static analysis and tests before delivery.

### 9.5 Platform support

- Android shall build as a native APK.
- iOS host source shall remain available for Xcode builds.
- Web shall build for reviewer convenience.

## 10. State-specific experience

| Context | Loading | Error | Empty | Success |
| --- | --- | --- | --- | --- |
| Home products | Progress indicator | Service-dependent | No recommendations | Horizontal recommendations |
| Catalog | Centered progress | Explanation + Retry | No matches + Clear Search | Responsive product grid |
| Product | Centered progress | Unavailable + Retry | Not found | Full product details |
| EMI | Inline progress | Explanation + Retry | No eligible plans | Selectable plan cards |
| Cart | Not applicable | Not applicable | Empty cart + return action | Quantity and checkout summary |
| Orders | Not applicable | Not applicable | No orders + shopping action | Reverse-chronological history |
| Money | Not applicable | Not applicable | No EMI plans + Shop action | Active plan metrics and cards |

## 11. Security and financial boundaries

- No credentials, payment details, government identifiers, or credit data are collected.
- No real lending eligibility is calculated.
- No payment authorization or money movement occurs.
- No merchant order is submitted.
- No secret keys or backend tokens are required.
- Production financial integration would require server-side validation, authentication, authorization, idempotency, audit logging, encryption, and regulatory review.

## 12. Out of scope

- Real user authentication and account recovery
- Production catalog, price, inventory, and eligibility APIs
- Credit bureau checks, underwriting, loan origination, KYC, and e-signature
- Payment gateway integration and stored payment methods
- Fulfillment, shipment tracking, cancellation, refunds, and returns
- Real Nearby Stores and Top Brands content
- Analytics, notifications, localization, and remote configuration
- Persistent offline cart/order database
- App Store and Play Store deployment automation

## 13. Acceptance criteria

The build is accepted when:

- Home, Money, Shop, and Profile are functional and navigable.
- The catalog loads ten products from the asynchronous service boundary.
- Search finds both product names and categories.
- Product details display variant-aware pricing and specifications.
- Cart quantities, removal, subtotal, checkout, and clearing behave correctly.
- EMI plans are variant-aware, exclusively selectable, and fully disclosed.
- EMI and full-payment purchases create order records.
- Orders appear consistently in Home, Money, Orders, and Profile metrics.
- Loading, retry, no-results, and empty states are demonstrable.
- Narrow-phone layouts remain scrollable and usable.
- Static analysis reports no issues.
- All automated tests pass.
- Android APK and web release builds complete successfully.

## 14. Traceability

| Requirement group | Primary implementation | Verification |
| --- | --- | --- |
| Shell/navigation | `lib/main.dart` | Bottom-navigation widget test + manual walkthrough |
| Home/Money/Profile | `lib/app_pages.dart` | Navigation test + manual walkthrough |
| Catalog/service | `lib/marketplace_service.dart` | Service filtering tests |
| Product/EMI | `lib/main.dart` | Variant-plan and CTA tests |
| Cart/orders | `lib/app_state.dart`, `lib/app_pages.dart` | Cart-to-order and EMI-activity tests |
| Models/currency | `lib/models.dart` | Currency-formatting test |

## 15. Future production requirements

Before production, replace simulated boundaries with authenticated backend services, persist server-authoritative cart and orders, source EMI terms from a compliant lending service, add payment processing, protect sensitive data, implement observability, expand accessibility testing, add integration/end-to-end device tests, and complete legal/security review.
