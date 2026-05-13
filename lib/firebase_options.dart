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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAFEcyB5X8n4VM0hMhwzI2Kd-5mwIcbBNM',
    appId: '1:27742527594:web:e5b8bef28d4c865ce1aa13',
    messagingSenderId: '27742527594',
    projectId: 'fitness-tracker-app-8deb3',
    authDomain: 'fitness-tracker-app-8deb3.firebaseapp.com',
    storageBucket: 'fitness-tracker-app-8deb3.firebasestorage.app',
    measurementId: 'G-BM25VTZ218',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6VpU7T974D7ceAUw5iZdIzH9d--0B9bw',
    appId: '1:27742527594:android:2b4a4675f956087ee1aa13',
    messagingSenderId: '27742527594',
    projectId: 'fitness-tracker-app-8deb3',
    storageBucket: 'fitness-tracker-app-8deb3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC0N8SxqxYhZxj4pt9LGnjMGuxpi3Njotw',
    appId: '1:27742527594:ios:64d5fd61013c7162e1aa13',
    messagingSenderId: '27742527594',
    projectId: 'fitness-tracker-app-8deb3',
    storageBucket: 'fitness-tracker-app-8deb3.firebasestorage.app',
    iosBundleId: 'com.example.fitnessTrackerApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC0N8SxqxYhZxj4pt9LGnjMGuxpi3Njotw',
    appId: '1:27742527594:ios:64d5fd61013c7162e1aa13',
    messagingSenderId: '27742527594',
    projectId: 'fitness-tracker-app-8deb3',
    storageBucket: 'fitness-tracker-app-8deb3.firebasestorage.app',
    iosBundleId: 'com.example.fitnessTrackerApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAFEcyB5X8n4VM0hMhwzI2Kd-5mwIcbBNM',
    appId: '1:27742527594:web:7340b05bfc555db2e1aa13',
    messagingSenderId: '27742527594',
    projectId: 'fitness-tracker-app-8deb3',
    authDomain: 'fitness-tracker-app-8deb3.firebaseapp.com',
    storageBucket: 'fitness-tracker-app-8deb3.firebasestorage.app',
    measurementId: 'G-PT59C1EQNV',
  );
}