import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskService {
  static const String baseUrl = 'http://localhost:8080';
  final http.Client client;

  TaskService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final response = await client.get(Uri.parse('$baseUrl/tasks'));

    if (response.statusCode == 200) {
      List<dynamic> tasksJson = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(tasksJson);
    } else {
      throw Exception('Failed to load tasks');
    }
  }
  Future<void> createTask(String title, String description, double budget,
      DateTime deadline, String clientId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'title': title,
        'description': description,
        'budget': budget.toString(),
        'deadline': deadline.toIso8601String(),
        'client_id': clientId,
        'status': 'pending', // Nowe zadania mają status 'pending'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTask(String taskId, String title, String description,
      double budget, DateTime deadline) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'title': title,
        'description': description,
        'budget': budget.toString(),
        'deadline': deadline.toIso8601String(),
        'status': 'pending',
        // Zakładamy, że zadania po aktualizacji mają status 'pending'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$taskId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  Future<void> addReview(String taskId, String clientId, String workerId,
      int rating, String comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'task_id': taskId,
        'client_id': clientId,
        'worker_id': workerId,
        'rating': rating.toString(),
        'comment': comment,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add review');
    }
  }

  Future<String?> getWorkerIdForTask(String taskId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/applications?task_id=$taskId&status=assigned'));

    if (response.statusCode == 200) {
      List<dynamic> applicationsJson = jsonDecode(response.body);
      if (applicationsJson.isNotEmpty) {
        return applicationsJson.first['worker_id'].toString();
      }
    } else {
      throw Exception('Failed to fetch worker ID for task');
    }
    return null;
  }


  Future<bool> applyForTask(String taskId, String workerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applications'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'task_id': taskId,
        'worker_id': workerId,
      },
    );

    return response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> fetchWorkerTasks(String workerId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/applications?worker_id=$workerId'));

    if (response.statusCode == 200) {
      List<dynamic> tasksJson = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(tasksJson);
    } else {
      throw Exception('Failed to load worker tasks');
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'status': status,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task status');
    }
  }

  Future<List<Map<String, dynamic>>> fetchApplications(String taskId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/applications?task_id=$taskId'));

    if (response.statusCode == 200) {
      List<dynamic> applicationsJson = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(applicationsJson);
    } else {
      if (response.body == 'Task is already assigned') {
        throw Exception('Task is already assigned');
      }
      throw Exception('Failed to load applications');
    }
  }

  Future<void> assignWorkerToTask(String applicationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/applications/$applicationId'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign worker to task');
    }
  }

  Future<void> completeTask(String taskId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId/complete'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'status': 'completed',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete task');
    }
  }

  Future<String?> takeIdClient(String taskId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/applications?task_id=$taskId&status=completed'));

    if (response.statusCode == 200) {
      List<dynamic> applicationsJson = jsonDecode(response.body);
      if (applicationsJson.isNotEmpty) {
        return applicationsJson.first['worker_id'].toString();
      }
    } else {
      throw Exception('Failed to fetch worker ID for task');
    }
    return null;
  }

  Future<bool> hasWorkerAppliedForTask(String taskId, String workerId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/applications?task_id=$taskId&worker_id=$workerId'));

    if (response.statusCode == 200) {
      List<dynamic> applicationsJson = jsonDecode(response.body);
      return applicationsJson.isNotEmpty;
    } else {
      throw Exception('Failed to check application status');
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch user details');
    }
  }

  Future<double> getAverageRating(String userId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/average-rating'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['average_rating'];
    } else {
      throw Exception('Failed to fetch average rating');
    }
  }
}
