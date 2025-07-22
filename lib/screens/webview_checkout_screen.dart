import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class WebViewCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;

  const WebViewCheckoutScreen({
    Key? key,
    required this.checkoutUrl,
  }) : super(key: key);

  @override
  State<WebViewCheckoutScreen> createState() => _WebViewCheckoutScreenState();
}

class _WebViewCheckoutScreenState extends State<WebViewCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // For web platform, open in a new tab
      _openInNewTab();
    } else {
      // For mobile platforms, use WebView
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
              });
              if (url.contains('/thank_you') || url.contains('/orders/')) {
                // Order completed successfully
                context.read<CartModel>().clearCart();
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order placed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              // Handle external links (like payment gateways) that need to open in browser
              if (request.url.contains('tel:') || 
                  request.url.contains('mailto:') ||
                  request.url.contains('sms:') ||
                  request.url.contains('maps:')) {
                launchUrl(Uri.parse(request.url));
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.checkoutUrl));
    }
  }

  Future<void> _openInNewTab() async {
    final Uri url = Uri.parse(widget.checkoutUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      // Since we can't track the completion in a new tab,
      // we'll show a dialog to ask if the order was completed
      if (mounted) {
        final completed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Order Status'),
            content: const Text('Did you complete your order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('NO'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('YES'),
              ),
            ],
          ),
        );

        if (completed == true) {
          context.read<CartModel>().clearCart();
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          Navigator.of(context).pop(false);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open checkout page'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave Checkout?'),
            content: const Text('Are you sure you want to leave the checkout process? Your progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('STAY'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('LEAVE'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldClose = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Leave Checkout?'),
                  content: const Text('Are you sure you want to leave the checkout process? Your progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('STAY'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('LEAVE'),
                    ),
                  ],
                ),
              );
              if (shouldClose == true) {
                Navigator.of(context).pop(false);
              }
            },
          ),
          actions: [
            if (_currentUrl.isNotEmpty && !_currentUrl.contains(widget.checkoutUrl))
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _controller.reload();
                },
              ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(height: 16),
                      const Text('Loading secure checkout...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
