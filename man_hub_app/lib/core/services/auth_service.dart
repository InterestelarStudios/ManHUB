import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String memberType; // Ex: 'Membro Vitalício', 'Visitante', 'Assinante'
  final String? phone;
  final String? bio;
  final String? height;
  final String? weight;
  final String? age;
  final String? bodyType;
  final String? faceShape;
  final String? skinTone;
  final String? contrastLevel;
  final String? hairType;
  final String? beardStyle;
  final String? stylePreference;
  final String? dressOccasion;
  final String? fragrancePreference;
  final List<String> goals;
  final DateTime? createdAt;
  final List<String> unlockedTrainingIds;
  final bool isSubscribed;
  final DateTime? subscriptionExpiresAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.memberType = 'Visitante',
    this.phone,
    this.bio,
    this.height,
    this.weight,
    this.age,
    this.bodyType,
    this.faceShape,
    this.skinTone,
    this.contrastLevel,
    this.hairType,
    this.beardStyle,
    this.stylePreference,
    this.dressOccasion,
    this.fragrancePreference,
    this.goals = const [],
    this.createdAt,
    this.unlockedTrainingIds = const [],
    this.isSubscribed = false,
    this.subscriptionExpiresAt,
  });

  bool hasAccessToTraining(String trainingId) {
    if (isSubscribed) {
      if (subscriptionExpiresAt == null || subscriptionExpiresAt!.isAfter(DateTime.now())) {
        return true;
      }
    }
    return unlockedTrainingIds.contains(trainingId);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'memberType': memberType,
      'phone': phone,
      'bio': bio,
      'height': height,
      'weight': weight,
      'age': age,
      'bodyType': bodyType,
      'faceShape': faceShape,
      'skinTone': skinTone,
      'contrastLevel': contrastLevel,
      'hairType': hairType,
      'beardStyle': beardStyle,
      'stylePreference': stylePreference,
      'dressOccasion': dressOccasion,
      'fragrancePreference': fragrancePreference,
      'goals': goals,
      'unlockedTrainingIds': unlockedTrainingIds,
      'isSubscribed': isSubscribed,
      'subscriptionExpiresAt': subscriptionExpiresAt != null
          ? Timestamp.fromDate(subscriptionExpiresAt!)
          : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parsedCreatedAt;
    final createdVal = map['createdAt'];
    if (createdVal is Timestamp) {
      parsedCreatedAt = createdVal.toDate();
    }

    DateTime? parsedSubExpiry;
    final subExpiryVal = map['subscriptionExpiresAt'];
    if (subExpiryVal is Timestamp) {
      parsedSubExpiry = subExpiryVal.toDate();
    }

    final rawUnlocked = map['unlockedTrainingIds'];
    List<String> unlockedList = [];
    if (rawUnlocked is List) {
      unlockedList = rawUnlocked.map((e) => e.toString()).toList();
    }

    final rawGoals = map['goals'];
    List<String> goalsList = [];
    if (rawGoals is List) {
      goalsList = rawGoals.map((e) => e.toString()).toList();
    }

    return UserProfile(
      uid: uid,
      name: (map['name'] as String?)?.trim().isNotEmpty == true ? map['name'] as String : 'Membro',
      email: map['email'] as String? ?? '',
      profileImageUrl: (map['profileImageUrl'] as String?)?.trim().isNotEmpty == true
          ? map['profileImageUrl'] as String
          : null,
      memberType: map['memberType'] as String? ?? 'Visitante',
      phone: map['phone'] as String?,
      bio: map['bio'] as String?,
      height: map['height'] as String?,
      weight: map['weight'] as String?,
      age: map['age'] as String?,
      bodyType: map['bodyType'] as String?,
      faceShape: map['faceShape'] as String?,
      skinTone: map['skinTone'] as String?,
      contrastLevel: map['contrastLevel'] as String?,
      hairType: map['hairType'] as String?,
      beardStyle: map['beardStyle'] as String?,
      stylePreference: map['stylePreference'] as String?,
      dressOccasion: map['dressOccasion'] as String?,
      fragrancePreference: map['fragrancePreference'] as String?,
      goals: goalsList,
      createdAt: parsedCreatedAt,
      unlockedTrainingIds: unlockedList,
      isSubscribed: map['isSubscribed'] as bool? ?? false,
      subscriptionExpiresAt: parsedSubExpiry,
    );
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    String? memberType,
    String? phone,
    String? bio,
    String? height,
    String? weight,
    String? age,
    String? bodyType,
    String? faceShape,
    String? skinTone,
    String? contrastLevel,
    String? hairType,
    String? beardStyle,
    String? stylePreference,
    String? dressOccasion,
    String? fragrancePreference,
    List<String>? goals,
    DateTime? createdAt,
    List<String>? unlockedTrainingIds,
    bool? isSubscribed,
    DateTime? subscriptionExpiresAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      memberType: memberType ?? this.memberType,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      bodyType: bodyType ?? this.bodyType,
      faceShape: faceShape ?? this.faceShape,
      skinTone: skinTone ?? this.skinTone,
      contrastLevel: contrastLevel ?? this.contrastLevel,
      hairType: hairType ?? this.hairType,
      beardStyle: beardStyle ?? this.beardStyle,
      stylePreference: stylePreference ?? this.stylePreference,
      dressOccasion: dressOccasion ?? this.dressOccasion,
      fragrancePreference: fragrancePreference ?? this.fragrancePreference,
      goals: goals ?? this.goals,
      createdAt: createdAt ?? this.createdAt,
      unlockedTrainingIds: unlockedTrainingIds ?? this.unlockedTrainingIds,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    );
  }
}

