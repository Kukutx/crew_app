import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stripeTestServiceProvider = Provider<StripeTestService>((ref) {
  return StripeTestService();
});

class StripeTestService {
  StripeTestService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://stripe-mobile-payment-sheet.glitch.me',
                headers: const {
                  'Content-Type': 'application/json; charset=utf-8',
                },
              ),
            );

  final Dio _dio;

  Future<StripePaymentSheetConfig> createPaymentSheet({
    required int amountInCents,
    required String currency,
    String? description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/create-payment-intent',
        data: <String, dynamic>{
          'amount': amountInCents,
          'currency': currency,
          if (description != null) 'description': description,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const StripeTestException('Empty response from Stripe test server');
      }
      return StripePaymentSheetConfig.fromJson(data);
    } on DioException catch (error) {
      final message = error.response?.data;
      final description = message is Map<String, dynamic>
          ? message['error']?.toString()
          : error.message;
      throw StripeTestException(
        description ?? 'Failed to create Stripe payment intent',
      );
    }
  }
}

class StripePaymentSheetConfig {
  StripePaymentSheetConfig({
    required this.paymentIntentClientSecret,
    required this.customerId,
    required this.customerEphemeralKeySecret,
    required this.publishableKey,
  });

  factory StripePaymentSheetConfig.fromJson(Map<String, dynamic> json) {
    final paymentIntent = json['paymentIntent']?.toString();
    final customer = json['customer']?.toString();
    final ephemeralKey = json['ephemeralKey']?.toString();
    final publishableKey = json['publishableKey']?.toString();

    if (paymentIntent == null || paymentIntent.isEmpty) {
      throw const StripeTestException('Missing payment intent secret');
    }
    if (customer == null || customer.isEmpty) {
      throw const StripeTestException('Missing customer id');
    }
    if (ephemeralKey == null || ephemeralKey.isEmpty) {
      throw const StripeTestException('Missing ephemeral key secret');
    }
    if (publishableKey == null || publishableKey.isEmpty) {
      throw const StripeTestException('Missing publishable key');
    }

    return StripePaymentSheetConfig(
      paymentIntentClientSecret: paymentIntent,
      customerId: customer,
      customerEphemeralKeySecret: ephemeralKey,
      publishableKey: publishableKey,
    );
  }

  final String paymentIntentClientSecret;
  final String customerId;
  final String customerEphemeralKeySecret;
  final String publishableKey;
}

class StripeTestException implements Exception {
  const StripeTestException(this.message);

  final String message;

  @override
  String toString() => 'StripeTestException: $message';
}
