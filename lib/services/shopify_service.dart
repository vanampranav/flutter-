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
    // First create a cart
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

    try {
      final graphQLClient = await client;
      
      // Debug log the items
      print('Creating cart with items: $items');

      // Create the cart first
      final createCartResult = await graphQLClient.mutate(
        MutationOptions(
          document: gql(createCartMutation),
        ),
      );

      if (createCartResult.hasException) {
        print('Error creating cart: ${createCartResult.exception}');
        return null;
      }

      final cartId = createCartResult.data?['cartCreate']['cart']['id'] as String?;
      if (cartId == null) {
        print('No cart ID returned');
        return null;
      }

      // Now add lines to the cart
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
                        title
                        price {
                          amount
                          currencyCode
                        }
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

      // Format the line items
      final lines = items.map((item) {
        String variantId = item['variantId'];
        if (!variantId.startsWith('gid://')) {
          variantId = 'gid://shopify/ProductVariant/$variantId';
        }
        return {
          'merchandiseId': variantId,
          'quantity': item['quantity'],
        };
      }).toList();

      print('Adding lines to cart: $lines');

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

      // Get the checkout URL from the cart
      final checkoutUrl = addLinesResult.data?['cartLinesAdd']['cart']['checkoutUrl'] as String?;
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

  Future<Map<String, dynamic>?> getProducts() async {
    const String query = '''
      query {
        products(first: 20) {
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
        fetchPolicy: FetchPolicy.networkOnly,
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