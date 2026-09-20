import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/product.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('products');

  Query<Product> getProductsQuery({String? category}) {
    Query<Map<String, dynamic>> query = _collection;

    if (category != null && category.isNotEmpty && category != 'Todos') {
      query = query.where('category', isEqualTo: category);
    }

    return query.withConverter<Product>(
      fromFirestore: (snapshot, _) => Product.fromFirestore(snapshot),
      toFirestore: (product, _) => product.toMap(),
    );
  }

  Stream<List<Product>> getProductsStream({String? category}) {
    Query<Map<String, dynamic>> query = _collection;

    if (category != null && category.isNotEmpty && category != 'Todos') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      // Ordena por destaque primeiro, depois por data de criação
      list.sort((a, b) {
        if (a.isFeatured != b.isFeatured) {
          return a.isFeatured ? -1 : 1;
        }
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return 0;
      });
      return list;
    });
  }

  Future<List<Product>> getProducts({String? category}) async {
    Query<Map<String, dynamic>> query = _collection;

    if (category != null && category.isNotEmpty && category != 'Todos') {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    final list = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    list.sort((a, b) {
      if (a.isFeatured != b.isFeatured) {
        return a.isFeatured ? -1 : 1;
      }
      if (a.createdAt != null && b.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      return 0;
    });
    return list;
  }
}