class AuthService extends ChangeNotifier {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSubscription;

  UserProfile? _currentUser;
  bool _isInitialized = false;

  bool get isLoggedIn => (_auth?.currentUser != null) && _currentUser != null;
  UserProfile? get currentUser => _currentUser;
  User? get firebaseUser => _auth?.currentUser;

  /// Verifica se o usuário atual possui assinatura ativa do Man Hub Pass
  bool get isSubscribed {
    if (!isLoggedIn || _currentUser == null) return false;
    if (!_currentUser!.isSubscribed) return false;
    if (_currentUser!.subscriptionExpiresAt != null &&
        _currentUser!.subscriptionExpiresAt!.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  /// Indica se o usuário atual realizou cadastro via e-mail e senha
  bool get isEmailPasswordUser {
    final user = _auth?.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  /// Indica se o usuário atual realizou login via Google
  bool get isGoogleUser {
    final user = _auth?.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  /// Permite injetar/definir perfil para testes ou modo visitante
  @visibleForTesting
  set currentUserForTesting(UserProfile? profile) {
    _currentUser = profile;
    notifyListeners();
  }

  /// Inicializa o listener de autenticação e carrega o perfil do usuário
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    final auth = _auth;
    if (auth != null) {
      _authSubscription = auth.authStateChanges().listen(_onAuthStateChanged);
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    await _userDocSubscription?.cancel();
    _userDocSubscription = null;

    if (user == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    final firestore = _firestore;
    if (firestore == null) return;

    final docRef = firestore.collection('users').doc(user.uid);

    // Escuta em tempo real o documento do usuário no Firestore
    _userDocSubscription = docRef.snapshots().listen(
      (snapshot) async {
        if (snapshot.exists && snapshot.data() != null) {
          final profile = UserProfile.fromMap(snapshot.data()!, user.uid);
          // Se o perfil existente não tiver foto, mas o provedor de login fornecer photoURL, sincroniza
          if ((profile.profileImageUrl == null || profile.profileImageUrl!.isEmpty) &&
              user.photoURL != null &&
              user.photoURL!.isNotEmpty) {
            try {
              await docRef.set({'profileImageUrl': user.photoURL}, SetOptions(merge: true));
            } catch (_) {}
          }
          _currentUser = profile;
          notifyListeners();
          // Sincroniza em segundo plano quaisquer matrículas ou assinaturas do site
          if (user.email != null && user.email!.isNotEmpty) {
            syncEntitlements();
          }
        } else {
          // Se o documento ainda não existir no Firestore, cria com dados iniciais
          final initialProfile = UserProfile(
            uid: user.uid,
            name: user.displayName ?? (user.email?.split('@').first ?? 'Membro'),
            email: user.email ?? '',
            profileImageUrl: user.photoURL,
            memberType: 'Visitante',
          );
          try {
            await docRef.set(initialProfile.toMap());
          } catch (e) {
            debugPrint('Erro ao criar perfil inicial no Firestore: $e');
          }
          _currentUser = initialProfile;
          notifyListeners();
          // Sincroniza em segundo plano quaisquer compras feitas no site antes da criação da conta
          if (user.email != null && user.email!.isNotEmpty) {
            syncEntitlements();
          }
        }
      },
      onError: (error) {
        debugPrint('Erro ao sincronizar perfil do Firestore: $error');
      },
    );
  }

  /// Realiza autenticação via Google (Mobile e Web)
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      throw 'Serviço de autenticação indisponível.';
    }

    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // Usuário cancelou a seleção de conta
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      debugPrint('Erro no login com Google: $e');
      throw 'Não foi possível autenticar com o Google. Tente novamente.';
    }
  }

  /// Realiza login com E-mail e Senha no Firebase
  Future<void> login({required String email, required String password}) async {
    final auth = _auth;
    if (auth == null) {
      throw 'Serviço de autenticação indisponível.';
    }
    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Não foi possível realizar o login. Verifique sua conexão e tente novamente.';
    }
  }

  /// Cria uma nova conta no Firebase Auth e registra no Firestore
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      throw 'Serviço de autenticação indisponível.';
    }
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());

        final newProfile = UserProfile(
          uid: user.uid,
          name: name.trim(),
          email: email.trim(),
          profileImageUrl: null,
          memberType: 'Visitante',
        );

        await firestore.collection('users').doc(user.uid).set(newProfile.toMap());
        _currentUser = newProfile;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Não foi possível criar a conta. Verifique os dados e tente novamente.';
    }
  }

  /// Envia e-mail oficial de redefinição de senha
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth == null) {
      throw 'Serviço de autenticação indisponível.';
    }
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Não foi possível enviar o e-mail de recuperação. Tente novamente.';
    }
  }

  /// Atualiza o perfil do usuário tanto no Firestore quanto no FirebaseAuth
  Future<void> updateProfile({
    required String name,
    String? email,
    String? profileImageUrl,
    String? phone,
    String? bio,
    String? height,
    String? weight,
    String? age,
    String? bodyType,
    String? faceShape,
    String? skinTone,
    String? contrastLevel,
    String? hairType,
    String? beardStyle,
    String? stylePreference,
    String? dressOccasion,
    String? fragrancePreference,
    List<String>? goals,
  }) async {
    final user = _auth?.currentUser;
    final firestore = _firestore;

    final trimmedName = name.trim();
    final trimmedImageUrl = (profileImageUrl != null && profileImageUrl.trim().isNotEmpty)
        ? profileImageUrl.trim()
        : null;

    final updates = <String, dynamic>{
      'name': trimmedName,
      'profileImageUrl': trimmedImageUrl,
      'phone': phone?.trim(),
      'bio': bio?.trim(),
      'height': height?.trim(),
      'weight': weight?.trim(),
      'age': age?.trim(),
      'bodyType': bodyType?.trim(),
      'faceShape': faceShape?.trim(),
      'skinTone': skinTone?.trim(),
      'contrastLevel': contrastLevel?.trim(),
      'hairType': hairType?.trim(),
      'beardStyle': beardStyle?.trim(),
      'stylePreference': stylePreference?.trim(),
      'dressOccasion': dressOccasion?.trim(),
      'fragrancePreference': fragrancePreference?.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (goals != null) {
      updates['goals'] = goals;
    }

    if (email != null && email.trim().isNotEmpty) {
      updates['email'] = email.trim();
    }

    try {
      if (user != null && firestore != null) {
        // Atualiza no Firestore
        await firestore.collection('users').doc(user.uid).set(updates, SetOptions(merge: true));

        // Sincroniza dados no Firebase User
        if (user.displayName != trimmedName) {
          await user.updateDisplayName(trimmedName);
        }
        if (user.photoURL != trimmedImageUrl) {
          await user.updatePhotoURL(trimmedImageUrl);
        }
      }

      // Atualiza estado local imediatamente
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          name: trimmedName,
          email: email?.trim(),
          profileImageUrl: trimmedImageUrl,
          phone: phone?.trim(),
          bio: bio?.trim(),
          height: height?.trim(),
          weight: weight?.trim(),
          age: age?.trim(),
          bodyType: bodyType?.trim(),
          faceShape: faceShape?.trim(),
          skinTone: skinTone?.trim(),
          contrastLevel: contrastLevel?.trim(),
          hairType: hairType?.trim(),
          beardStyle: beardStyle?.trim(),
          stylePreference: stylePreference?.trim(),
          dressOccasion: dressOccasion?.trim(),
          fragrancePreference: fragrancePreference?.trim(),
          goals: goals ?? _currentUser!.goals,
        );
        notifyListeners();
      }
    } catch (e) {
      throw 'Erro ao salvar alterações do perfil: $e';
    }
  }

  /// Atualiza exclusivamente a foto de perfil sem interferir nos outros campos do usuário
  Future<void> updateProfilePhoto(String? profileImageUrl) async {
    final user = _auth?.currentUser;
    final firestore = _firestore;
    final trimmedUrl = (profileImageUrl != null && profileImageUrl.trim().isNotEmpty)
        ? profileImageUrl.trim()
        : null;

    try {
      if (user != null && firestore != null) {
        await firestore.collection('users').doc(user.uid).set({
          'profileImageUrl': trimmedUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        try {
          await user.updatePhotoURL(trimmedUrl);
        } catch (_) {
          // Ignora se der erro pontual na sincronização de displayName/photoURL do Firebase Auth
        }
      }

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(profileImageUrl: trimmedUrl);
        notifyListeners();
      }
    } catch (e) {
      throw 'Erro ao atualizar foto de perfil: $e';
    }
  }

  /// Salva especificamente o diagnóstico personalizado do usuário
  Future<void> updatePersonalizedProfile({
    String? height,
    String? weight,
    String? age,
    String? bodyType,
    String? faceShape,
    String? skinTone,
    String? contrastLevel,
    String? hairType,
    String? beardStyle,
    String? stylePreference,
    String? dressOccasion,
    String? fragrancePreference,
    List<String>? goals,
  }) async {
    final user = _auth?.currentUser;
    final firestore = _firestore;

    final updates = <String, dynamic>{
      'height': height?.trim(),
      'weight': weight?.trim(),
      'age': age?.trim(),
      'bodyType': bodyType?.trim(),
      'faceShape': faceShape?.trim(),
      'skinTone': skinTone?.trim(),
      'contrastLevel': contrastLevel?.trim(),
      'hairType': hairType?.trim(),
      'beardStyle': beardStyle?.trim(),
      'stylePreference': stylePreference?.trim(),
      'dressOccasion': dressOccasion?.trim(),
      'fragrancePreference': fragrancePreference?.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (goals != null) {
      updates['goals'] = goals;
    }

    try {
      if (user != null && firestore != null) {
        await firestore.collection('users').doc(user.uid).set(updates, SetOptions(merge: true));
      }

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          height: height?.trim(),
          weight: weight?.trim(),
          age: age?.trim(),
          bodyType: bodyType?.trim(),
          faceShape: faceShape?.trim(),
          skinTone: skinTone?.trim(),
          contrastLevel: contrastLevel?.trim(),
          hairType: hairType?.trim(),
          beardStyle: beardStyle?.trim(),
          stylePreference: stylePreference?.trim(),
          dressOccasion: dressOccasion?.trim(),
          fragrancePreference: fragrancePreference?.trim(),
          goals: goals ?? _currentUser!.goals,
        );
      } else {
        _currentUser = UserProfile(
          uid: 'guest',
          name: 'Visitante',
          email: '',
          height: height?.trim(),
          weight: weight?.trim(),
          age: age?.trim(),
          bodyType: bodyType?.trim(),
          faceShape: faceShape?.trim(),
          skinTone: skinTone?.trim(),
          contrastLevel: contrastLevel?.trim(),
          hairType: hairType?.trim(),
          beardStyle: beardStyle?.trim(),
          stylePreference: stylePreference?.trim(),
          dressOccasion: dressOccasion?.trim(),
          fragrancePreference: fragrancePreference?.trim(),
          goals: goals ?? [],
        );
      }
      notifyListeners();
    } catch (e) {
      throw 'Erro ao salvar diagnóstico personalizado: $e';
    }
  }

  /// Verifica se o usuário atual tem acesso total a um treinamento
  bool hasAccessToTraining(String trainingId) {
    if (_currentUser == null) return false;
    return _currentUser!.hasAccessToTraining(trainingId);
  }

  /// Simula a aquisição vitalícia de um treinamento individual
  Future<void> purchaseTrainingLifetime(String trainingId) async {
    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user == null || _currentUser == null) {
      throw 'Faça login para vincular a compra do treinamento à sua conta.';
    }

    final currentUnlocked = List<String>.from(_currentUser!.unlockedTrainingIds);
    if (!currentUnlocked.contains(trainingId)) {
      currentUnlocked.add(trainingId);
    }

    final updates = <String, dynamic>{
      'unlockedTrainingIds': currentUnlocked,
      'memberType': _currentUser!.isSubscribed ? _currentUser!.memberType : 'Membro Vitalício',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (firestore != null) {
        await firestore.collection('users').doc(user.uid).set(updates, SetOptions(merge: true));
      }
      _currentUser = _currentUser!.copyWith(
        unlockedTrainingIds: currentUnlocked,
        memberType: _currentUser!.isSubscribed ? _currentUser!.memberType : 'Membro Vitalício',
      );
      notifyListeners();
    } catch (e) {
      throw 'Erro ao registrar aquisição do treinamento: $e';
    }
  }

  /// Simula a contratação do plano mensal Man Hub Pass (acesso a todos os treinamentos)
  Future<void> subscribeMonthly() async {
    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user == null || _currentUser == null) {
      throw 'Faça login para assinar o plano e ter acesso ilimitado.';
    }

    final expiresAt = DateTime.now().add(const Duration(days: 30));
    final updates = <String, dynamic>{
      'isSubscribed': true,
      'subscriptionExpiresAt': Timestamp.fromDate(expiresAt),
      'memberType': 'Assinante Man Hub Pass',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (firestore != null) {
        await firestore.collection('users').doc(user.uid).set(updates, SetOptions(merge: true));
      }
      _currentUser = _currentUser!.copyWith(
        isSubscribed: true,
        subscriptionExpiresAt: expiresAt,
        memberType: 'Assinante Man Hub Pass',
      );
      notifyListeners();
    } catch (e) {
      throw 'Erro ao ativar assinatura mensal: $e';
    }
  }

  /// Sincroniza ativamente matrículas e assinaturas adquiridas pelo site oficial
  /// consultando o e-mail do usuário em entitlements e orders
  Future<bool> syncEntitlements() async {
    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user == null || firestore == null || user.email == null || user.email!.isEmpty) {
      return false;
    }

    final normalizedEmail = user.email!.trim().toLowerCase();
    bool updated = false;

    try {
      final userRef = firestore.collection('users').doc(user.uid);
      final List<String> currentUnlocked = List<String>.from(_currentUser?.unlockedTrainingIds ?? []);
      bool isSub = _currentUser?.isSubscribed ?? false;
      DateTime? subExpiry = _currentUser?.subscriptionExpiresAt;
      String memberType = _currentUser?.memberType ?? 'Visitante';

      // 1. Consulta documento específico em 'entitlements/{normalizedEmail}'
      final entDoc = await firestore.collection('entitlements').doc(normalizedEmail).get();
      if (entDoc.exists && entDoc.data() != null) {
        final data = entDoc.data()!;
        final rawCourses = data['unlockedTrainingIds'];
        if (rawCourses is List) {
          for (final c in rawCourses) {
            final cStr = c.toString();
            if (!currentUnlocked.contains(cStr)) {
              currentUnlocked.add(cStr);
              updated = true;
            }
          }
        }

        if (data['isSubscribed'] == true) {
          final exp = data['subscriptionExpiresAt'];
          DateTime? newExpiry;
          if (exp is Timestamp) {
            newExpiry = exp.toDate();
          } else if (exp is String) {
            newExpiry = DateTime.tryParse(exp);
          }
          if (newExpiry == null || newExpiry.isAfter(DateTime.now())) {
            if (!isSub || (subExpiry != null && newExpiry != null && newExpiry.isAfter(subExpiry))) {
              isSub = true;
              subExpiry = newExpiry ?? DateTime.now().add(const Duration(days: 30));
              memberType = 'Assinante Man Hub Pass';
              updated = true;
            }
          }
        }
      }

      // 2. Consulta ordens aprovadas associadas a este e-mail
      try {
        final ordersSnap = await firestore
            .collection('orders')
            .where('payerEmail', isEqualTo: normalizedEmail)
            .get();

        for (final doc in ordersSnap.docs) {
          final order = doc.data();
          if (order['status'] == 'approved') {
            final itemType = order['itemType'] as String?;
            final itemId = order['itemId'] as String?;
            if (itemType == 'training' && itemId != null && itemId.isNotEmpty) {
              if (!currentUnlocked.contains(itemId)) {
                currentUnlocked.add(itemId);
                updated = true;
              }
            } else if (itemType == 'pass') {
              isSub = true;
              subExpiry = DateTime.now().add(const Duration(days: 30));
              memberType = 'Assinante Man Hub Pass';
              updated = true;
            }
          }
        }
      } catch (orderErr) {
        debugPrint('Aviso ao consultar orders: $orderErr');
      }

      if (updated) {
        final updateData = <String, dynamic>{
          'unlockedTrainingIds': currentUnlocked,
          'isSubscribed': isSub,
          'memberType': isSub
              ? 'Assinante Man Hub Pass'
              : (currentUnlocked.isNotEmpty ? 'Membro Vitalício' : memberType),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (subExpiry != null) {
          updateData['subscriptionExpiresAt'] = Timestamp.fromDate(subExpiry);
        }

        await userRef.set(updateData, SetOptions(merge: true));

        _currentUser = _currentUser?.copyWith(
          unlockedTrainingIds: currentUnlocked,
          isSubscribed: isSub,
          subscriptionExpiresAt: subExpiry,
          memberType: updateData['memberType'] as String?,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao sincronizar acessos: $e');
      return false;
    }
  }

  /// Altera a senha do usuário autenticado com e-mail e senha
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth?.currentUser;
    if (user == null || user.email == null) {
      throw 'Usuário não autenticado.';
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword.trim(),
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword.trim());
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Não foi possível alterar a senha: $e';
    }
  }

  /// Altera o e-mail do usuário autenticado com e-mail e senha
  Future<void> changeEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user == null || user.email == null) {
      throw 'Usuário não autenticado.';
    }

    final trimmedNewEmail = newEmail.trim();

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      await user.verifyBeforeUpdateEmail(trimmedNewEmail);

      if (firestore != null) {
        await firestore.collection('users').doc(user.uid).set({
          'email': trimmedNewEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(email: trimmedNewEmail);
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Não foi possível alterar o e-mail: $e';
    }
  }

  /// Exclui permanentemente a conta do usuário
  Future<void> deleteAccount({String? currentPassword}) async {
    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user == null) {
      throw 'Usuário não autenticado.';
    }

    try {
      if (isEmailPasswordUser &&
          currentPassword != null &&
          currentPassword.trim().isNotEmpty &&
          user.email != null) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword.trim(),
        );
        await user.reauthenticateWithCredential(cred);
      }

      final uid = user.uid;

      if (firestore != null) {
        try {
          await firestore.collection('users').doc(uid).delete();
        } catch (e) {
          debugPrint('Erro ao excluir documento do usuário: $e');
        }
        try {
          await firestore.collection('user_progress').doc(uid).delete();
        } catch (_) {}
      }

      try {
        if (!kIsWeb) {
          await GoogleSignIn().signOut();
        }
      } catch (_) {}

      await user.delete();

      await _userDocSubscription?.cancel();
      _userDocSubscription = null;
      _currentUser = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Por segurança, confirme sua senha atual para autorizar a exclusão da conta.';
      }
      throw _getErrorMessage(e);
    } catch (e) {
      throw 'Não foi possível excluir a conta: $e';
    }
  }

  /// Encerra a sessão do usuário
  Future<void> logout() async {
    await _userDocSubscription?.cancel();
    _userDocSubscription = null;
    final auth = _auth;
    if (auth != null) {
      try {
        if (!kIsWeb) {
          await GoogleSignIn().signOut();
        }
      } catch (e) {
        debugPrint('Erro ao desconectar GoogleSignIn: $e');
      }
      await auth.signOut();
    }
    _currentUser = null;
    notifyListeners();
  }

  /// Mensagens de erro amigáveis em português para códigos do FirebaseAuth
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nenhum usuário cadastrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Verifique os dados digitados.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este endereço de e-mail já está cadastrado em outra conta.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta associada a este e-mail com outro método de login.';
      case 'popup-closed-by-user':
        return 'A janela de autenticação foi fechada.';
      case 'invalid-email':
        return 'O formato do e-mail digitado é inválido.';
      case 'weak-password':
        return 'A senha escolhida é muito fraca. Utilize no mínimo 6 caracteres.';
      case 'user-disabled':
        return 'Esta conta de usuário foi desativada pelo administrador.';
      case 'too-many-requests':
        return 'Muitas tentativas consecutivas. Aguarde alguns instantes e tente novamente.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique o acesso à internet do seu dispositivo.';
      case 'operation-not-allowed':
        return 'Este método de autenticação não está habilitado no momento.';
      case 'requires-recent-login':
        return 'Esta operação requer autenticação recente. Informe sua senha atual para continuar.';
      default:
        return e.message ?? 'Ocorreu um erro na autenticação. Tente novamente.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
