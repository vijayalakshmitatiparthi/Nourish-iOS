import SwiftUI

@main
struct NourishBowlDemoApp: App {
    @StateObject private var store = MealStore()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store)
                .tint(Brand.forest)
        }
    }
}

enum Brand {
    static let forest = Color(red: 0.13, green: 0.36, blue: 0.27)
    static let mint = Color(red: 0.87, green: 0.94, blue: 0.86)
    static let cream = Color(red: 0.98, green: 0.975, blue: 0.945)
    static let orange = Color(red: 0.97, green: 0.65, blue: 0.29)
    static let ink = Color(red: 0.14, green: 0.21, blue: 0.17)
}

struct Ingredient: Identifiable, Hashable {
    enum Group: String, CaseIterable { case base = "Base", protein = "Protein", vegetables = "Vegetables", legumes = "Legumes", fats = "Healthy Fats", extras = "Extras" }
    let id: String
    let name: String
    let group: Group
    let icon: String
    let kcal: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let pricePer100g: Double
    let increment: Int
    let maximum: Int
    // Nutrients are illustrative amounts per 100 g of a prepared edible ingredient.
    static let catalog: [Ingredient] = [
        .init(id: "rice", name: "Brown Rice", group: .base, icon: "🍚", kcal: 112, protein: 2.6, carbs: 23, fat: 0.9, pricePer100g: 22, increment: 25, maximum: 300),
        .init(id: "quinoa", name: "Quinoa", group: .base, icon: "🌾", kcal: 120, protein: 4.4, carbs: 21.3, fat: 1.9, pricePer100g: 55, increment: 25, maximum: 300),
        .init(id: "millet", name: "Cooked Millet", group: .base, icon: "🌿", kcal: 119, protein: 3.5, carbs: 23.7, fat: 1, pricePer100g: 28, increment: 25, maximum: 300),
        .init(id: "chicken", name: "Grilled Chicken", group: .protein, icon: "🍗", kcal: 165, protein: 31, carbs: 0, fat: 3.6, pricePer100g: 95, increment: 25, maximum: 250),
        .init(id: "eggs", name: "Boiled Egg", group: .protein, icon: "🥚", kcal: 155, protein: 12.6, carbs: 1.1, fat: 10.6, pricePer100g: 48, increment: 25, maximum: 200),
        .init(id: "paneer", name: "Paneer", group: .protein, icon: "🧀", kcal: 265, protein: 18, carbs: 3, fat: 20, pricePer100g: 75, increment: 25, maximum: 250),
        .init(id: "tofu", name: "Tofu", group: .protein, icon: "◻️", kcal: 145, protein: 15, carbs: 3, fat: 8, pricePer100g: 65, increment: 25, maximum: 250),
        .init(id: "broccoli", name: "Broccoli", group: .vegetables, icon: "🥦", kcal: 35, protein: 2.4, carbs: 7.2, fat: 0.4, pricePer100g: 40, increment: 25, maximum: 200),
        .init(id: "carrot", name: "Carrot", group: .vegetables, icon: "🥕", kcal: 35, protein: 0.8, carbs: 8.2, fat: 0.2, pricePer100g: 16, increment: 25, maximum: 200),
        .init(id: "cucumber", name: "Cucumber", group: .vegetables, icon: "🥒", kcal: 15, protein: 0.7, carbs: 3.6, fat: 0.1, pricePer100g: 14, increment: 25, maximum: 200),
        .init(id: "chickpeas", name: "Chickpeas", group: .legumes, icon: "🫘", kcal: 164, protein: 8.9, carbs: 27.4, fat: 2.6, pricePer100g: 32, increment: 25, maximum: 200),
        .init(id: "almonds", name: "Almonds", group: .fats, icon: "🥜", kcal: 579, protein: 21.2, carbs: 21.6, fat: 49.9, pricePer100g: 160, increment: 10, maximum: 50),
        .init(id: "pumpkin", name: "Pumpkin Seeds", group: .fats, icon: "🌱", kcal: 559, protein: 30, carbs: 10.7, fat: 49, pricePer100g: 120, increment: 10, maximum: 50),
        .init(id: "yogurt", name: "Yogurt Dressing", group: .extras, icon: "🥣", kcal: 75, protein: 4, carbs: 6, fat: 4, pricePer100g: 30, increment: 25, maximum: 100)
    ]
}

struct Macros {
    var kcal: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
}

struct DemoOrder: Identifiable, Codable {
    let id: UUID
    let date: Date
    let title: String
    let details: String
    let total: Int
    let kind: String
}

