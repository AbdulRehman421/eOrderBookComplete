
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
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


  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBP4LUTGd9JR9FSEngIVdR5NqioSFv_PpA',
    appId: '1:634175054526:android:c607aa0597545e7edcb4ef',
    messagingSenderId: '634175054526',
    projectId: 'eorderbook-d5930',
    storageBucket: 'eorderbook-d5930.appspot.com',
  );



}
//apiid : 1:634175054526:android:c607aa0597545e7edcb4ef
//webapikey : AIzaSyBP4LUTGd9JR9FSEngIVdR5NqioSFv_PpA