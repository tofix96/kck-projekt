import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../providers/auth_provider.dart';
import 'view_applications_screen.dart';

class ClientTaskListScreen extends StatefulWidget {
  @override
  _ClientTaskListScreenState createState() => _ClientTaskListScreenState();
}

class _ClientTaskListScreenState extends State<ClientTaskListScreen> {
  final TaskService taskService = TaskService();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _refreshTasks() async {
    setState(() {});
  }

  Future<void> _completeTask(String taskId) async {
  try {
    await taskService.completeTask(taskId);
    print('tasksID: $taskId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task completed')),
    );
    String? workerid = await taskService.takeIdClient(taskId); // get workerid where taskid = $taskid and status = completed
    _showReviewDialog(taskId, workerid!);
    _refreshTasks();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error completing task: $e')),
    );
  }
}


   void _showReviewDialog(String taskId, String workerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Review'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: ratingController,
                  decoration: InputDecoration(labelText: 'Rating (1-5)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a rating';
                    }
                    final rating = int.tryParse(value);
                    if (rating == null || rating < 1 || rating > 5) {
                      return 'Please enter a valid rating between 1 and 5';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: commentController,
                  decoration: InputDecoration(labelText: 'Comment'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await taskService.addReview(
                      taskId,
                      Provider.of<AuthProvider>(context, listen: false).user!['id'].toString(),
                      workerId,
                      int.parse(ratingController.text),
                      commentController.text,
                    );
                    Navigator.of(context).pop(true); // Zwracamy true po dodaniu recenzji
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Review added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add review: $e')),
                    );
                  }
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        _refreshTasks(); // Odświeżenie zadań po dodaniu recenzji
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Client Task List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: taskService.fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks available'));
          } else {
            final tasks = snapshot.data!.where((task) => task['client_id'] == authProvider.user!['id']).toList();

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task['title']),
                  subtitle: Text(task['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Status: ${task['status']}'),
                      if (task['status'] == 'assigned')
                        TextButton(
                          onPressed: () {

                            _completeTask(task['id']);
                          },
                          child: Text('Complete'),
                        ),
                      if (task['status'] == 'accepted')
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewApplicationsScreen(taskId: task['id']),
                              ),
                            );
                            if (result == true) {
                              _refreshTasks();
                            }
                          },
                          child: Text('Aplikacje'),
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
