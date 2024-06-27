import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../providers/auth_provider.dart';

class WorkerTaskListScreen extends StatefulWidget {
  @override
  _WorkerTaskListScreenState createState() => _WorkerTaskListScreenState();
}

class _WorkerTaskListScreenState extends State<WorkerTaskListScreen> {
  final TaskService taskService = TaskService();
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = taskService.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Available Tasks'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks available'));
          } else {
            final tasks = snapshot.data!
                .where((task) => task['status'] == 'approved' || task['status'] == 'accepted')
                .toList();
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return FutureBuilder<bool>(
                  future: taskService.hasWorkerAppliedForTask(
                      task['id'], authProvider.user!['id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final hasApplied = snapshot.data ?? false;
                      return ListTile(
                        title: Text(task['title']),
                        subtitle: Text(task['description']),
                        trailing: ElevatedButton(
                          onPressed: hasApplied
                              ? null
                              : () async {
                                  final success = await taskService.applyForTask(
                                      task['id'], authProvider.user!['id']);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Applied for task')),
                                    );
                                    setState(() {
                                      _tasksFuture = taskService.fetchTasks();
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to apply for task')),
                                    );
                                  }
                                },
                          child: Text(hasApplied ? 'Applied' : 'Apply'),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
