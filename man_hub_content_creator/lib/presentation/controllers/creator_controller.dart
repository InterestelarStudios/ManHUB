import 'package:flutter/foundation.dart';
import '../../domain/models/content_block.dart';
import '../../domain/models/screen_model.dart';
import '../../domain/models/session.dart';
import '../../domain/models/module.dart';
import '../../domain/models/training.dart';
import '../../services/firestore_training_service.dart';

class CreatorController extends ChangeNotifier {
  final FirestoreTrainingService _firestoreService = FirestoreTrainingService();

  List<Training> trainings = [];
  Training training = Training(title: 'Jornada do Homem de Valor');
  Session? selectedSession;
  ScreenModel? selectedScreen;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _statusMessage;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get statusMessage => _statusMessage;
  bool get isFirestoreAvailable => _firestoreService.isAvailable;

  CreatorController() {
    trainings = [training];
  }

  /// Carrega os treinamentos cadastrados no Firestore
  Future<void> loadTrainingsFromFirestore() async {
    _isLoading = true;
    notifyListeners();

    try {
      final remoteTrainings = await _firestoreService.fetchTrainings();
      if (remoteTrainings.isNotEmpty) {
        trainings = remoteTrainings;
        training = trainings.first;
        selectedSession = null;
        selectedScreen = null;
      }
    } catch (e) {
      debugPrint('Não foi possível carregar treinamentos do Firestore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva um treinamento diretamente no Cloud Firestore
  Future<bool> saveTrainingToFirestore(Training t) async {
    _isSaving = true;
    _statusMessage = 'Salvando "${t.title}" no Firestore...';
    notifyListeners();

    try {
      await _firestoreService.saveTraining(t);
      if (!trainings.any((item) => item.id == t.id)) {
        trainings.add(t);
      }
      _statusMessage = 'Salvo com sucesso no Firestore!';
      return true;
    } catch (e) {
      _statusMessage = 'Erro ao salvar: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Salva o treinamento atualmente selecionado
  Future<bool> saveCurrentTraining() async {
    return await saveTrainingToFirestore(training);
  }

  void selectTraining(Training t) {
    training = t;
    selectedSession = null;
    selectedScreen = null;
    notifyListeners();
  }

  void addNewTraining(
    String title, {
    String? subtitle,
    String? description,
    String? whatYouWillLearn,
    String? duration,
    String? coverImageUrl,
    String? requirements,
    double? price,
    String? category,
    List<String>? categories,
  }) {
    final newTraining = Training(
      title: title,
      subtitle: subtitle,
      description: description,
      whatYouWillLearn: whatYouWillLearn,
      duration: duration,
      coverImageUrl: coverImageUrl,
      requirements: requirements,
      price: price,
      category: category,
      categories: categories,
    );
    trainings.add(newTraining);
    selectTraining(newTraining);
  }

  void importTraining(Training t) {
    // Se já houver um com o mesmo ID, atualiza; senão adiciona
    final index = trainings.indexWhere((item) => item.id == t.id);
    if (index >= 0) {
      trainings[index] = t;
    } else {
      trainings.add(t);
    }
    selectTraining(t);
  }

  Future<void> deleteTraining(Training t) async {
    trainings.remove(t);
    if (training == t) {
      if (trainings.isNotEmpty) {
        selectTraining(trainings.first);
      } else {
        final fallback = Training(title: 'Novo Treinamento');
        trainings.add(fallback);
        selectTraining(fallback);
      }
    } else {
      notifyListeners();
    }

    try {
      await _firestoreService.deleteTraining(t.id);
    } catch (e) {
      debugPrint('Aviso: Falha ao excluir do Firestore: $e');
    }
  }

  void updateTrainingTitle(String newTitle) {
    training.title = newTitle;
    notifyListeners();
  }

  void updateTrainingSubtitle(String newSubtitle) {
    training.subtitle = newSubtitle;
    notifyListeners();
  }

  void updateTrainingDescription(String newDescription) {
    training.description = newDescription;
    notifyListeners();
  }

  void updateTrainingWhatYouWillLearn(String newWhatYouWillLearn) {
    training.whatYouWillLearn = newWhatYouWillLearn;
    notifyListeners();
  }

  void updateTrainingDuration(String newDuration) {
    training.duration = newDuration;
    notifyListeners();
  }

  void updateTrainingCoverImageUrl(String newCoverImageUrl) {
    training.coverImageUrl = newCoverImageUrl;
    notifyListeners();
  }

  void updateTrainingRequirements(String newRequirements) {
    training.requirements = newRequirements;
    notifyListeners();
  }

  void updateTrainingPrice(double? newPrice) {
    training.price = newPrice;
    notifyListeners();
  }

  void updateTrainingCategory(String? newCategory) {
    training.category = newCategory;
    notifyListeners();
  }

  void updateTrainingCategories(List<String> newCategories) {
    training.categories = newCategories;
    if (newCategories.isNotEmpty) {
      training.category = newCategories.first;
    }
    notifyListeners();
  }

  void updateTrainingMetadata({
    String? title,
    String? subtitle,
    String? description,
    String? whatYouWillLearn,
    String? duration,
    String? coverImageUrl,
    String? requirements,
    double? price,
    String? category,
    List<String>? categories,
  }) {
    if (title != null) training.title = title;
    if (subtitle != null) training.subtitle = subtitle;
    if (description != null) training.description = description;
    if (whatYouWillLearn != null) training.whatYouWillLearn = whatYouWillLearn;
    if (duration != null) training.duration = duration;
    if (coverImageUrl != null) training.coverImageUrl = coverImageUrl;
    if (requirements != null) training.requirements = requirements;
    training.price = price;
    if (category != null) training.category = category;
    if (categories != null) training.categories = categories;
    notifyListeners();
  }

  void addModule() {
    training.modules.add(Module(title: 'Novo Módulo'));
    notifyListeners();
  }

  void updateModuleTitle(Module module, String title) {
    module.title = title;
    notifyListeners();
  }

  void removeModule(Module module) {
    training.modules.remove(module);
    if (selectedSession != null) {
      bool sessionExists = training.modules.expand((m) => m.sessions).contains(selectedSession);
      if (!sessionExists) {
        selectedSession = null;
        selectedScreen = null;
      }
    }
    notifyListeners();
  }

  void addSessionToModule(Module module) {
    module.sessions.add(Session(title: 'Nova Aula'));
    notifyListeners();
  }

  void updateSessionTitle(Session session, String title) {
    session.title = title;
    notifyListeners();
  }

  void updateSessionSubtitle(Session session, String subtitle) {
    session.subtitle = subtitle;
    notifyListeners();
  }

  void removeSession(Module module, Session session) {
    module.sessions.remove(session);
    if (selectedSession == session) {
      selectedSession = null;
      selectedScreen = null;
    }
    notifyListeners();
  }

  void selectSession(Session session) {
    selectedSession = session;
    if (session.screens.isEmpty) {
      session.screens.add(ScreenModel(title: 'Tela 1'));
    }
    selectedScreen = session.screens.first;
    notifyListeners();
  }

  void addScreenToSession(Session session) {
    final newScreen = ScreenModel(title: 'Tela ${session.screens.length + 1}');
    session.screens.add(newScreen);
    selectedScreen = newScreen;
    notifyListeners();
  }

  void removeScreen(Session session, ScreenModel screen) {
    session.screens.remove(screen);
    if (selectedScreen == screen) {
      selectedScreen = session.screens.isNotEmpty ? session.screens.last : null;
    }
    notifyListeners();
  }

  void selectScreen(ScreenModel screen) {
    selectedScreen = screen;
    notifyListeners();
  }

  void addBlock(ContentBlock block) {
    if (selectedScreen != null) {
      selectedScreen!.contents.add(block);
      notifyListeners();
    }
  }

  void removeBlock(ContentBlock block) {
    if (selectedScreen != null) {
      selectedScreen!.contents.remove(block);
      notifyListeners();
    }
  }

  void reorderBlock(int oldIndex, int newIndex) {
    if (selectedScreen != null) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = selectedScreen!.contents.removeAt(oldIndex);
      selectedScreen!.contents.insert(newIndex, item);
      notifyListeners();
    }
  }

  void moveBlockUp(int index) {
    if (selectedScreen != null && index > 0 && index < selectedScreen!.contents.length) {
      final item = selectedScreen!.contents.removeAt(index);
      selectedScreen!.contents.insert(index - 1, item);
      notifyListeners();
    }
  }

  void moveBlockDown(int index) {
    if (selectedScreen != null && index >= 0 && index < selectedScreen!.contents.length - 1) {
      final item = selectedScreen!.contents.removeAt(index);
      selectedScreen!.contents.insert(index + 1, item);
      notifyListeners();
    }
  }

  void updateTitleBlock(TitleBlock block, String text) {
    block.text = text;
    notifyListeners();
  }

  void updateTitle2Block(Title2Block block, String text) {
    block.text = text;
    notifyListeners();
  }

  void updateDescriptionBlock(DescriptionBlock block, String text) {
    block.text = text;
    notifyListeners();
  }

  void updateHighlightedDescriptionBlock(HighlightedDescriptionBlock block, String text) {
    block.text = text;
    notifyListeners();
  }

  void updateImageBlock(ImageBlock block, String url) {
    block.imageUrl = url;
    notifyListeners();
  }

  void updateVideoBlock(VideoBlock block, String url) {
    block.videoUrl = url;
    notifyListeners();
  }
}
