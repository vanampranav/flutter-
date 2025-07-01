import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopifyService {
  static const String _storeUrl = 'theelefit.com';
  static const String _storefrontAccessToken = '3476fc91bc4860c5b02aea3983766cb1';
  static const String _apiKey = '307e11a2d080bd92db478241bc9d20dc';
  static const String _apiSecretKey = '21eb801073c48a83cd3dc7093077d087';
  
  late GraphQLClient _client;
  late SharedPreferences _prefs;

  static final ShopifyService _instance = ShopifyService._internal();

  factory ShopifyService() {
    return _instance;
  }

  ShopifyService._internal() {
    _initializeClient();
  }

  void _initializeClient() {
    final HttpLink httpLink = HttpLink(
      'https://$_storeUrl/api/2024-01/graphql',
    );

    final AuthLink authLink = AuthLink(
      headerKey: 'X-Shopify-Storefront-Access-Token',
      getToken: () async => _storefrontAccessToken,
    );

    final Link link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isLoggedIn() async {
    final token = _prefs.getString('customerAccessToken');
    return token != null;
  }

  Future<Map<String, dynamic>?> getCurrentUser(String accessToken) async {
    const String query = '''
      query {
        customer {
          id
          firstName
          lastName
          email
          orders(first: 10) {
            edges {
              node {
                id
                orderNumber
                totalPrice
                processedAt
                statusUrl
                lineItems(first: 5) {
                  edges {
                    node {
                      title
                      quantity
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
      final QueryOptions options = QueryOptions(
        document: gql(query),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('Error fetching user data: ${result.exception}');
        return null;
      }

      return result.data?['customer'];
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCustomerOrders() async {
    final customerAccessToken = _prefs.getString('customerAccessToken');
    if (customerAccessToken == null) return null;

    const query = '''
      query {
        customer(customerAccessToken: "\$customerAccessToken") {
          orders(first: 10) {
            edges {
              node {
                id
                orderNumber
                processedAt
                totalPrice
                statusUrl
                lineItems(first: 5) {
                  edges {
                    node {
                      title
                      quantity
                      variant {
                        price
                        image {
                          url
                        }
                      }
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
      final result = await _client.query(QueryOptions(
        document: gql(query),
        variables: {'customerAccessToken': customerAccessToken},
      ));

      if (result.hasException) {
        print('Error fetching orders: ${result.exception}');
        return null;
      }

      final orders = result.data?['customer']?['orders']?['edges']
          ?.map((edge) => edge['node'])
          ?.toList();

      return List<Map<String, dynamic>>.from(orders ?? []);
    } catch (e) {
      print('Error fetching orders: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> addToCart(String variantId, int quantity) async {
    const String mutation = '''
      mutation checkoutCreate(\$input: CheckoutCreateInput!) {
        checkoutCreate(input: \$input) {
          checkout {
            id
            webUrl
            totalPrice {
              amount
              currencyCode
            }
            lineItems(first: 5) {
              edges {
                node {
                  title
                  quantity
                  variant {
                    price {
                      amount
                      currencyCode
                    }
                  }
                }
              }
            }
          }
          checkoutUserErrors {
            code
            field
            message
          }
        }
      }
    ''';

    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'lineItems': [
                {
                  'variantId': variantId,
                  'quantity': quantity,
                }
              ],
            },
          },
        ),
      );

      if (result.hasException) {
        print('Error creating checkout: ${result.exception}');
        return null;
      }

      return result.data;
    } catch (e) {
      print('Exception while creating checkout: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProductsByCategory(String category) async {
    const String query = '''
      query GetProductsByCollection(\$query: String!) {
        products(first: 20, query: \$query) {
          edges {
            node {
              id
              title
              description
              priceRange {
                minVariantPrice {
                  amount
                  currencyCode
                }
              }
              images(first: 1) {
                edges {
                  node {
                    url
                  }
                }
              }
              variants(first: 5) {
                edges {
                  node {
                    id
                    title
                    price {
                      amount
                      currencyCode
                    }
                  }
                }
              }
              tags
            }
          }
        }
      }
    ''';

    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: {
            'query': 'tag:$category',
          },
        ),
      );

      if (result.hasException) {
        print('Error fetching products by category: ${result.exception}');
        return null;
      }

      return result.data;
    } catch (e) {
      print('Exception while fetching products by category: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> searchProducts(String searchTerm) async {
    const String query = '''
      query SearchProducts(\$query: String!) {
        products(first: 20, query: \$query) {
          edges {
            node {
              id
              title
              description
              priceRange {
                minVariantPrice {
                  amount
                  currencyCode
                }
              }
              images(first: 1) {
                edges {
                  node {
                    url
                  }
                }
              }
            }
          }
        }
      }
    ''';

    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: {
            'query': searchTerm,
          },
        ),
      );

      if (result.hasException) {
        print('Error searching products: ${result.exception}');
        return null;
      }

      return result.data;
    } catch (e) {
      print('Exception while searching products: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProducts() async {
    const String query = '''
      query GetProducts {
        products(first: 20) {
          edges {
            node {
              id
              title
              description
              priceRange {
                minVariantPrice {
                  amount
                  currencyCode
                }
              }
              images(first: 1) {
                edges {
                  node {
                    url
                  }
                }
              }
              variants(first: 5) {
                edges {
                  node {
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
      }
    ''';

    try {
      final QueryResult result = await _client.query(
        QueryOptions(document: gql(query)),
      );

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

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        print('Error creating customer: ${result.exception}');
        return null;
      }

      return result.data;
    } catch (e) {
      print('Error creating customer: $e');
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
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
          },
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        print('Error creating access token: ${result.exception}');
        return null;
      }

      return result.data;
    } catch (e) {
      print('Error creating access token: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _prefs.remove('customerAccessToken');
  }
} 