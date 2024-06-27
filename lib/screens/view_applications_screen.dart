import 'package:flutter/material.dart';
import '../services/task_service.dart';

class ViewApplicationsScreen extends StatelessWidget {
  final String taskId;

  ViewApplicationsScreen({required this.taskId});

  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Applications'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: taskService.fetchApplications(taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No applications found'));
          } else {
            final applications = snapshot.data!;
            return ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                print('Application data: $application');
                return ListTile(
                  title: Text(application['worker_name']),
                  subtitle: Text('Status: ${application['status']}'),
                  trailing: ElevatedButton(
                    onPressed: application['status'] == 'accepted' || application['status'] == 'assigned'
                        ? null
                        : () async {
                            await taskService.assignWorkerToTask(application['id']);
                            Navigator.pop(context, true);
                          },
                    child: Text('Assign'),
                  ),
                  onTap: () async {
                    try {
                      final userDetails = await taskService.getUserDetails(application['worker_id']);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Worker Details'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Name: ${userDetails['name'] ?? 'N/A'}'),
                                Text('Email: ${userDetails['email'] ?? 'N/A'}'),
                                Text('Phone Number: ${userDetails['phone_number'] ?? 'N/A'}'),
                                Text('Age: ${userDetails['age'] ?? 'N/A'}'),
                              ],
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Chat'),
                              )
                            ],
                          );
                        },
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error fetching user details: $e')),
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
