import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return web; // As APIs REST/Firestore do Firebase utilizam as chaves do projeto
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBTMx6HSuRO1VXRA1zLMVw5wGI8fB-CExo',
    appId: '1:495141513520:web:1474a35e6b1396d45340f5',
    messagingSenderId: '495141513520',
    projectId: 'man-hub-c0bef',
    authDomain: 'man-hub-c0bef.firebaseapp.com',
    storageBucket: 'man-hub-c0bef.firebasestorage.app',
    measurementId: 'G-Q1B137M3BS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8mJIcIkghuugvu-kHQby3RBnz9f97uZo',
    appId: '1:495141513520:android:3f760fbd7d25b62e5340f5',
    messagingSenderId: '495141513520',
    projectId: 'man-hub-c0bef',
    storageBucket: 'man-hub-c0bef.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC499lCUYpcbLG3_YdK674I6xvCmoftkks',
    appId: '1:495141513520:ios:8940410af2d3f3915340f5',
    messagingSenderId: '495141513520',
    projectId: 'man-hub-c0bef',
    storageBucket: 'man-hub-c0bef.firebasestorage.app',
    iosBundleId: 'com.example.manHubApp',
  );
}