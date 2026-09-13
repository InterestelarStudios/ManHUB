import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:man_hub_app/domain/models/outfit.dart';
import 'package:man_hub_app/core/services/outfit_service.dart';
import 'package:man_hub_app/core/services/wardrobe_service.dart';
import 'package:man_hub_app/presentation/screens/main_navigation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Outfit & OutfitPiece Models', () {
    test('OutfitPiece serializes and deserializes properly', () {
      const piece = OutfitPiece(
        id: 'piece_1',
        category: 'Torso',
        name: 'Camisa Linho Branca Slim',
        brand: 'Zara Man',
        price: 'R\$ 279,90',
        affiliateUrl: 'https://exemplo.com/camisa',
        color: 'Branco Neve',
      );

      final map = piece.toMap();
      expect(map['id'], 'piece_1');
      expect(map['category'], 'Torso');
      expect(map['name'], 'Camisa Linho Branca Slim');
      expect(map['price'], 'R\$ 279,90');
      expect(map['affiliateUrl'], 'https://exemplo.com/camisa');

      final parsed = OutfitPiece.fromMap(map);
      expect(parsed.id, piece.id);
      expect(parsed.category, piece.category);
      expect(parsed.name, piece.name);
      expect(parsed.price, piece.price);
      expect(parsed.affiliateUrl, piece.affiliateUrl);
    });

    test('Outfit serializes and deserializes properly with pieces list', () {
      final outfit = Outfit(
        id: 'outfit_test_1',
        title: 'Old Money Summer Linen',
        description: 'Look elegante de verão com alfaiataria em linho claro.',
        imageUrl: 'https://images.unsplash.com/test-look.jpg',
        styleCategory: 'Old Money',
        season: 'Verão',
        occasion: 'Lazer Fino',
        authorName: 'IA Stylist ManHUB',
        likesCount: 15,
        pieces: const [
          OutfitPiece(
            id: 'p1',
            category: 'Torso',
            name: 'Camisa Linho',
            price: 'R\$ 299,00',
          ),
          OutfitPiece(
            id: 'p2',
            category: 'Pants',
            name: 'Calça Alfaiataria Bege',
            price: 'R\$ 389,00',
          ),
        ],
      );

      final map = outfit.toMap();
      expect(map['id'], 'outfit_test_1');
      expect(map['title'], 'Old Money Summer Linen');
      expect(map['styleCategory'], 'Old Money');
      expect((map['pieces'] as List).length, 2);

      final parsed = Outfit.fromMap(map);
      expect(parsed.id, outfit.id);
      expect(parsed.title, outfit.title);
      expect(parsed.pieces.length, 2);
      expect(parsed.pieces.first.name, 'Camisa Linho');
      expect(parsed.totalPrice, 688.0);
    });
  });

  group('OutfitService Tests', () {
    test('Contains default preset looks and handles bookmarking', () {
      final service = OutfitService();
      expect(service.outfits.isNotEmpty, isTrue);

      final firstOutfit = service.outfits.first;
      expect(service.isOutfitSaved(firstOutfit.id), isFalse);

      // Bookmark
      service.toggleSaveOutfit(firstOutfit.id);
      expect(service.isOutfitSaved(firstOutfit.id), isTrue);
      expect(service.savedOutfits.any((o) => o.id == firstOutfit.id), isTrue);

      // Un-bookmark
      service.toggleSaveOutfit(firstOutfit.id);
      expect(service.isOutfitSaved(firstOutfit.id), isFalse);
    });

    test('Publishing a new look adds it to the outfits list', () async {
      final service = OutfitService();
      final initialCount = service.outfits.length;

      final newOutfit = Outfit(
        id: 'custom_look_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Casual Tech Leader',
        description: 'Minimalismo escuro com jaqueta bomber e tênis monocromático.',
        imageUrl: 'https://images.unsplash.com/look_leader.jpg',
        styleCategory: 'Casual Chic',
        season: 'Outono',
        occasion: 'Casual Corporativo',
        authorName: 'Você (IA Assistant)',
        pieces: const [
          OutfitPiece(
            id: 'c1',
            category: 'Torso',
            name: 'Camiseta Algodão Egípcio Preta',
            brand: 'Insider',
            price: 'R\$ 169,00',
          ),
        ],
      );

      await service.publishOutfit(newOutfit);
      expect(service.outfits.length, initialCount + 1);
      expect(service.outfits.first.title, 'Casual Tech Leader');
    });
  });

  group('WardrobeService Tests', () {
    test('Default haircuts and fragrances exist and bookmarking works', () {
      final wardrobe = WardrobeService();
      expect(wardrobe.savedHaircuts.isNotEmpty, isTrue);
      expect(wardrobe.savedFragrances.isNotEmpty, isTrue);

      const customCut = SavedHaircut(
        id: 'hc_custom',
        title: 'Buzz Cut com Fade Cirúrgico',
        faceShape: 'Quadrado',
        description: 'Visual militar moderno e imponente.',
        imageUrl: 'https://example.com/buzz.jpg',
        recommendedStylingProduct: 'Óleo para Couro Cabeludo',
      );

      expect(wardrobe.isHaircutSaved(customCut.id), isFalse);
      wardrobe.toggleSaveHaircut(customCut);
      expect(wardrobe.isHaircutSaved(customCut.id), isTrue);
      wardrobe.toggleSaveHaircut(customCut);
      expect(wardrobe.isHaircutSaved(customCut.id), isFalse);
    });
  });

  group('MainNavigationScreen Structure', () {
    testWidgets('Has 5 tabs in correct order: Home, Outfits, Treinamentos, Armário, Perfil', (tester) async {
      await _runWithMockImageClient(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MainNavigationScreen(),
          ),
        );
        await tester.pump();

        // Verify the 5 labels exist
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Outfits'), findsOneWidget);
        expect(find.text('Treinamentos'), findsOneWidget);
        expect(find.text('Armário'), findsOneWidget);
        expect(find.text('Perfil'), findsOneWidget);

        // Verify 'Produtos' was completely removed
        expect(find.text('Produtos'), findsNothing);
      });
    });

    testWidgets('Tapping Outfits tab navigates to Outfits view', (tester) async {
      await _runWithMockImageClient(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MainNavigationScreen(),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Outfits'));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Outfits & Estilos'), findsOneWidget);
        expect(find.text('Criar Look com IA'), findsOneWidget);
      });
    });

    testWidgets('Tapping Armário tab navigates to Wardrobe view', (tester) async {
      await _runWithMockImageClient(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MainNavigationScreen(),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Armário'));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Meu Armário'), findsOneWidget);
        expect(find.text('Cortes & Visagismo'), findsOneWidget);
        expect(find.text('Perfumes'), findsOneWidget);
        expect(find.text('Paleta & Biometria'), findsOneWidget);
      });
    });
  });
}

Future<void> _runWithMockImageClient(Future<void> Function() testBody) async {
  debugNetworkImageHttpClientProvider = () => _FakeHttpClient();
  try {
    await testBody();
  } finally {
    debugNetworkImageHttpClientProvider = null;
  }
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final Stream<List<int>> _stream = Stream<List<int>>.value(_kTransparentPng);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  List<Cookie> get cookies => [];

  @override
  String get reasonPhrase => 'OK';

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => [];

  @override
  Future<Socket> detachSocket() => throw UnimplementedError();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) =>
      throw UnimplementedError();

  @override
  bool get persistentConnection => true;
}

final List<int> _kTransparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];
