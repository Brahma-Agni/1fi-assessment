# 1Fi Marketplace — User Guide

This guide explains how to explore every implemented experience in the application. All financial and order actions are local simulations; they do not charge money or create a real loan.

## 1. Launching the app

From the project directory:

```bash
flutter pub get
flutter run
```

Choose an Android/iOS device or Chrome when prompted. The app opens on **Home**.

## 2. Bottom navigation

The bottom bar remains available on all four main destinations:

| Destination | Purpose |
| --- | --- |
| Home | Purchasing-power summary, shortcuts, recommendations, recent activity |
| Money | Available limit, monthly EMI total, active EMI records |
| Shop | Catalog search, product details, variants, cart, EMI selection |
| Profile | Demo account, activity totals, cart, orders, support placeholders |

The active destination is shown with a highlighted icon background.

## 3. Home

### Spending limit

The purple card shows a simulated total spending limit of ₹1,20,000. Its available amount decreases when an EMI purchase is recorded during the current session.

This value is demonstration data—not a credit offer or eligibility decision.

### Quick actions

- **Shop** opens the Marketplace tab.
- **Cart** opens the current cart. Its badge shows total quantity.
- **Orders** opens order history. Its badge shows recorded order count.

### Popular products

Swipe horizontally to browse popular catalog products. Select a card or View All to move into Shop.

### Recent purchases

Before a purchase, this section explains that nothing has been recorded. After checkout, it shows the most recent order and provides access to complete history.

## 4. Shop

### Shop sections

The segmented selector contains:

- **Top Brands** — intentionally empty for this assignment.
- **Nearby** — intentionally empty for this assignment.
- **Marketplace** — the complete product catalog.

The selected section persists when navigating to and back from product details.

### Search

Search supports product names and categories. Examples:

- `TV`
- `washing`
- `audio`
- `air conditioners`
- `Nova`
- `home care`

Typing is debounced briefly before results update. Select the clear icon to restore the full catalog. If nothing matches, select **Clear search** from the empty state.

### Product catalog

Each card displays:

- category;
- product name;
- current starting price;
- EMI availability;
- category-specific illustration;
- arrow to open details.

The catalog contains smartphones, laptops, audio, wearables, TVs, washing machines, refrigerators, air conditioners, microwaves, and smart home-care equipment.

## 5. Product details

Select any catalog card to open details.

### Product information

The screen shows:

- product illustration;
- category and name;
- current price;
- original price when available;
- description;
- product specifications.

### Variants

When variants exist, select one chip. Variants may represent storage, color, size, capacity, or energy rating.

Changing a variant:

1. updates the displayed price;
2. clears any previously selected EMI plan;
3. loads plans for the new variant.

Products without variants skip this section.

## 6. Adding products to the cart

1. Open a product.
2. Select the desired variant when applicable.
3. Select **Add to cart**.
4. Confirm the “Added to your cart” message.

Adding the same variant again increments its quantity. Adding a different variant creates a separate line.

The cart badge updates on Shop and Home.

## 7. Managing the cart

Open Cart from the Shop header, Home quick actions, or Profile.

For each line you can:

- select `+` to increase quantity;
- select `−` to decrease quantity;
- select the delete icon to remove it immediately.

The line total and subtotal update automatically. Decreasing quantity from one removes the line.

### Demo full-payment checkout

1. Review product, variant, quantity, subtotal, and free delivery.
2. Select **Place order**.
3. The app creates one local order per cart line.
4. The cart is cleared.
5. The success screen displays order reference numbers and total.

No payment method is collected and no payment is processed.

## 8. Choosing an EMI plan

Scroll to **Choose your EMI plan** on product details.

Each plan shows:

- tenure in months;
- monthly installment;
- total payable;
- zero-cost status or annual interest rate;
- processing fee when applicable.

Only one plan may be selected. Selection is shown through a checkmark, colored background, and stronger border.

The **Select EMI** action remains disabled until a plan is selected. After selection it becomes **Continue**.

## 9. Confirming an EMI purchase

1. Select an EMI plan.
2. Select **Continue**.
3. Review product, variant, tenure, monthly payment, total payable, and fee.
4. Select **Confirm purchase**.
5. The app records a local EMI order and displays its reference.

This confirmation simulates a completed product selection. It does not perform credit checks, originate a loan, or move money.

## 10. Purchase success

The success screen displays:

- number of purchased items;
- total recorded value;
- generated order reference(s);
- local confirmed status.

Use **View orders** to open history or **Continue shopping** to return to the application shell.

## 11. Orders and purchases

Open Orders from Home or Profile.

Orders are newest first. Each detailed card shows:

- product and selected variant;
- payment method (`Paid in full` or an EMI tenure);
- order amount;
- order reference;
- date;
- quantity;
- confirmation status.

Order status remains Confirmed because no real merchant or fulfillment backend is connected.

## 12. Money

Money summarizes recorded EMI activity.

### Available spending limit

The app subtracts the total payable of in-session EMI orders from the simulated ₹1,20,000 limit. It never performs a real eligibility calculation.

### Metrics

- **Active plans** — count of recorded EMI orders.
- **Monthly EMI** — sum of monthly installments across those orders.

### EMI plan cards

Each active plan shows the product, tenure, confirmed status, and monthly payment.

When there are no plans, select **Explore products** to return to Shop.

## 13. Profile

Profile uses a clearly labelled Guest Shopper demo identity.

The metric cards show:

- number of orders;
- total cart quantity;
- number of EMI purchases.

Available actions:

- **Orders & purchases** — complete history.
- **Your cart** — current cart.
- **Notifications** — backend integration placeholder.
- **Help & support** — backend integration placeholder.
- **About 1Fi Marketplace** — app name and version.

## 14. Loading, error, and empty states

### Loading

Product catalog, product details, and EMI plans display progress while the mock service waits.

### Error

A controlled service failure displays plain-language feedback and a Retry action. Retrying requests the same data again.

### Empty

- No search matches → Clear Search.
- Empty cart → Back to Shop.
- No orders → Start Shopping.
- No EMI activity → Explore Products.
- No eligible plans → informational explanation with disabled EMI continuation.

## 15. Resetting demo data

Cart, order, purchase, and EMI activity are stored only in memory. Fully restarting or refreshing the application returns it to its initial empty state.

Hot reload may preserve state; use hot restart (`R`) when developing if a full UI reset is needed.

## 16. Troubleshooting

### No devices are available

```bash
flutter doctor
flutter devices
```

Start an emulator, connect an authorized Android device, open an iOS simulator on macOS, or run with `-d chrome`.

### The browser shows an old catalog

Perform a hard refresh or restart `flutter run`. A release web build can also be served again after `flutter build web`.

### Cart or orders disappeared

This is expected after a full restart because the demo has no persistence backend.

### A plan disappeared after changing variants

This is intentional. EMI selection resets because eligibility and terms can differ by variant.
