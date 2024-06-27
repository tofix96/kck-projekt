import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../providers/auth_provider.dart';

class WorkerAssignedTasksScreen extends StatelessWidget {
  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Assigned Tasks'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: taskService.fetchWorkerTasks(authProvider.user!['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks assigned'));
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task['title'] ?? 'No title'),
                  subtitle: Text(task['description'] ?? 'No description'),
                  trailing: Text('Status: ${task['status'] ?? 'No status'}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
