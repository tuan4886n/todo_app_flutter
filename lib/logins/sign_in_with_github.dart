import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';

Future<UserCredential> signInWithGitHub() async {
  await FirebaseAuth.instance.signOut();

  final Uri gitHubAuthUrl = Uri.https('github.com', '/login/oauth/authorize', {
    'client_id': 'Ov23li9IkiMpUekprwtJ',
    'scope': 'read:user user:email',
  });

  // Open the URL in a web view or browser
  final result = await FlutterWebAuth.authenticate(
      url: gitHubAuthUrl.toString(),
      callbackUrlScheme: "todoapp"
  );

  // Extract code from result URL
  final code = Uri.parse(result).queryParameters['code'];

  // Use the code to get the access token from GitHub
  final response = await http.post(
    Uri.https('github.com', '/login/oauth/access_token'),
    headers: {
      'Accept': 'application/json',
    },
    body: {
      'client_id': 'Ov23li9IkiMpUekprwtJ',
      'client_secret': '9a7ff2543ad7f141bdaaee4672674fd234469d90',
      'code': code,
    },
  );

  final accessToken = json.decode(response.body)['access_token'];

  // Use the access token to sign in with Firebase
  final AuthCredential credential = GithubAuthProvider.credential(accessToken);
  return FirebaseAuth.instance.signInWithCredential(credential);
}
