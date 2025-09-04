import SwiftUI

// MARK: - Product Model
struct Product: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let price: String
    let description: String
    let category: String
}

let sampleProducts = [
    Product(name: "Sneakers", imageName: "sneakers", price: "$79", description: "Colorful & comfy sneakers.", category: "Shoes"),
    Product(name: "T-Shirt", imageName: "tshirt", price: "$25", description: "Stylish cotton t-shirt.", category: "Clothing"),
    Product(name: "Backpack", imageName: "backpack", price: "$49", description: "Trendy daily backpack.", category: "Accessories"),
    Product(name: "Headphones", imageName: "headphones", price: "$99", description: "Crystal-clear sound.", category: "Electronics"),
    Product(name: "Smartwatch", imageName: "smartwatch", price: "$200", description: "Track fitness in style.", category: "Electronics"),
    Product(name: "Hoodie", imageName: "hoodie", price: "$55", description: "Bright and cozy hoodie.", category: "Clothing"),
    Product(name: "Sunglasses", imageName: "sunglasses", price: "$39", description: "Retro UV protection.", category: "Accessories"),
    Product(name: "Joggers", imageName: "joggers", price: "$45", description: "Bold, breathable joggers.", category: "Clothing"),
    Product(name: "Laptop Sleeve", imageName: "sleeve", price: "$29", description: "Vibrant protective sleeve.", category: "Accessories"),
    Product(name: "Speaker", imageName: "speaker", price: "$69", description: "Loud, colorful, portable.", category: "Electronics")
]

let categories = ["All", "Clothing", "Shoes", "Accessories", "Electronics"]

// MARK: - Managers
class CartManager: ObservableObject {
    @Published var cartItems: [Product] = []
    func addToCart(_ product: Product) {
        if !cartItems.contains(where: { $0.id == product.id }) {
            cartItems.append(product)
        }
    }
    func clearCart() {
        cartItems.removeAll()
    }
}

class FavoritesManager: ObservableObject {
    @Published var favorites: Set<UUID> = []
    func toggleFavorite(_ product: Product) {
        if favorites.contains(product.id) {
            favorites.remove(product.id)
        } else {
            favorites.insert(product.id)
        }
    }
    func isFavorite(_ product: Product) -> Bool {
        favorites.contains(product.id)
    }
}

class AddressManager: ObservableObject {
    @Published var savedAddresses: [String] = [
        "123 Main Street, New York",
        "45 Hill Road, San Francisco"
    ]
    func addAddress(_ address: String) {
        savedAddresses.append(address)
    }
}

class PaymentManager: ObservableObject {
    @Published var savedCards: [String] = ["Visa **** 1234"]
    func addCard(_ card: String) {
        savedCards.append(card)
    }
}

// MARK: - Main Tab View with Dark Mode Support
struct ContentView: View {
    @StateObject private var cartManager = CartManager()
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var addressManager = AddressManager()
    @StateObject private var paymentManager = PaymentManager()

    @AppStorage("isDarkMode") private var isDarkMode = false  // Dark mode preference

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(cartManager)
                .environmentObject(favoritesManager)
                .tabItem { Label("Home", systemImage: "house.fill") }

            ExploreView()
                .environmentObject(cartManager)
                .environmentObject(favoritesManager)
                .tabItem { Label("Explore", systemImage: "magnifyingglass") }

            FavoritesView()
                .environmentObject(favoritesManager)
                .tabItem { Label("Favorites", systemImage: "heart.fill") }

            CartView()
                .environmentObject(cartManager)
                .environmentObject(addressManager)
                .environmentObject(paymentManager)
                .tabItem { Label("Cart", systemImage: "cart.fill") }

            ProfileView()
                .environmentObject(addressManager)
                .environmentObject(paymentManager)
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .accentColor(.pink)
        .preferredColorScheme(isDarkMode ? .dark : .light)  // Apply dark mode globally
    }
}

// MARK: - Home View
struct HomeView: View {
    @State private var selectedCategory = "All"
    @State private var searchText = ""
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var favoritesManager: FavoritesManager

