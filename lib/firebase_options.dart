import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAO4IZnMdJQLA8ZX8u0RJqYs5W5Xfb_WZg',
    appId: '1:241545225297:web:18c1770aadacfd1bce8470',
    messagingSenderId: '241545225297',
    projectId: 'hanasasou-gallery',
    authDomain: 'hanasasou-gallery.firebaseapp.com',
    storageBucket: 'hanasasou-gallery.firebasestorage.app',
  );
}

