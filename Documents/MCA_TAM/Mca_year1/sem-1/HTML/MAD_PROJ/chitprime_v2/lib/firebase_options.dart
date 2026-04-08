import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAKPuM1ISPArmg60RiIAzKjDvjrj-QeBgE',
    appId: '1:450650002313:web:298dcace89654fb25d8758',
    messagingSenderId: '450650002313',
    projectId: 'chitprime-abb5f',
    authDomain: 'chitprime-abb5f.firebaseapp.com',
    databaseURL: 'https://chitprime-abb5f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chitprime-abb5f.firebasestorage.app',
    measurementId: 'G-B4D823TCEG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcYpngpJOr7ixdBZSBdOTGKRWtzkdVd4c',
    appId: '1:450650002313:android:c3ad845018b181185d8758',
    messagingSenderId: '450650002313',
    projectId: 'chitprime-abb5f',
    databaseURL: 'https://chitprime-abb5f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chitprime-abb5f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKPuM1ISPArmg60RiIAzKjDvjrj-QeBgE',
    authDomain: 'chitprime-abb5f.firebaseapp.com',
    databaseURL: 'https://chitprime-abb5f-default-rtdb.asia-southeast1.firebasedatabase.app',
    projectId: 'chitprime-abb5f',
    storageBucket: 'chitprime-abb5f.firebasestorage.app',
    messagingSenderId: '450650002313',
    appId: '1:450650002313:web:298dcace89654fb25d8758',
    iosBundleId: 'com.chitprime.chitprimeV2',
  );
}