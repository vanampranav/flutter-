import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<Map<String, dynamic>?> getCurrentCustomer(String accessToken) async {
    const query = '''
      query {
        customer {
          id
          firstName
          lastName
          email
          phone
          defaultAddress {
            id
            address1
            address2
            city
            province
            country
            zip
          }
          orders(first: 5) {
            edges {
              node {
                id
                orderNumber
                processedAt
                totalPrice
                currencyCode
                statusUrl
              }
            }
          }
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://$_storeUrl/api/2024-01/graphql.json'),
        headers: {
          'X-Shopify-Storefront-Access-Token': _storefrontAccessToken,
          'Content-Type': 'application/json',
          'X-Shopify-Customer-Access-Token': accessToken,
        },
        body: json.encode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['customer'] != null) {
          final customer = data['data']['customer'];
          
          // Transform orders data
          final orders = customer['orders']['edges']
              .map((edge) => edge['node'])
              .toList();

          return {
            'id': customer['id'],
            'firstName': customer['firstName'],
            'lastName': customer['lastName'],
            'email': customer['email'],
            'phone': customer['phone'],
            'defaultAddress': customer['defaultAddress'],
            'orders': orders,
            'wishlist': [], // Implement wishlist functionality
            'reviews': [], // Implement reviews functionality
          };
        }
      }
      return null;
    } catch (e) {
      print('Error fetching customer data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBlogs() async {
    const String query = '''
      query GetBlogs {
        blogs(first: 10) {
          edges {
            node {
              id
              title
              articles(first: 10, sortKey: PUBLISHED_AT, reverse: true) {
                edges {
                  node {
                    id
                    title
                    content
                    excerpt
                    publishedAt
                    image {
                      url
                    }
                    author {
                      name
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
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('Error fetching blogs: ${result.exception}');
        return null;
      }

      return result.data;
    } catch (e) {
      print('Exception while fetching blogs: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createCheckout(List<Map<String, dynamic>> items) async {
    const String mutation = '''
      mutation checkoutCreate(\$input: CheckoutCreateInput!) {
        checkoutCreate(input: \$input) {
          checkout {
            id
            webUrl
            totalPriceV2 {
              amount
              currencyCode
            }
            lineItems(first: 250) {
              edges {
                node {
                  id
                  title
                  quantity
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
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'lineItems': items.map((item) => {
              'variantId': item['variantId'],
              'quantity': item['quantity'],
            }).toList(),
          },
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        print('Error creating checkout: ${result.exception}');
        return null;
      }

      return result.data?['checkoutCreate']?['checkout'];
    } catch (e) {
      print('Exception while creating checkout: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateCheckout({
    required String checkoutId,
    required String email,
    required Map<String, dynamic> shippingAddress,
  }) async {
    const String mutation = '''
      mutation checkoutEmailUpdateV2(\$checkoutId: ID!, \$email: String!) {
        checkoutEmailUpdateV2(checkoutId: \$checkoutId, email: \$email) {
          checkout {
            id
            email
          }
          checkoutUserErrors {
            code
            field
            message
          }
        }
      }
    ''';

    const String addressMutation = '''
      mutation checkoutShippingAddressUpdateV2(\$checkoutId: ID!, \$shippingAddress: MailingAddressInput!) {
        checkoutShippingAddressUpdateV2(checkoutId: \$checkoutId, shippingAddress: \$shippingAddress) {
          checkout {
            id
            shippingAddress {
              address1
              address2
              city
              country
              firstName
              lastName
              phone
              province
              zip
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
      // Update email
      final emailResult = await _client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'checkoutId': checkoutId,
            'email': email,
          },
        ),
      );

      if (emailResult.hasException) {
        print('Error updating checkout email: ${emailResult.exception}');
        return null;
      }

      // Update shipping address
      final addressResult = await _client.mutate(
        MutationOptions(
          document: gql(addressMutation),
          variables: {
            'checkoutId': checkoutId,
            'shippingAddress': shippingAddress,
          },
        ),
      );

      if (addressResult.hasException) {
        print('Error updating shipping address: ${addressResult.exception}');
        return null;
      }

      return addressResult.data?['checkoutShippingAddressUpdateV2']?['checkout'];
    } catch (e) {
      print('Exception while updating checkout: $e');
      return null;
    }
  }

  Future<String?> completeCheckoutWithCreditCard({
    required String checkoutId,
    required Map<String, dynamic> creditCard,
    required Map<String, dynamic> billingAddress,
  }) async {
    const String mutation = '''
      mutation checkoutCompleteWithCreditCardV2(
        \$checkoutId: ID!,
        \$payment: CreditCardPaymentInputV2!
      ) {
        checkoutCompleteWithCreditCardV2(
          checkoutId: \$checkoutId,
          payment: \$payment
        ) {
          checkout {
            id
            completedAt
            order {
              id
              processedAt
              orderNumber
              statusUrl
            }
          }
          checkoutUserErrors {
            code
            field
            message
          }
          payment {
            id
            errorMessage
          }
        }
      }
    ''';

    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'checkoutId': checkoutId,
            'payment': {
              'paymentAmount': {
                'amount': creditCard['amount'],
                'currencyCode': 'USD',
              },
              'idempotencyKey': DateTime.now().millisecondsSinceEpoch.toString(),
              'billingAddress': billingAddress,
              'vaultId': creditCard['vaultId'], // Token from payment provider
            },
          },
        ),
      );

      if (result.hasException) {
        print('Error completing checkout: ${result.exception}');
        return null;
      }

      final orderUrl = result.data?['checkoutCompleteWithCreditCardV2']?['checkout']?['order']?['statusUrl'];
      return orderUrl;
    } catch (e) {
      print('Exception while completing checkout: $e');
      return null;
    }
  }
} 