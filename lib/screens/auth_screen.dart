import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../logins/sign_in_with_facebook.dart';
import '../logins/sign_in_with_github.dart';
import '../logins/sign_in_with_google.dart';
import 'todo_list_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isSignUp = false; // Set to false to show login screen first
  String errorMessage = '';

  // Create a logger instance
  final Logger _logger = Logger();

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  Future<void> _authenticate() async {
    setState(() {
      errorMessage = '';
    });

    if (!isValidEmail(emailController.text)) {
      setState(() {
        errorMessage = 'Invalid email format';
      });
      return;
    }

    if (passwordController.text.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters long';
      });
      return;
    }

    try {
      if (isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      }
      _logger.i("Authentication successful");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (
              context) => const TodoListScreen()), // Navigate to TodoListScreen on success
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      _logger.e("Authentication failed", e);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final UserCredential userCredential = await signInWithGoogle();
      _logger.i("Google Authentication successful: ${userCredential.user}");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TodoListScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      _logger.e("Google Authentication failed", e);
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final UserCredential userCredential = await signInWithFacebook();
      _logger.i("Facebook Authentication successful: ${userCredential.user}");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TodoListScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      _logger.e("Facebook Authentication failed", e);
    }
  }

  Future<void> _signInWithGitHub() async {
    try {
      final UserCredential userCredential = await signInWithGitHub();
      _logger.i("GitHub Authentication successful: ${userCredential.user}");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TodoListScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      _logger.e("GitHub Authentication failed", e);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to TodoApp',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.blue),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(isSignUp ? 'Sign Up' : 'Log In'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isSignUp = !isSignUp;
                  });
                },
                child: Text(isSignUp ? 'Already have an account? Log In' : 'Create an account'),
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _signInWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: _signInWithFacebook,
                    icon: Image.asset(
                      'assets/images/facebook_icon.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: _signInWithGitHub,
                    icon: Image.asset(
                      'assets/images/github_icon.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}
