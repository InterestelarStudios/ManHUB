import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  /// Endpoint oficial do Firebase Cloud Functions para criação de preferências
  static const String _cloudFunctionUrl =
      'https://us-central1-man-hub-c0bef.cloudfunctions.net/createPaymentPreference';

  /// URL base da API do Man Hub Web (Next.js) como fallback de desenvolvimento
  /// Android Emulator usa 10.0.2.2 para acessar o localhost do host.
  String get _apiBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  /// Gera a preferência no Mercado Pago através do Firebase Cloud Functions
  /// (ou fallback web) e abre o Checkout Pro oficial (Pix, Cartão, Boleto).
  Future<bool> startCheckout({
    required String itemType, // 'training' | 'pass'
    required String itemId,
    required String title,
    required double price,
    required String userId,
    String? userEmail,
  }) async {
    final payload = jsonEncode({
      'itemType': itemType,
      'itemId': itemId,
      'title': title,
      'price': price,
      'userId': userId,
      'userEmail': userEmail ?? '',
    });

    final endpoints = [
      Uri.parse('https://createpaymentpreference-qvx7hkb7ha-uc.a.run.app'),
      Uri.parse(_cloudFunctionUrl),
      Uri.parse('$_apiBaseUrl/api/payments/create-preference'),
    ];

    String? initPoint;
    dynamic lastError;

    for (final uri in endpoints) {
      try {
        debugPrint('[PaymentService] Tentando checkout em: $uri');
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: payload,
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          initPoint = data['initPoint'] as String?;
          if (initPoint != null && initPoint.isNotEmpty) {
            break; // Sucesso na criação da preferência
          }
        } else {
          lastError =
              'Status ${response.statusCode}: ${response.body}';
        }
      } catch (e) {
        lastError = e;
        debugPrint('[PaymentService] Falha no endpoint $uri: $e');
      }
    }

    if (initPoint == null || initPoint.isEmpty) {
      throw Exception(
          'Não foi possível iniciar o checkout no Mercado Pago. Detalhes: $lastError');
    }

    final checkoutUri = Uri.parse(initPoint);
    final launched = await launchUrl(
      checkoutUri,
      mode: LaunchMode.externalApplication,
    );

    return launched;
  }
}