    var filteredProducts: [Product] {
        var products = selectedCategory == "All" ? sampleProducts : sampleProducts.filter { $0.category == selectedCategory }
        if !searchText.isEmpty {
            products = products.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
        return products
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack {
                        LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(height: 160)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Welcome Back 👋")
                                .font(.title2).bold().foregroundColor(.white)
                            Text("Discover trending products and amazing deals!")
                                .font(.subheadline).foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                Button {
                                    withAnimation {
                                        selectedCategory = category
                                    }
                                } label: {
                                    Text(category)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color.pink.opacity(0.8) : Color.gray.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Text("🔥 Featured")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(sampleProducts.prefix(3)) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
                                    VStack(alignment: .leading) {
                                        Image(product.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 160, height: 120)
                                            .cornerRadius(12)
                                            .clipped()
                                        Text(product.name)
                                            .font(.headline)
                                        Text(product.price)
                                            .foregroundColor(.pink)
                                            .bold()
                                    }
                                    .frame(width: 160)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(radius: 4)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Text("🛍️ All Products")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)

                    LazyVStack(spacing: 16) {
                        ForEach(filteredProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductCardView(product: product)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(
                LinearGradient(colors: [.pink.opacity(0.05), .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("Home")
            .searchable(text: $searchText, prompt: "Search products...")
        }
    }
}

// MARK: - Product Card View
struct ProductCardView: View {
    let product: Product
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        HStack {
            Image(product.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .cornerRadius(12)

            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text(product.price)
                    .foregroundColor(.blue)
                    .bold()
            }
            Spacer()
            Button {
                favoritesManager.toggleFavorite(product)
            } label: {
                Image(systemName: favoritesManager.isFavorite(product) ? "heart.fill" : "heart")
                    .foregroundColor(favoritesManager.isFavorite(product) ? .red : .gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .purple.opacity(0.1), radius: 5)
    }
}

// MARK: - Product Detail View with Dark Mode & Interactive Add to Cart
struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showCheckoutAlert = false
    @State private var rating: Int = 0
    @State private var isAddCartPressed = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(product.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .cornerRadius(20)
                    .padding()
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), radius: 10)

                Text(product.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color.primary)

                Text(product.description)
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)

                Text(product.price)
                    .font(.title2)
                    .foregroundColor(Color.pink)
                    .bold()

                VStack {
                    Text("Rate this product")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.title2)
                                .onTapGesture {
                                    rating = star
                                }
                                .padding(4)
                        }
                    }
                }
                .padding()

                HStack(spacing: 20) {
                    Button {
                        favoritesManager.toggleFavorite(product)
                    } label: {
                        Label("Favorite", systemImage: favoritesManager.isFavorite(product) ? "heart.fill" : "heart")
                            .padding()
                            .background(colorScheme == .dark ? Color.pink.opacity(0.6) : Color.pink.opacity(0.2))
                            .foregroundColor(Color.pink)
                            .cornerRadius(10)
                    }

                    Button {
                        cartManager.addToCart(product)
                    } label: {
                        Label("Add to Cart", systemImage: "cart.badge.plus")
                            .padding()
                            .background(colorScheme == .dark ? Color.blue.opacity(0.6) : Color.blue.opacity(0.2))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.blue)
                            .cornerRadius(10)
                            .scaleEffect(isAddCartPressed ? 0.95 : 1.0)
                            .opacity(isAddCartPressed ? 0.7 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: isAddCartPressed)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isAddCartPressed = true }
                            .onEnded { _ in isAddCartPressed = false }
                    )
                }

                Button {
                    cartManager.addToCart(product)
                    showCheckoutAlert = true
                } label: {
                    Text("Buy Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: colorScheme == .dark ? [.pink, .purple] : [.pink.opacity(0.8), .purple.opacity(0.8)],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .alert(isPresented: $showCheckoutAlert) {
                    Alert(title: Text("Checkout"),
                          message: Text("Added \(product.name) to cart!"),
                          dismissButton: .default(Text("OK")))
                }

                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color(UIColor.systemBackground))
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Explore View
struct ExploreView: View {
    @State private var searchText = ""
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var favoritesManager: FavoritesManager

    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return sampleProducts
        } else {
            return sampleProducts.filter {
                $0.name.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationView {
            List(filteredProducts) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    HStack {
                        Image(product.imageName)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                        VStack(alignment: .leading) {
                            Text(product.name)
                            Text(product.price).foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search all products...")
        }
    }
}

// MARK: - Cart View with Buy All and Total
struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var addressManager: AddressManager
    @EnvironmentObject var paymentManager: PaymentManager
    @State private var goCheckout = false

    var totalAmount: String {
        let total = cartManager.cartItems.reduce(0) { $0 + (Double($1.price.dropFirst()) ?? 0) }
        return "$\(String(format: "%.2f", total))"
    }

    var body: some View {
        NavigationView {
            VStack {
                if cartManager.cartItems.isEmpty {
                    Text("Your cart is empty 🛒")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List(cartManager.cartItems) { product in
                        HStack {
                            Image(product.imageName)
                                .resizable()
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text(product.name)
                                Text(product.price).foregroundColor(.gray)
                            }
                        }
                    }
                    HStack {
                        Text("Total").font(.headline)
                        Spacer()
                        Text(totalAmount)
                            .bold()
                            .foregroundColor(.pink)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .shadow(radius: 2)

                    Button {
                        goCheckout = true
                    } label: {
                        Text("Buy All")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                    .sheet(isPresented: $goCheckout) {
                        CheckoutView(total: totalAmount)
                            .environmentObject(addressManager)
                            .environmentObject(paymentManager)
                    }
                }
            }
            .navigationTitle("Cart")
            .background(Color(UIColor.systemBackground))
        }
    }
}

// MARK: - Checkout Flow
struct CheckoutView: View {
    @EnvironmentObject var addressManager: AddressManager
    @EnvironmentObject var paymentManager: PaymentManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedAddress: String?
    @State private var selectedPayment: String?
    @State private var showSuccess = false

    let total: String

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Address")) {
                    ForEach(addressManager.savedAddresses, id: \.self) { addr in
                        HStack {
                            Text(addr)
                            Spacer()
                            if selectedAddress == addr {
                                Image(systemName: "checkmark").foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedAddress = addr
                        }
                    }
                }
                Section(header: Text("Select Payment Method")) {
                    ForEach(paymentManager.savedCards, id: \.self) { card in
                        HStack {
                            Text(card)
                            Spacer()
                            if selectedPayment == card {
                                Image(systemName: "checkmark").foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPayment = card
                        }
                    }
                }
                Section {
                    Button("Place Order (\(total))") {
                        if selectedAddress != nil && selectedPayment != nil {
                            showSuccess = true
                        }
                    }
                    .disabled(selectedAddress == nil || selectedPayment == nil)
                }
            }
            .navigationTitle("Checkout")
            .alert(isPresented: $showSuccess) {
                Alert(title: Text("🎉 Order Placed"),
                      message: Text("Your order will be delivered soon!"),
                      dismissButton: .default(Text("OK")) {
                          presentationMode.wrappedValue.dismiss()
                      })
            }
        }
    }
}

