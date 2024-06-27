import 'package:flutter/material.dart';
import '../services/task_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TaskDetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;
  final TaskService taskService = TaskService();

  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(task['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              task['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Description: ${task['description']}'),
            SizedBox(height: 16),
            Text('Budget: \$${task['budget']}'),
            SizedBox(height: 16),
            Text('Deadline: ${task['deadline']}'),
            SizedBox(height: 16),
            Text('Status: ${task['status']}'),
            SizedBox(height: 16),
            if (authProvider.user!['role'] == 'client' && task['status'] == 'pending') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/edit-task',
                    arguments: task,
                  );
                },
                child: Text('Edit Task'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await taskService.deleteTask(task['id']);
                  Navigator.pop(context);
                },
                child: Text('Delete Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
