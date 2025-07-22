import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationService {
  static const String _ipApiUrl = 'http://ip-api.com/json';

  String? _countryCode;
  String? _currencyCode;
  
  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // For web testing, default to US
        _countryCode = 'US';
        _currencyCode = 'USD';
      } else {
        // Get location from IP for non-web platforms
        final locationResponse = await http.get(Uri.parse(_ipApiUrl));
        if (locationResponse.statusCode == 200) {
          final locationData = json.decode(locationResponse.body);
          _countryCode = locationData['countryCode'];
          
          // Only support US and IN
          if (_countryCode == 'IN') {
            _currencyCode = 'INR';
          } else {
            // Default to USD for all other countries
            _countryCode = 'US';
            _currencyCode = 'USD';
          }
        }
      }
    } catch (e) {
      print('Error initializing location service: $e');
      // Default to USD if there's an error
      _countryCode = 'US';
      _currencyCode = 'USD';
    }
  }

  void setCountry(String countryCode) {
    _countryCode = countryCode;
    _currencyCode = countryCode == 'IN' ? 'INR' : 'USD';
  }

  String formatPrice(double priceInUSD) {
    if (_currencyCode == 'INR') {
      // Use the exact price from your Shopify store's INR setting
      // This should match your Shopify store's currency conversion rate
      final priceInINR = priceInUSD * 83; // Replace 83 with your store's actual USD to INR rate
      return NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 2,
        locale: 'hi_IN',
      ).format(priceInINR);
    } else {
      // USD price
      return NumberFormat.currency(
        symbol: '\$',
        decimalDigits: 2,
      ).format(priceInUSD);
    }
  }

  String get currencyCode => _currencyCode ?? 'USD';
  String get countryCode => _countryCode ?? 'US';
}