// MARK: - Favorites View
struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    var favoriteProducts: [Product] {
        sampleProducts.filter { favoritesManager.favorites.contains($0.id) }
    }
    var body: some View {
        NavigationView {
            List(favoriteProducts) { product in
                HStack {
                    Image(product.imageName)
                        .resizable()
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text(product.name)
                        Text(product.price).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

// MARK: - Profile View with Dark Mode Toggle, Address & Payment Management
struct ProfileView: View {
    @EnvironmentObject var addressManager: AddressManager
    @EnvironmentObject var paymentManager: PaymentManager

    @AppStorage("isDarkMode") private var isDarkMode = false

    @State private var showAddAddressSheet = false
    @State private var newAddress = ""

    @State private var showAddCardSheet = false
    @State private var newCard = ""

    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.pink)
                        Text("Hello, Shopper!")
                            .font(.title2)
                            .bold()
                        Text("shopper@email.com")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }

                Section(header: Text("Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                    }
                }

                Section(header: Text("Addresses")) {
                    ForEach(addressManager.savedAddresses, id: \.self) { addr in
                        Text(addr)
                    }
                    Button("➕ Add New Address") {
                        showAddAddressSheet = true
                    }
                }
                Section(header: Text("Payment Methods")) {
                    ForEach(paymentManager.savedCards, id: \.self) { card in
                        Text(card)
                    }
                    Button("➕ Add New Card") {
                        showAddCardSheet = true
                    }
                }
                Section(header: Text("Account")) {
                    NavigationLink("Order History") {
                        OrderHistoryView()
                    }
                    NavigationLink("Refund Status") {
                        Text("Refunds coming soon")
                    }
                    NavigationLink("Track Orders") {
                        Text("Tracking coming soon")
                    }
                }
                Section(header: Text("Support")) {
                    NavigationLink("Customer Support") {
                        CustomerSupportView()
                    }
                    Button(role: .destructive) {
                        print("User logged out")
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showAddAddressSheet) {
                VStack(spacing: 20) {
                    Text("Add New Address").font(.headline)
                    TextField("Enter address", text: $newAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Save Address") {
                        if !newAddress.isEmpty {
                            addressManager.addAddress(newAddress)
                            newAddress = ""
                            showAddAddressSheet = false
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Spacer()
                }
                .padding()
            }
            .sheet(isPresented: $showAddCardSheet) {
                VStack(spacing: 20) {
                    Text("Add New Card").font(.headline)
                    TextField("Enter card details (e.g., Visa **** 1234)", text: $newCard)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Save Card") {
                        if !newCard.isEmpty {
                            paymentManager.addCard(newCard)
                            newCard = ""
                            showAddCardSheet = false
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Spacer()
                }
                .padding()
            }
        }
    }
}

// MARK: - Order History View
struct OrderHistoryView: View {
    var body: some View {
        List {
            Text("Order #1001 - Delivered")
            Text("Order #1002 - Pending")
            Text("Order #1003 - Shipped")
        }
        .navigationTitle("Order History")
    }
}

// MARK: - Customer Support View
struct CustomerSupportView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Contact Support").font(.headline)
            Text("support@shopapp.com").foregroundColor(.blue)
            Text("📞 +1 123 456 789").foregroundColor(.blue)
            Spacer()
        }
        .padding()
        .navigationTitle("Customer Support")
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
