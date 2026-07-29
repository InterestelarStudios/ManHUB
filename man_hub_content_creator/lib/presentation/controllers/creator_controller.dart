import 'package:flutter/foundation.dart';
import '../../domain/models/content_block.dart';
import '../../domain/models/screen_model.dart';
import '../../domain/models/session.dart';
import '../../domain/models/module.dart';
import '../../domain/models/training.dart';

class CreatorController extends ChangeNotifier {
  Training training = Training(title: 'Jornada do Homem de Valor');
  Session? selectedSession;
  ScreenModel? selectedScreen;

  void updateTrainingTitle(String newTitle) {
    training.title = newTitle;
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
