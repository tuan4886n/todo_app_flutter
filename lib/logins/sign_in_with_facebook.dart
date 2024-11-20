import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithFacebook() async {
  try {
    // Log out before attempting a new login
    await FacebookAuth.instance.logOut();
    debugPrint('Logged out of previous session.');

    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );
    debugPrint('Login result status: ${loginResult.status}');

    // Check the login status
    if (loginResult.status == LoginStatus.success) {
      debugPrint('Login was successful.');

      // Get the AccessToken object from the login result
      final accessToken = loginResult.accessToken;

      // Print the accessToken to the log for debugging purposes
      if (accessToken != null) {
        debugPrint('AccessToken: ${accessToken.tokenString}');
      } else {
        debugPrint('Failed to retrieve access token.');
      }

      // Create a credential from the AccessToken
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken!.tokenString);

      // Sign in with the credential and return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    } else {
      debugPrint('Login failed: ${loginResult.message}');
      throw FirebaseAuthException(
        code: 'ERROR_FACEBOOK_LOGIN_FAILED',
        message: loginResult.message,
      );
    }
  } catch (e) {
    debugPrint('Error: $e');
    throw FirebaseAuthException(
      code: 'ERROR_FACEBOOK_LOGIN_FAILED',
      message: e.toString(),
    );
  }
}