final class MealStore: ObservableObject {
    @Published var quantities: [String: Int] = ["rice": 100, "chicken": 125, "broccoli": 50, "carrot": 50, "chickpeas": 50, "almonds": 10]
    @Published var activeTab: Int = 0
    @Published var orders: [DemoOrder] = [] { didSet { persistOrders() } }
    @Published var planDays = 30
    @Published var mealsPerDay = 2
    @Published var deliverySlot = "Lunch · 12–2 PM"
    @Published var vegetarian = false
    @Published var showCheckout = false
    @Published var showSuccess = false
    init() {
        if let data = UserDefaults.standard.data(forKey: "nourish_demo_orders"),
           let saved = try? JSONDecoder().decode([DemoOrder].self, from: data) { orders = saved }
    }
    var selected: [(Ingredient, Int)] { Ingredient.catalog.compactMap { item in
        let g = quantities[item.id, default: 0]
        return g > 0 ? (item, g) : nil
    } }
    var macros: Macros {
        selected.reduce(into: Macros()) { result, entry in
            let (item, grams) = entry
            let f = Double(grams) / 100
            result.kcal += item.kcal * f
            result.protein += item.protein * f
            result.carbs += item.carbs * f
            result.fat += item.fat * f
        }
    }
    var bowlPrice: Int { Int(ceil(55 + selected.reduce(0.0) { $0 + $1.0.pricePer100g * Double($1.1) / 100 })) }
    var totalGrams: Int { quantities.values.reduce(0, +) }
    var isValidBowl: Bool { totalGrams > 0 && selected.contains(where: { $0.0.group == .base || $0.0.group == .protein }) }
    var discountedSubscriptionTotal: Int {
        let discount = planDays == 30 ? 0.12 : planDays == 7 ? 0.05 : 0
        return Int((Double(bowlPrice * planDays * mealsPerDay) * (1 - discount)).rounded())
    }
    func adjust(_ item: Ingredient, by change: Int) {
        quantities[item.id] = min(item.maximum, max(0, quantities[item.id, default: 0] + change))
    }
    func usePreset(vegetarian: Bool) {
        self.vegetarian = vegetarian
        quantities = vegetarian ? ["millet": 125, "paneer": 100, "broccoli": 75, "chickpeas": 50, "pumpkin": 10] : ["rice": 100, "chicken": 125, "broccoli": 50, "carrot": 50, "chickpeas": 50, "almonds": 10]
    }
    func placeOrder(subscription: Bool) {
        let details = selected.map { "\($0.0.name) \($0.1)g" }.joined(separator: " · ")
        let new = DemoOrder(id: UUID(), date: Date(), title: subscription ? "\(planDays)-day meal plan" : "Custom nutrition bowl", details: details, total: subscription ? discountedSubscriptionTotal : bowlPrice, kind: subscription ? "Subscription · \(mealsPerDay) meals/day" : "One-time order")
        orders.insert(new, at: 0)
        showCheckout = false
        showSuccess = true
    }
    private func persistOrders() {
        if let data = try? JSONEncoder().encode(orders) { UserDefaults.standard.set(data, forKey: "nourish_demo_orders") }
    }
}

struct RootView: View {
    @EnvironmentObject var store: MealStore
    var body: some View {
        TabView(selection: $store.activeTab) {
            NavigationStack { HomeView() }.tabItem { Label("Explore", systemImage: "house.fill") }.tag(0)
            NavigationStack { BuilderView() }.tabItem { Label("Build Bowl", systemImage: "slider.horizontal.3") }.tag(1)
            NavigationStack { PlansView() }.tabItem { Label("Meal Plans", systemImage: "calendar") }.tag(2)
            NavigationStack { OrdersView() }.tabItem { Label("My Orders", systemImage: "bag") }.tag(3)
        }
        .sheet(isPresented: $store.showCheckout) { CheckoutView() }
        .alert("Demo order created!", isPresented: $store.showSuccess) {
            Button("View Orders") { store.activeTab = 3 }
            Button("Done", role: .cancel) { }
        } message: { Text("This is a prototype. No payment was taken and no food will be delivered.") }
    }
}

