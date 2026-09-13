import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  /// URL base da API do Man Hub Web (Next.js)
  /// Android Emulator usa 10.0.2.2 para acessar o localhost do computador hospedeiro.
  String get _apiBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  /// Gera a preferência no Mercado Pago através do backend Next.js
  /// e abre a interface de Checkout Pro oficial (Pix, Cartão, Boleto) no navegador ou app do MP.
  Future<bool> startCheckout({
    required String itemType, // 'training' | 'pass'
    required String itemId,
    required String title,
    required double price,
    required String userId,
    String? userEmail,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/api/payments/create-preference');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'itemType': itemType,
              'itemId': itemId,
              'title': title,
              'price': price,
              'userId': userId,
              'userEmail': userEmail ?? '',
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception(
            'Falha no gateway de pagamento (${response.statusCode}): ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final initPoint = data['initPoint'] as String?;

      if (initPoint == null || initPoint.isEmpty) {
        throw Exception('Link de pagamento não retornado pelo Mercado Pago.');
      }

      final checkoutUri = Uri.parse(initPoint);
      final launched = await launchUrl(
        checkoutUri,
        mode: LaunchMode.externalApplication,
      );

      return launched;
    } catch (e) {
      debugPrint('[PaymentService] Erro ao iniciar checkout Mercado Pago: $e');
      rethrow;
    }
  }
}
