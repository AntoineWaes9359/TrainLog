import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithApple() async {
    try {
      // Demander l'autorisation à Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Créer les credentials pour Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Se connecter à Firebase
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      print('Erreur lors de la connexion avec Apple: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialiser Google Sign In
      await GoogleSignIn.instance.initialize();

      // Authentifier avec Google
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        return null;
      }

      // Obtenir les headers d'autorisation pour Firebase
      final Map<String, String>? headers =
          await googleUser.authorizationClient.authorizationHeaders([]);

      if (headers == null) {
        print('Impossible d\'obtenir les headers d\'autorisation');
        return null;
      }

      // Créer les credentials pour Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: headers['Authorization']?.replaceFirst('Bearer ', ''),
        idToken: headers['X-Goog-ID-Token'],
      );

      // Se connecter à Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Erreur lors de la connexion avec Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn.instance.disconnect();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }
}
