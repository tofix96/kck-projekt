import 'package:http/http.dart' as http;
import 'dart:convert';

class ApplicationService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Map<String, dynamic>>> fetchApplicationsForTask(String taskId) async {
    final response = await http.get(Uri.parse('$baseUrl/applications?task_id=$taskId'));

    if (response.statusCode == 200) {
      List<dynamic> applicationsJson = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(applicationsJson);
    } else {
      throw Exception('Failed to load applications');
    }
  }

  Future<void> acceptApplication(String applicationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/applications/$applicationId'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'status': 'accepted',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept application');
    }
  }
}
