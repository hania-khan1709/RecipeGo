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
    apiKey: 'AIzaSyCcR624ryjUX_Rzw-wrGxoChZrpVlduK2A',
    appId: '1:11301027606:web:1d293220cea32a037a9a37',
    messagingSenderId: '11301027606',
    projectId: 'mclab-42afd',
    authDomain: 'mclab-42afd.firebaseapp.com',
    databaseURL: 'https://mclab-42afd-default-rtdb.firebaseio.com',
    storageBucket: 'mclab-42afd.firebasestorage.app',
    measurementId: 'G-NQWCJXXY26',
  );

  // TODO: Replace with your Firebase Web configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCn06mL0hYnIzUeBRBhnD_-ReN6XPJCsYc',
    appId: '1:11301027606:android:e051e236998be0f97a9a37',
    messagingSenderId: '11301027606',
    projectId: 'mclab-42afd',
    databaseURL: 'https://mclab-42afd-default-rtdb.firebaseio.com',
    storageBucket: 'mclab-42afd.firebasestorage.app',
  );

  // TODO: Replace with your Firebase Android configuration

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDtV-QSrSaIOzMWFDQNOMrjXSeu1TMoqkc',
    appId: '1:11301027606:ios:608e10d035e361567a9a37',
    messagingSenderId: '11301027606',
    projectId: 'mclab-42afd',
    databaseURL: 'https://mclab-42afd-default-rtdb.firebaseio.com',
    storageBucket: 'mclab-42afd.firebasestorage.app',
    iosBundleId: 'com.example.untitled1',
  );

  // TODO: Replace with your Firebase iOS configuration

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDtV-QSrSaIOzMWFDQNOMrjXSeu1TMoqkc',
    appId: '1:11301027606:ios:608e10d035e361567a9a37',
    messagingSenderId: '11301027606',
    projectId: 'mclab-42afd',
    databaseURL: 'https://mclab-42afd-default-rtdb.firebaseio.com',
    storageBucket: 'mclab-42afd.firebasestorage.app',
    iosBundleId: 'com.example.untitled1',
  );

  // TODO: Replace with your Firebase macOS configuration

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCcR624ryjUX_Rzw-wrGxoChZrpVlduK2A',
    appId: '1:11301027606:web:805c0a08d6b01bf37a9a37',
    messagingSenderId: '11301027606',
    projectId: 'mclab-42afd',
    authDomain: 'mclab-42afd.firebaseapp.com',
    databaseURL: 'https://mclab-42afd-default-rtdb.firebaseio.com',
    storageBucket: 'mclab-42afd.firebasestorage.app',
    measurementId: 'G-QJH9G2GF68',
  );

}