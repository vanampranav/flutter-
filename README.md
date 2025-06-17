# EleFit Mobile App

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
