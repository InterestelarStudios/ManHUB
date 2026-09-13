import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/outfit.dart';
import 'auth_service.dart';

class OutfitService extends ChangeNotifier {
  static final OutfitService _instance = OutfitService._internal();
  factory OutfitService() => _instance;
  OutfitService._internal() {
    _loadPresetOutfits();
    _fetchRemoteOutfits();
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final List<Outfit> _outfits = [];
  final Set<String> _savedOutfitIds = {};
  bool _isLoading = false;

  List<Outfit> get outfits => List.unmodifiable(_outfits);
  Set<String> get savedOutfitIds => Set.unmodifiable(_savedOutfitIds);
  bool get isLoading => _isLoading;

  List<Outfit> get savedOutfits {
    return _outfits.where((o) => _savedOutfitIds.contains(o.id)).toList();
  }

  bool isOutfitSaved(String outfitId) => _savedOutfitIds.contains(outfitId);

  void toggleSaveOutfit(String outfitId) {
    if (_savedOutfitIds.contains(outfitId)) {
      _savedOutfitIds.remove(outfitId);
    } else {
      _savedOutfitIds.add(outfitId);
    }
    notifyListeners();
    _persistSavedOutfits();
  }

  Future<void> _persistSavedOutfits() async {
    final user = AuthService().currentUser;
    final fs = _firestore;
    if (user != null && fs != null) {
      try {
        await fs.collection('users').doc(user.uid).set({
          'savedOutfitIds': _savedOutfitIds.toList(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Erro ao persistir outfits salvos: $e');
      }
    }
  }

  Future<void> publishOutfit(Outfit outfit) async {
    final fs = _firestore;
    final outfitId = outfit.id.isEmpty ? const Uuid().v4() : outfit.id;
    final newOutfit = outfit.copyWith(id: outfitId);

    _outfits.insert(0, newOutfit);
    notifyListeners();

    if (fs != null) {
      try {
        await fs.collection('outfits').doc(outfitId).set(newOutfit.toMap());
      } catch (e) {
        debugPrint('Erro ao publicar outfit no Firestore: $e');
      }
    }
  }

  Future<void> refreshOutfits() async {
    await _fetchRemoteOutfits();
  }

  Future<void> _fetchRemoteOutfits() async {
    final fs = _firestore;
    if (fs == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await fs
          .collection('outfits')
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final remoteOutfits = snapshot.docs.map((doc) => Outfit.fromFirestore(doc)).toList();
        
        // Merge without duplicating preset ones
        for (final ro in remoteOutfits) {
          final idx = _outfits.indexWhere((o) => o.id == ro.id);
          if (idx >= 0) {
            _outfits[idx] = ro;
          } else {
            _outfits.add(ro);
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar outfits remotos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadPresetOutfits() {
    if (_outfits.isNotEmpty) return;

    _outfits.addAll([
      Outfit(
        id: 'outfit_smart_casual_1',
        title: 'Smart Casual Riviera & Alfaiataria',
        description: 'Combinação clássica contemporânea com blazer de linho desestruturado, camisa polo texturizada, calça de alfaiataria bege e mocassim de camurça.',
        styleCategory: 'Smart Casual',
        occasion: 'Trabalho / Almoço de Negócios',
        imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=1200&auto=format&fit=crop',
        creatorName: 'Man Hub Curadoria',
        isFeatured: true,
        likesCount: 142,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        pieces: [
          OutfitPiece(
            id: 'p_1',
            name: 'Blazer Desestruturado em Linho Azul Petróleo',
            category: 'Casaco / Blazer',
            price: 'R\$ 689,90',
            brand: 'Massimo Dutti',
            affiliateUrl: 'https://www.massimodutti.com',
            notes: 'Corte slim sem ombreiras para um caimento natural e fluido.',
          ),
          OutfitPiece(
            id: 'p_2',
            name: 'Camisa Polo em Algodão Mercerizado Off-White',
            category: 'Torso / Polo',
            price: 'R\$ 219,90',
            brand: 'Reserva Premium',
            affiliateUrl: 'https://www.usereserva.com',
            notes: 'Colarinho firme que se mantém alinhado por baixo do blazer.',
          ),
          OutfitPiece(
            id: 'p_3',
            name: 'Calça de Alfaiataria Chino Areia com Ajuste Lateral',
            category: 'Calça / Alfaiataria',
            price: 'R\$ 349,90',
            brand: 'Zara Men Studio',
            affiliateUrl: 'https://www.zara.com',
            notes: 'Barra italiana limpa, sem sobras sobre o calçado.',
          ),
          OutfitPiece(
            id: 'p_4',
            name: 'Mocassim Loafer em Camurça Marrom Café',
            category: 'Calçado / Sapato',
            price: 'R\$ 489,90',
            brand: 'Democrata',
            affiliateUrl: 'https://www.democrata.com.br',
            notes: 'Sola de couro com acabamento manual e palmilha anatômica.',
          ),
          OutfitPiece(
            id: 'p_5',
            name: 'Relógio Cronógrafo Clássico com Pulseira em Couro',
            category: 'Acessório / Relógio',
            price: 'R\$ 890,00',
            brand: 'Tissot Classic',
            affiliateUrl: 'https://www.tissotwatches.com',
            notes: 'Caixa de 40mm minimalista com mostrador marfim.',
          ),
        ],
      ),
      Outfit(
        id: 'outfit_old_money_1',
        title: 'Old Money Summer Heritage',
        description: 'Elegância silenciosa com camisa de linho cru respirável, suéter de tricô azul marinho nos ombros e mocassim penny loafer.',
        styleCategory: 'Old Money',
        occasion: 'Fim de Semana / Resort',
        imageUrl: 'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?q=80&w=1200&auto=format&fit=crop',
        creatorName: 'Man Hub IA',
        isFeatured: true,
        likesCount: 218,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        pieces: [
          OutfitPiece(
            id: 'om_1',
            name: 'Camisa 100% Linho Puro Francês Branco Neve',
            category: 'Torso / Camisa',
            price: 'R\$ 389,00',
            brand: 'Ralph Lauren Classic',
            affiliateUrl: 'https://www.ralphlauren.com',
            notes: 'Toque macio pré-lavado, caimento levemente solto.',
          ),
          OutfitPiece(
            id: 'om_2',
            name: 'Suéter Tricô Gola Redonda em Algodão Pima Marinho',
            category: 'Casaco / Tricô',
            price: 'R\$ 429,90',
            brand: 'Brooks Brothers',
            affiliateUrl: 'https://www.brooksbrothers.com',
            notes: 'Ideal para usar drapeado sobre os ombros com nó suave.',
          ),
          OutfitPiece(
            id: 'om_3',
            name: 'Bermuda Chino Alfaiatada Caqui Claro',
            category: 'Calça / Alfaiataria',
            price: 'R\$ 259,00',
            brand: 'Aramis',
            affiliateUrl: 'https://www.aramis.com.br',
            notes: 'Comprimento 2 dedos acima do joelho.',
          ),
          OutfitPiece(
            id: 'om_4',
            name: 'Perfume Bleu Égée Cítrico Amadeirado',
            category: 'Perfumaria / Assinatura',
            price: 'R\$ 550,00',
            brand: 'Acqua Di Parma',
            affiliateUrl: 'https://www.sephora.com.br',
            notes: 'Notas de bergamota italiana, cipreste e cedro nobre.',
          ),
        ],
      ),
      Outfit(
        id: 'outfit_urban_1',
        title: 'Casual Urbano & Overshirt Estruturada',
        description: 'Visual contemporâneo sofisticado com overshirt de sarja pesada grafite, camiseta premium de alta gramatura e botas chelsea pretas.',
        styleCategory: 'Casual Urbano',
        occasion: 'Encontro Noturno / Evento Cultural',
        imageUrl: 'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=1200&auto=format&fit=crop',
        creatorName: 'Man Hub Curadoria',
        isFeatured: false,
        likesCount: 95,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        pieces: [
          OutfitPiece(
            id: 'u_1',
            name: 'Overshirt Utilitária em Sarja Pesada Grafite',
            category: 'Casaco / Jaqueta',
            price: 'R\$ 419,00',
            brand: 'Foxton Men',
            affiliateUrl: 'https://www.foxton.com.br',
            notes: 'Bolsos frontais com pesponto reforçado.',
          ),
          OutfitPiece(
            id: 'u_2',
            name: 'T-Shirt Heavyweight 240g Preta Pura',
            category: 'Torso / Camiseta',
            price: 'R\$ 149,90',
            brand: 'Minimal Club',
            affiliateUrl: 'https://www.minimalclub.com.br',
            notes: 'Gola careca reforçada que não deforma com lavagens.',
          ),
          OutfitPiece(
            id: 'u_3',
            name: 'Calça Jeans Selvedge Denim Escura Reta',
            category: 'Calça / Jeans',
            price: 'R\$ 399,00',
            brand: 'Levi’s Premium',
            affiliateUrl: 'https://www.levi.com.br',
            notes: 'Sem lavagens artificiais, tom índigo profundo.',
          ),
          OutfitPiece(
            id: 'u_4',
            name: 'Bota Chelsea em Couro Floater Preto',
            category: 'Calçado / Bota',
            price: 'R\$ 529,00',
            brand: 'Kildare Heritage',
            affiliateUrl: 'https://www.kildare.com.br',
            notes: 'Elástico lateral reforçado e sola tratorada discreta.',
          ),
        ],
      ),
      Outfit(
        id: 'outfit_minimalist_1',
        title: 'Minimalismo Monocromático Noturno',
        description: 'Linhas puras e arquitetura têxtil com gola alta de lã merino, casaco alfaiatado estruturado e calça reta com pregas discretas.',
        styleCategory: 'Minimalista & Atemporal',
        occasion: 'Jantar Executivo / Evento Noturno',
        imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1200&auto=format&fit=crop',
        creatorName: 'Man Hub IA',
        isFeatured: true,
        likesCount: 176,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        pieces: [
          OutfitPiece(
            id: 'm_1',
            name: 'Turtleneck de Lã Merino Fina Preto Fosco',
            category: 'Torso / Gola Alta',
            price: 'R\$ 320,00',
            brand: 'Uniqlo / Curadoria',
            affiliateUrl: 'https://www.uniqlo.com',
            notes: 'Termorreguladora, mantém o corpo aquecido sem excesso de volume.',
          ),
          OutfitPiece(
            id: 'm_2',
            name: 'Casaco Overcoat Curto em Lã Batida Carvão',
            category: 'Casaco / Sobretudo',
            price: 'R\$ 799,00',
            brand: 'Zara Studio',
            affiliateUrl: 'https://www.zara.com',
            notes: 'Fechamento com 3 botões e lapela notched alinhada.',
          ),
          OutfitPiece(
            id: 'm_3',
            name: 'Calça Alfaiataria Reta Preta com Pregas',
            category: 'Calça / Alfaiataria',
            price: 'R\$ 289,00',
            brand: 'Cider Man',
            affiliateUrl: 'https://www.cider.com',
            notes: 'Caimento fluido com excelente mobilidade.',
          ),
          OutfitPiece(
            id: 'm_4',
            name: 'Sapato Derby Couro Nobuck Preto Fosco',
            category: 'Calçado / Sapato',
            price: 'R\$ 460,00',
            brand: 'Vans / Premium',
            affiliateUrl: 'https://www.democrata.com.br',
            notes: 'Silhueta elegante e solado acolchoado.',
          ),
        ],
      ),
    ]);
  }
}
