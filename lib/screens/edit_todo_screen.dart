import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTodoScreen extends StatefulWidget {
  final String id;
  final String currentTitle;
  final String currentDescription;

  const EditTodoScreen(this.id, this.currentTitle, this.currentDescription, {super.key});

  @override
  EditTodoScreenState createState() => EditTodoScreenState();
}

class EditTodoScreenState extends State<EditTodoScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.currentTitle);
    descriptionController = TextEditingController(text: widget.currentDescription);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text;
                final description = descriptionController.text;

                // Ensure this context is used in a synchronous part before async call
                if (title.isNotEmpty && description.isNotEmpty) {
                  final navigator = Navigator.of(context);

                  await FirebaseFirestore.instance.collection('todos').doc(widget.id).update({
                    'title': title,
                    'description': description,
                  });

                  if (mounted) {
                    navigator.pop();
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title and description.')),
                    );
                  }
                }
              },
              child: const Text('Update Todo'),
            ),
          ],
        ),
      ),
    );
  }
}
