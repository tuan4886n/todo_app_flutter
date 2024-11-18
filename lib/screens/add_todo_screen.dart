import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  AddTodoScreenState createState() => AddTodoScreenState();
}

class AddTodoScreenState extends State<AddTodoScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String _priority = 'Medium'; // Default priority
  DateTime? _dueDate; // Due date field

  Map<String, int> priorityMap = {
    'High': 1,
    'Medium': 2,
    'Low': 3,
  };

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _addTodo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('todos').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'priority': priorityMap[_priority], // Store numerical priority
        'dueDate': _dueDate ?? DateTime.now(), // Store due date or default to current date/time
        'userId': user.uid,
      });

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
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
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: priorityMap.keys
                  .map((priority) => DropdownMenuItem(
                value: priority,
                child: Text(priority),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _priority = value ?? 'Medium';
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDueDate(context),
              child: Text(_dueDate == null ? 'Select Due Date' : DateFormat('HH:mm dd/MM/yyyy').format(_dueDate!)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTodo,
              child: const Text('Add Todo'),
            ),
          ],
        ),
      ),
    );
  }
}
