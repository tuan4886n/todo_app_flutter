import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../screens/edit_todo_screen.dart';

class TodoList extends StatelessWidget {
  final String searchQuery;

  const TodoList({super.key, required this.searchQuery});

  final Map<String, int> priorityMap = const {
    'High': 1,
    'Medium': 2,
    'Low': 3,
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    final Stream<QuerySnapshot> todoStream = FirebaseFirestore.instance
        .collection('todos')
        .where('userId', isEqualTo: user.uid)
        .orderBy('priority')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: todoStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final todos = snapshot.data!.docs.where((doc) {
          final data = doc.data()! as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          final description = data['description']?.toString().toLowerCase() ?? '';
          return title.contains(searchQuery) || description.contains(searchQuery);
        }).toList();

        return ListView(
          children: todos.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            String priorityLabel = priorityMap.entries
                .firstWhere((entry) => entry.value == data['priority'])
                .key;
            DateTime dueDate = (data['dueDate'] as Timestamp).toDate();
            String formattedDate = DateFormat('HH:mm dd/MM/yyyy').format(dueDate);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(
                  data['title'],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(  // Adjusted to make title more prominent
                    decoration: (data['completed'] ?? false) ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                subtitle: Text('Priority: $priorityLabel\nDue Date: $formattedDate\n${data['description']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: data['completed'] ?? false,
                      onChanged: (bool? value) {
                        FirebaseFirestore.instance.collection('todos').doc(document.id).update({'completed': value});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTodoScreen(document.id, data['title'], data['description']),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text('Are you sure you want to delete this todo?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance.collection('todos').doc(document.id).delete();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
