import 'package:flutter/material.dart';
import '../services/task_service.dart';

class ModeratorTaskListScreen extends StatefulWidget {
  const ModeratorTaskListScreen({super.key});

  @override
  _ModeratorTaskListScreenState createState() => _ModeratorTaskListScreenState();
}

class _ModeratorTaskListScreenState extends State<ModeratorTaskListScreen> {
  final TaskService taskService = TaskService();

  Future<void> _refreshTasks() async {
    setState(() {});
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await taskService.deleteTask(taskId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted')),
      );
      _refreshTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderator Task List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: taskService.fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks available'));
          } else {
            final tasks = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshTasks,
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task['title']),
                    subtitle: Text(task['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task['status'] == 'pending')
                          ElevatedButton(
                            onPressed: () async {
                              await taskService.updateTaskStatus(task['id'], 'accepted');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Task accepted')),
                              );
                              _refreshTasks();
                            },
                            child: const Text('Accept'),
                          ),
                         Text('Status: ${task['status']}'),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteTask(task['id']);
                          },
                          color: Colors.red,
                        ),

                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
