# Nourish: SwiftUI demo iOS application

A local, offline prototype for a Chennai-first custom healthy meal bowl and daily subscription startup.

## Run
1. Unzip the folder on a Mac.
2. Open `NourishBowlDemo.xcodeproj` using **Xcode 16 or later**.
3. Select an iPhone simulator running iOS 17+.
4. Press **Run** (⌘R).
5. For a physical iPhone, choose your own Apple Developer Team in Signing & Capabilities, then select your device and Run.

No API keys or third-party packages are required.

## Demo features
- Explore tab with brand hero, editable starter presets and feature highlights.
- Build Bowl with 14 ingredients, adjustable cooked portions, real-time calories/protein/carbs/fats and indicative INR pricing.
- Meal Plans with 1-, 7- and 30-day durations, 1–3 meals/day and illustrative discounts.
- Sample checkout (one-time or subscription), breakfast/lunch/dinner time slots.
- Local mock order history saved with UserDefaults.

## Intentional limitations
- **Demo only.** Orders are local to your device. There are no real payments, kitchens, customer accounts or deliveries.
- Nutrition figures are generic, illustrative estimates per 100g prepared ingredient, not validated commercial labels or medical guidance.
- Prices are planning placeholders and omit final delivery/tax accounting.
- Subscriptions currently repeat the user's selected bowl. A real app needs a weekly calendar, separate breakfast/lunch/dinner menus, swaps, skips, cutoffs and billing integrations.
- No cloud backend or admin/kitchen management app included in this first customer-facing demonstration.

## Suggested next phase
Separate models, views and services; add a production ingredient database, validated recipe versions, pricing service, backend APIs, kitchen ticketing, inventory, subscription scheduler, payment integration and delivery routing.
