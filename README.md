# EleFit Mobile App

## Project Overview

EleFit is a modern, cross-platform Flutter application designed for the EleFit Shopify store, combining fitness and e-commerce features. The app enables users to browse and purchase fitness products, manage their cart and wishlist, access workout and blog content, and interact with a personalized profile/dashboard. The UI/UX is optimized for mobile, with a focus on a fitness-inspired, visually appealing, and user-friendly experience.

## Technology Stack

- **Flutter**: Main framework for building cross-platform mobile apps (Android, iOS, web, desktop)
- **Dart**: Programming language for Flutter
- **Provider**: State management for cart, wishlist, theme, and authentication
- **Shopify Storefront API**: Backend for product, customer, and order data
- **shared_preferences**: Local storage for authentication tokens, cart, wishlist, and theme preference
- **google_fonts**: Custom font integration
- **flutter_carousel_widget**: Product and image carousels
- **http**: API requests
- **cached_network_image**: Efficient image loading (if used)

## Architecture & Approach

- **State Management**: Uses Provider for modular, reactive state (cart, wishlist, theme, fitness data)
- **Authentication**: Shopify customer accounts, with persistent login and secure token storage
- **Navigation**: Bottom navigation bar with animated transitions, page controller, and named routes
- **UI/UX**: Custom themes (light/dark), fitness-inspired visuals, responsive layouts, and modern animations
- **E-commerce**: Real-time product data from Shopify, cart and wishlist with persistent storage, and product details with image carousel
- **Fitness & Content**: Workout and blog sections, with navigation to detailed content
- **Profile/Dashboard**: User data, order history, theme toggle, and sign-in/out flows
- **Error Handling**: User-friendly error and loading states throughout

## Screens

- **HomeScreen**: Main landing page with hero carousel, featured/best-seller products, categories, blog, and newsletter.
- **ShopScreen**: Product grid with categories, search, sale badges, and add-to-cart/wishlist actions.
- **ProductDetailsScreen**: Detailed product view with image carousel, size/quantity selector, add to cart, and wishlist.
- **CartScreen**: Shopping cart with item management, quantity adjustment, and checkout summary.
- **WishlistScreen**: Saved products with add-to-cart and remove options.
- **AuthScreen**: Login and registration with Shopify customer accounts.
- **ProfileScreen**: User dashboard with profile info, order history, theme toggle, and sign-out.
- **WorkoutScreen**: Fitness/workout content and "Ask Our Coach" section.
- **BlogScreen**: Blog post details and media content.

## Services

- **ShopifyService**: Handles all Shopify Storefront API requests (products, authentication, customer data, etc.).
- **ThemeProvider**: Manages app theme (light/dark) and persists user preference.
- **CartModel**: State management for cart items, totals, and persistence.
- **WishlistModel**: State management for wishlist items and persistence.
- **FitnessModel**: State for fitness/workout-related data.

---

A Flutter mobile application for the EleFit Shopify store. This app allows customers to browse products, add items to cart, and make purchases directly from their mobile devices.

## Features

- Browse fitness products
- View detailed product information
- Add products to cart
- Manage shopping cart
- Secure checkout process
- Beautiful and responsive UI

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Android Studio or VS Code with Flutter extension
- A physical device or emulator for testing

### Installation

1. Clone this repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

### Configuration

The app uses the following Shopify credentials:
- Store URL: theelefit.com
- Storefront Access Token: 3476fc91bc4860c5b02aea3983766cb1

## Dependencies

- shopify_flutter: For Shopify API integration
- provider: For state management
- cached_network_image: For efficient image loading
- http: For API requests
- shared_preferences: For local storage

## Project Structure

```
lib/
  ├── models/
  │   └── cart_model.dart
  ├── screens/
  │   ├── cart_screen.dart
  │   └── product_details_screen.dart
  └── main.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License.
