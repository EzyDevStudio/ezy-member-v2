import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool isInit = false;

  static Future<void> init() async {
    if (!isInit) {
      await _googleSignIn.initialize(serverClientId: kIsWeb ? null : "551410384420-mk3vpiukav7mnnr1ltksjk4l5mdbcjb6.apps.googleusercontent.com");
    }

    isInit = true;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await init();

      if (kIsWeb) {
        final GoogleAuthProvider provider = GoogleAuthProvider();

        provider.addScope("email");
        provider.addScope("profile");

        return await _auth.signInWithPopup(provider);
      } else {
        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
        final idToken = googleUser.authentication.idToken;
        final authorizationClient = googleUser.authorizationClient;

        GoogleSignInClientAuthorization? authorization = await authorizationClient.authorizationForScopes(["email", "profile"]);

        final accessToken = authorization?.accessToken;

        if (accessToken == null) {
          final tmpAuthorization = await authorizationClient.authorizationForScopes(["email", "profile"]);

          if (tmpAuthorization?.accessToken == null) throw FirebaseAuthException(code: "error", message: "error");

          authorization = tmpAuthorization;
        }

        final credential = GoogleAuthProvider.credential(accessToken: accessToken, idToken: idToken);
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        return userCredential;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      if (!kIsWeb) await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
