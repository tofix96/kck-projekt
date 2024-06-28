import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:inzynier/services/task_service.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient mockClient;
  late TaskService taskService;

  setUp(() {
    mockClient = MockClient();
    taskService = TaskService(client: mockClient);
  });

  test('fetchTasks returns list of tasks', () async {
    const response = '{"tasks": [{"id": "1", "title": "Task 1", "description": "Description 1"}]}';
    when(mockClient.get(Uri.parse('http://localhost:8080/tasks')))
        .thenAnswer((_) async => http.Response(response, 200));

    final tasks = await taskService.fetchTasks();

    expect(tasks, isA<List<Map<String, dynamic>>>());
    expect(tasks[0]['title'], 'Task 1');
  });
}
