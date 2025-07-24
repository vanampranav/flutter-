import 'package:graphql/client.dart';
import 'dart:async';

class ShopifyService {
  static const String _storeUrl = 'theelefit.com';
  static const String _storefrontAccessToken = '3476fc91bc4860c5b02aea3983766cb1';
  static const String _apiKey = '307e11a2d080bd92db478241bc9d20dc';
  static const String _apiSecretKey = '21eb801073c48a83cd3dc7093077d087';
  
  GraphQLClient? _client;
  bool _isInitialized = false;

  ShopifyService() {
    initialize();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    final HttpLink httpLink = HttpLink(
      'https://$_storeUrl/api/2024-01/graphql',
      defaultHeaders: {
        'X-Shopify-Storefront-Access-Token': _storefrontAccessToken,
        'Content-Type': 'application/json',
      },
    );

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.noCache,
        ),
        mutate: Policies(
          fetch: FetchPolicy.noCache,
        ),
      ),
    );

    _isInitialized = true;
  }

  Future<GraphQLClient> get client async {
    if (!_isInitialized) {
      await initialize();
    }
    return _client!;
  }

  Future<String?> createCheckout(List<Map<String, dynamic>> items) async {
    try {
      final graphQLClient = await client;
      
      // Create cart mutation
      const String createCartMutation = '''
        mutation cartCreate {
          cartCreate {
            cart {
              id
              checkoutUrl
            }
            userErrors {
              field
              message
            }
          }
        }
      ''';

      print('Creating cart with items: $items');

      // Create cart
      final createCartResult = await graphQLClient.mutate(
        MutationOptions(
          document: gql(createCartMutation),
        ),
      );

      if (createCartResult.hasException) {
        print('Error creating cart: ${createCartResult.exception}');
        return null;
      }

      final cartData = createCartResult.data?['cartCreate'];
      if (cartData == null || cartData['cart'] == null) {
        print('Invalid cart data received');
        return null;
      }

      final cartId = cartData['cart']['id'] as String;
      
      // Add lines mutation
      const String addLinesMutation = '''
        mutation cartLinesAdd(\$cartId: ID!, \$lines: [CartLineInput!]!) {
          cartLinesAdd(cartId: \$cartId, lines: \$lines) {
            cart {
              id
              checkoutUrl
              lines(first: 10) {
                edges {
                  node {
                    id
                    quantity
                    merchandise {
                      ... on ProductVariant {
                        id
                      }
                    }
                  }
                }
              }
            }
            userErrors {
              field
              message
            }
          }
        }
      ''';

      // Format line items - ensure proper variant ID format
      final lines = items.map((item) {
        String variantId = item['variantId'].toString();
        
        // If the ID doesn't have the proper Shopify format, add it
        if (!variantId.startsWith('gid://shopify/ProductVariant/')) {
          // Remove any existing Shopify prefix if present
          variantId = variantId.replaceAll('gid://shopify/ProductVariant/', '');
          variantId = variantId.replaceAll('gid://shopify/Product/', '');
          // Add the correct prefix
          variantId = 'gid://shopify/ProductVariant/$variantId';
        }
        
        return {
          'merchandiseId': variantId,
          'quantity': item['quantity'],
        };
      }).toList();

      print('Adding lines to cart: $lines');

      // Add items to cart
      final addLinesResult = await graphQLClient.mutate(
        MutationOptions(
          document: gql(addLinesMutation),
          variables: {
            'cartId': cartId,
            'lines': lines,
          },
        ),
      );

      if (addLinesResult.hasException) {
        print('Error adding lines to cart: ${addLinesResult.exception}');
        return null;
      }

      final addLinesData = addLinesResult.data?['cartLinesAdd'];
      if (addLinesData == null) {
        print('Invalid response data received');
        print('Response data: ${addLinesResult.data}');
        return null;
      }

      if (addLinesData['userErrors'] != null && 
          (addLinesData['userErrors'] as List).isNotEmpty) {
        print('Cart line errors: ${addLinesData['userErrors']}');
        return null;
      }

      if (addLinesData['cart'] == null) {
        print('Invalid cart data received after adding lines');
        print('Response data: ${addLinesResult.data}');
        return null;
      }

      final checkoutUrl = addLinesData['cart']['checkoutUrl'] as String?;
      if (checkoutUrl == null) {
        print('No checkout URL returned');
        return null;
      }

      print('Created cart and got checkout URL: $checkoutUrl');
      return checkoutUrl;
    } catch (e, stackTrace) {
      print('Exception while creating cart: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<bool> testConnection() async {
    const String testQuery = '''
      query {
        shop {
          name
          primaryDomain {
            url
          }
        }
      }
    ''';

    try {
      final graphQLClient = await client;
      final result = await graphQLClient.query(
        QueryOptions(
          document: gql(testQuery),
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        print('API Test Error: ${result.exception}');
        return false;
      }

      print('API Test Success: ${result.data}');
      return true;
    } catch (e) {
      print('API Test Exception: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProducts({int first = 20, String? collectionId}) async {
    String query = '''
      query {
        products(first: $first${collectionId != null ? ', query: "collection_id:$collectionId"' : ''}) {
          edges {
            node {
              id
              title
              handle
              description
              priceRange {
                minVariantPrice {
                  amount
                  currencyCode
                }
              }
              images(first: 5) {
                edges {
                  node {
                    url
                    altText
                  }
                }
              }
              variants(first: 10) {
                edges {
                  node {
                    id
                    title
                    price {
                      amount
                      currencyCode
                    }
                    availableForSale
                    selectedOptions {
                      name
                      value
                    }
                  }
                }
              }
            }
          }
        }
      }
    ''';

    try {
      final graphQLClient = await client;
      final QueryOptions options = QueryOptions(
        document: gql(query),
        fetchPolicy: FetchPolicy.noCache,
      );

      final QueryResult result = await graphQLClient.query(options);

      if (result.hasException) {
        print('Error fetching products: ${result.exception}');
        return null;
      }

      return result.data;
    } catch (e) {
      print('Exception while fetching products: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> customerAccessTokenCreate({
    required String email,
    required String password,
  }) async {
    const String mutation = '''
      mutation customerAccessTokenCreate(\$input: CustomerAccessTokenCreateInput!) {
        customerAccessTokenCreate(input: \$input) {
          customerAccessToken {
            accessToken
            expiresAt
          }
          customerUserErrors {
            code
            field
            message
          }
        }
      }
    ''';

    try {
      final graphQLClient = await client;
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
          },
        },
      );

      final QueryResult result = await graphQLClient.mutate(options);

      if (result.hasException) {
        print('Error creating access token: ${result.exception}');
        return null;
      }

      return result.data;
    } catch (e) {
      print('Exception while creating access token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createCustomer({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    const String mutation = '''
      mutation customerCreate(\$input: CustomerCreateInput!) {
        customerCreate(input: \$input) {
          customer {
            id
            email
            firstName
            lastName
          }
          customerUserErrors {
            code
            field
            message
          }
        }
      }
    ''';

    try {
      final graphQLClient = await client;
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
            'firstName': firstName,
            'lastName': lastName,
          },
        },
      );

      final QueryResult result = await graphQLClient.mutate(options);

      if (result.hasException) {
        print('Error creating customer: ${result.exception}');
        return null;
      }

      return result.data;
    } catch (e) {
      print('Exception while creating customer: $e');
      return null;
    }
  }
} 