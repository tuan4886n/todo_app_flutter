import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_todo_screen.dart';
import 'auth_screen.dart';
import '../widgets/todo_list.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  TodoListScreenState createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  String searchQuery = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: const InputDecoration(
              hintText: 'Search Todos...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.greenAccent),
            ),
            style: const TextStyle(color: Colors.greenAccent),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
              tooltip: 'Log Out',
            ),
          ],
        ),
        body: TodoList(searchQuery: searchQuery),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const AddTodoScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = 0.0;
                  const end = 1.0;
                  const curve = Curves.ease;

                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  final fadeAnimation = animation.drive(tween);

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
          tooltip: 'Add Todo',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
