// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyByfr7uyTX8fq27CVfVfnsdQ97PRfRY_wg',
    appId: '1:218574771960:web:82f4704b8e9be8196e4d0d',
    messagingSenderId: '218574771960',
    projectId: 'semester-project-d4339',
    authDomain: 'semester-project-d4339.firebaseapp.com',
    databaseURL: 'https://semester-project-d4339-default-rtdb.firebaseio.com',
    storageBucket: 'semester-project-d4339.appspot.com',
    measurementId: 'G-PMBZ6P2TMS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqpw6Jf8OeRvHroRhrDKq9jmP-FA1OEt4',
    appId: '1:218574771960:android:4c607432110cd1b86e4d0d',
    messagingSenderId: '218574771960',
    projectId: 'semester-project-d4339',
    databaseURL: 'https://semester-project-d4339-default-rtdb.firebaseio.com',
    storageBucket: 'semester-project-d4339.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbV40zJ-GA-cJ2Pxu_b4vLPUxn4VjLePU',
    appId: '1:218574771960:ios:abf1e5006e3c0e326e4d0d',
    messagingSenderId: '218574771960',
    projectId: 'semester-project-d4339',
    databaseURL: 'https://semester-project-d4339-default-rtdb.firebaseio.com',
    storageBucket: 'semester-project-d4339.appspot.com',
    iosClientId: '218574771960-lidu9flim728833o97nb6l640cshqbnm.apps.googleusercontent.com',
    iosBundleId: 'com.example.maveshifinproj',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCbV40zJ-GA-cJ2Pxu_b4vLPUxn4VjLePU',
    appId: '1:218574771960:ios:abf1e5006e3c0e326e4d0d',
    messagingSenderId: '218574771960',
    projectId: 'semester-project-d4339',
    databaseURL: 'https://semester-project-d4339-default-rtdb.firebaseio.com',
    storageBucket: 'semester-project-d4339.appspot.com',
    iosClientId: '218574771960-lidu9flim728833o97nb6l640cshqbnm.apps.googleusercontent.com',
    iosBundleId: 'com.example.maveshifinproj',
  );
}