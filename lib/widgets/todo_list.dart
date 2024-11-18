import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package
import '../screens/edit_todo_screen.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

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
        .orderBy('priority') // Sort by numerical priority
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

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            String priorityLabel = priorityMap.entries
                .firstWhere((entry) => entry.value == data['priority'])
                .key;
            DateTime dueDate = (data['dueDate'] as Timestamp).toDate();
            String formattedDate = DateFormat('HH:mm dd/MM/yyyy').format(dueDate);
            return ListTile(
              title: Text(data['title']),
              subtitle: Text('Priority: $priorityLabel\nDue Date: $formattedDate\n${data['description']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      FirebaseFirestore.instance.collection('todos').doc(document.id).delete();
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
