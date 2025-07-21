class AppConstants {
  static const String appName = 'EleFit';
  static const String appVersion = '1.0.0';
  static const String placeholderImage = 'https://placehold.co/400x600/1A1A1A/FFFFFF.png?text=EleFit';
  static const String productPlaceholder = 'https://placehold.co/400x400/1A1A1A/FFFFFF.png?text=Product';
  static const String blogPlaceholder = 'https://placehold.co/400x400/1A1A1A/FFFFFF.png?text=Blog';
  
  // Shopify Store Constants
  static const String shopifyStoreDomain = 'theelefit.com';
  static const String shopifyStorefrontAccessToken = '3476fc91bc4860c5b02aea3983766cb1';
  
  // API Endpoints
  static const String baseUrl = 'https://$shopifyStoreDomain/api/2024-01';
  static const String storefrontUrl = 'https://$shopifyStoreDomain/api/2024-01/graphql';
  
  // Cache Keys
  static const String authTokenKey = 'auth_token';
  static const String cartKey = 'cart';
  static const String wishlistKey = 'wishlist';
  static const String themeKey = 'theme';
} 