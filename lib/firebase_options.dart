import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return ios;
      case TargetPlatform.windows:
        return web;
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
    apiKey: 'AIzaSyAEf1L85LIGonn2ivz-gNpCBgOz2XQYy0M',
    appId: '1:974658039816:web:e102dbe24367498f8b61bd',
    messagingSenderId: '974658039816',
    projectId: 'qout-f853f',
    authDomain: 'qout-f853f.firebaseapp.com',
    storageBucket: 'qout-f853f.firebasestorage.app',
    measurementId: 'G-ZW8W5TZBRQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQssp6ASuH_YoOaq3AZXFy7CFhGrz2rHk',
    appId: '1:974658039816:android:6701b993fa6a2f488b61bd',
    messagingSenderId: '974658039816',
    projectId: 'qout-f853f',
    storageBucket: 'qout-f853f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAlQ43TYwTZzU4rtSIBzZIa2ozNi1RmR1g',
    appId: '1:974658039816:ios:9241f6d7a99daf428b61bd',
    messagingSenderId: '974658039816',
    projectId: 'qout-f853f',
    storageBucket: 'qout-f853f.firebasestorage.app',
    iosBundleId: 'com.example.qout',
  );
}
