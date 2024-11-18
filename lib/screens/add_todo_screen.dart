import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize time zones
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (!mounted) return; // Ensure the widget is still mounted

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _dueDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute
          );
        });
      }
    }
  }

  Future<void> _scheduleNotification(String title, DateTime dueDate) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dueDate, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'your_channel_id', 'your_channel_name', channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Todo Reminder: $title', // Notification Title
      'Your todo is due soon!', // Notification Body
      scheduledDate, // Scheduled DateTime in local time zone
      platformChannelSpecifics, // Notification Details
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Ensure notification matches the time component
    );
  }

  Future<void> _addTodo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dueDate = _dueDate ?? DateTime.now();
      await FirebaseFirestore.instance.collection('todos').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'priority': priorityMap[_priority], // Store numerical priority
        'dueDate': dueDate, // Store due date or default to current date/time
        'userId': user.uid,
      });

      // Schedule notification with the selected due date
      await _scheduleNotification(titleController.text, dueDate);

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
              onPressed: _selectDueDate,
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