struct HomeView: View {
    @EnvironmentObject var store: MealStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("NOURISH").font(.system(size: 26, weight: .black, design: .rounded)).tracking(1.8).foregroundStyle(Brand.forest)
                        Text("Personal nutrition, made fresh.").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "leaf.circle.fill").font(.system(size: 36)).foregroundStyle(Brand.forest)
                }
                HStack(spacing: 5) { Image(systemName: "location.fill"); Text("Chennai · Pilot experience") }
                    .font(.caption.weight(.semibold)).foregroundStyle(Brand.forest)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Every gram.\nYour choice.")
                        .font(.system(size: 37, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    Text("Build meals your way, see macros instantly, and plan your whole week.")
                        .foregroundStyle(.white.opacity(0.9)).font(.subheadline)
                    HStack {
                        Label("Made for you", systemImage: "heart.fill")
                        Spacer()
                        Text("🥬  🍚  🍗")
                    }.font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    Button { store.activeTab = 1 } label: {
                        HStack { Text("Build your bowl"); Spacer(); Image(systemName: "arrow.up.right") }
                            .font(.headline).foregroundStyle(Brand.ink).padding(15)
                            .background(.white, in: RoundedRectangle(cornerRadius: 15))
                    }
                }
                .padding(22).background(Brand.forest.gradient, in: RoundedRectangle(cornerRadius: 24))
                HStack {
                    Text("Start with a favorite").font(.title3.bold())
                    Spacer()
                    Text("Fully editable").font(.caption).foregroundStyle(.secondary)
                }
                HStack(spacing: 12) {
                    PresetCard(icon: "🍗", name: "Power Bowl", detail: "Chicken + rice", color: Brand.mint) {
                        store.usePreset(vegetarian: false); store.activeTab = 1
                    }
                    PresetCard(icon: "🥗", name: "Plant Bowl", detail: "Millet + paneer", color: Color(red: 1, green: 0.92, blue: 0.8)) {
                        store.usePreset(vegetarian: true); store.activeTab = 1
                    }
                }
                Text("Nutrition that fits your routine").font(.title3.bold())
                HStack(spacing: 12) {
                    FeatureTile(icon: "scalemass", heading: "Portion control", text: "Adjust each ingredient by grams")
                    FeatureTile(icon: "chart.pie.fill", heading: "Live macros", text: "See estimated nutrition instantly")
                }
                HStack(spacing: 12) {
                    FeatureTile(icon: "calendar.badge.clock", heading: "Meal plans", text: "Choose 1, 7 or 30 days")
                    FeatureTile(icon: "bicycle", heading: "Chennai first", text: "Delivery concept for local launch")
                }
                Text("Demo only · Prices and nutrition are illustrative. No real orders or deliveries.")
                    .font(.caption2).foregroundStyle(.secondary)
            }.padding(20)
        }
        .background(Brand.cream)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PresetCard: View {
    let icon: String; let name: String; let detail: String; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(icon).font(.system(size: 48))
                Text(name).font(.headline).foregroundStyle(Brand.ink)
                Text(detail).font(.caption).foregroundStyle(.secondary)
                HStack { Text("Customize"); Image(systemName: "arrow.right") }
                    .font(.caption.weight(.bold)).foregroundStyle(Brand.forest)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
                .background(color, in: RoundedRectangle(cornerRadius: 20))
        }.buttonStyle(.plain)
    }
}
struct FeatureTile: View {
    let icon: String; let heading: String; let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(Brand.forest)
            Text(heading).font(.subheadline.bold())
            Text(text).font(.caption).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, minHeight: 102, alignment: .topLeading).padding(14)
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct MacroCard: View {
    let value: Double; let title: String; let unit: String
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(value.rounded()))").font(.title2.bold()).monospacedDigit().foregroundStyle(Brand.forest)
            Text(unit).font(.caption2).foregroundStyle(.secondary)
            Text(title).font(.caption.weight(.medium)).foregroundStyle(Brand.ink)
        }.frame(maxWidth: .infinity).padding(.vertical, 12)
            .background(Brand.mint.opacity(0.65), in: RoundedRectangle(cornerRadius: 13))
    }
}

struct BuilderView: View {
    @EnvironmentObject var store: MealStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                Text("Your bowl, your rules.").font(.title2.bold())
                Text("Choose prepared food quantities in grams. Adjust anything and watch the totals update.")
                    .font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    MacroCard(value: store.macros.kcal, title: "Energy", unit: "kcal")
                    MacroCard(value: store.macros.protein, title: "Protein", unit: "g")
                    MacroCard(value: store.macros.carbs, title: "Carbs", unit: "g")
                    MacroCard(value: store.macros.fat, title: "Fat", unit: "g")
                }
                ForEach(Ingredient.Group.allCases, id: \.self) { group in
                    VStack(alignment: .leading, spacing: 9) {
                        Text(group.rawValue).font(.headline).foregroundStyle(Brand.ink)
                        ForEach(Ingredient.catalog.filter { $0.group == group }) { ingredient in
                            IngredientRow(item: ingredient)
                        }
                    }
                }
                Text("Estimates based on generic cooked-ingredient data. Recipe-specific oils, cooking loss, micronutrients, and allergens require validation before commercial launch.")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(18).padding(.bottom, 92)
        }
        .background(Brand.cream)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("\(store.totalGrams) g selected").font(.caption).foregroundStyle(.secondary)
                    Text("₹\(store.bowlPrice)").font(.title2.bold()).foregroundStyle(Brand.forest)
                }
                Spacer()
                Button { store.showCheckout = true } label: {
                    HStack { Text("Continue"); Image(systemName: "arrow.right") }.font(.headline).padding(.horizontal, 21).padding(.vertical, 15)
                }.buttonStyle(PrimaryButton()).disabled(!store.isValidBowl)
            }.padding(.horizontal, 18).padding(.vertical, 10)
                .background(.regularMaterial)
        }
        .navigationTitle("Build a Bowl")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Reset") { store.usePreset(vegetarian: false) }.font(.subheadline) } }
    }
}
struct IngredientRow: View {
    @EnvironmentObject var store: MealStore
    let item: Ingredient
    var body: some View {
        HStack(spacing: 12) {
            Text(item.icon).font(.title2).frame(width: 37, height: 42)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name).font(.subheadline.weight(.semibold))
                Text("₹\(Int(item.pricePer100g))/100g").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 6)
            Button { store.adjust(item, by: -item.increment) } label: { Image(systemName: "minus").frame(width: 28, height: 28) }
                .disabled(store.quantities[item.id, default: 0] == 0)
            Text("\(store.quantities[item.id, default: 0])g").font(.subheadline.monospacedDigit().weight(.semibold)).frame(minWidth: 47)
            Button { store.adjust(item, by: item.increment) } label: { Image(systemName: "plus").frame(width: 28, height: 28) }
                .disabled(store.quantities[item.id, default: 0] >= item.maximum)
        }
        .buttonStyle(.borderless).foregroundStyle(Brand.forest)
        .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 15))
    }
}
struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.foregroundStyle(.white)
            .background(Brand.forest, in: RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct PlansView: View {
    @EnvironmentObject var store: MealStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Good food, on repeat.").font(.title2.bold())
                    Text("Turn your current bowl into a recurring meal plan. Change ingredients in Build Bowl first.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Text("Choose your duration").font(.headline)
                HStack(spacing: 10) {
                    ForEach([1,7,30], id: \.self) { days in
                        Button { store.planDays = days } label: {
                            VStack(spacing: 4) {
                                Text("\(days)").font(.title2.bold())
                                Text(days == 1 ? "Day" : "Days").font(.caption)
                            }.frame(maxWidth: .infinity).padding(14)
                                .background(store.planDays == days ? Brand.forest : .white, in: RoundedRectangle(cornerRadius: 16))
                                .foregroundStyle(store.planDays == days ? .white : Brand.ink)
                        }.buttonStyle(.plain)
                    }
                }
                Text("Meals every day").font(.headline)
                HStack(spacing: 10) {
                    ForEach(1...3, id: \.self) { count in
                        Button { store.mealsPerDay = count } label: {
                            VStack(spacing: 5) {
                                Image(systemName: count == 1 ? "fork.knife" : count == 2 ? "fork.knife.circle" : "sun.horizon")
                                    .font(.title3)
                                Text("\(count) meal\(count == 1 ? "" : "s")").font(.subheadline.bold())
                            }.frame(maxWidth: .infinity).padding(.vertical, 17)
                                .background(store.mealsPerDay == count ? Brand.mint : .white, in: RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(store.mealsPerDay == count ? Brand.forest : .clear, lineWidth: 1.5))
                        }.buttonStyle(.plain).foregroundStyle(Brand.forest)
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sample plan summary").font(.headline)
                    HStack { Text("Current customized bowl"); Spacer(); Text("₹\(store.bowlPrice)") }
                    HStack { Text("Total meals"); Spacer(); Text("\(store.planDays * store.mealsPerDay)") }
                    HStack { Text("Plan discount"); Spacer(); Text(store.planDays == 30 ? "12%" : store.planDays == 7 ? "5%" : "0%") }
                    Divider()
                    HStack {
                        Text("Estimated total").font(.headline)
                        Spacer()
                        Text("₹\(store.discountedSubscriptionTotal)").font(.title2.bold()).foregroundStyle(Brand.forest)
                    }
                    Text("Illustrative pricing only. Delivery, taxes, meal variety and subscription policies have not been finalized.")
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(17).background(.white, in: RoundedRectangle(cornerRadius: 20))
                Button { store.showCheckout = true } label: {
                    HStack { Spacer(); Text("Preview this plan"); Image(systemName: "arrow.right"); Spacer() }.font(.headline).padding(17)
                }.buttonStyle(PrimaryButton()).disabled(!store.isValidBowl)
                Text("The finished service will allow separate breakfast, lunch and dinner menus, dietary preferences, skips and swaps. This demo repeats the current bowl to illustrate the subscription flow.")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(18)
        }
        .background(Brand.cream).navigationTitle("Meal Plans").navigationBarTitleDisplayMode(.inline)
    }
}

struct CheckoutView: View {
    @EnvironmentObject var store: MealStore
    @Environment(\.dismiss) var dismiss
    @State private var subscription = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Review your meal").font(.title2.bold())
                    Picker("Order type", selection: $subscription) {
                        Text("One-time").tag(false)
                        Text("Subscription").tag(true)
                    }.pickerStyle(.segmented)
                    VStack(spacing: 12) {
                        ForEach(Ingredient.catalog.filter { store.quantities[$0.id, default: 0] > 0 }) { ingredient in
                            HStack { Text("\(ingredient.icon) \(ingredient.name)"); Spacer(); Text("\(store.quantities[ingredient.id, default: 0]) g").monospacedDigit() }
                                .font(.subheadline)
                        }
                    }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
                    if subscription {
                        Text("\(store.planDays) days · \(store.mealsPerDay) meals/day").font(.headline)
                        Text("All meals repeat your currently configured bowl in this demo.").font(.caption).foregroundStyle(.secondary)
                    } else {
                        Picker("Preferred slot", selection: $store.deliverySlot) {
                            Text("Breakfast · 7–10 AM").tag("Breakfast · 7–10 AM")
                            Text("Lunch · 12–2 PM").tag("Lunch · 12–2 PM")
                            Text("Dinner · 7–9 PM").tag("Dinner · 7–9 PM")
                        }
                    }
                    HStack { Text("Estimated total").font(.headline); Spacer(); Text("₹\(subscription ? store.discountedSubscriptionTotal : store.bowlPrice)").font(.title2.bold()).foregroundStyle(Brand.forest) }
                    Text("DEMO CHECKOUT · No payment, delivery, account registration, or real kitchen is connected.")
                        .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Button { store.placeOrder(subscription: subscription) } label: {
                        HStack { Spacer(); Text("Place demo order"); Image(systemName: "checkmark.circle.fill"); Spacer() }.font(.headline).padding(16)
                    }.buttonStyle(PrimaryButton())
                }.padding(20)
            }
            .background(Brand.cream)
            .navigationTitle("Checkout").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() } } }
        }
        .presentationDragIndicator(.visible)
    }
}

struct OrdersView: View {
    @EnvironmentObject var store: MealStore
    var body: some View {
        Group {
            if store.orders.isEmpty {
                VStack(spacing: 13) {
                    Image(systemName: "bag.badge.plus").font(.system(size: 60)).foregroundStyle(Brand.forest)
                    Text("No orders yet").font(.title2.bold())
                    Text("Build your first bowl and try the demo checkout.")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    Button("Build a bowl") { store.activeTab = 1 }.buttonStyle(.borderedProminent)
                }.padding(32).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.orders) { order in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(order.title).font(.headline)
                                        Text(order.kind).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("₹\(order.total)").font(.headline).foregroundStyle(Brand.forest)
                                }
                                Text(order.details).font(.subheadline).foregroundStyle(.secondary)
                                Divider()
                                HStack {
                                    Text(order.date, style: .date)
                                    Spacer()
                                    Label("Demo only", systemImage: "checkmark.seal")
                                }.font(.caption).foregroundStyle(.secondary)
                            }.padding(17).background(.white, in: RoundedRectangle(cornerRadius: 18))
                        }
                    }.padding(18)
                }
            }
        }
        .background(Brand.cream)
        .navigationTitle("My Orders")
        .navigationBarTitleDisplayMode(.inline)
    }
}
