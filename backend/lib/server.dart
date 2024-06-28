import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';


final _headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Headers': 'Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale',
  'Access-Control-Allow-Methods': 'POST,GET,OPTIONS,DELETE,PUT'
};

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

final dbConnection = PostgreSQLConnection(
  'localhost', // Host
  5432, // Port
  'outsource_it_db', // Database name
  username: 'postgres', // Your database username
  password: 'zaq1@WSX', // Your database password
);

void main() async {
  try {
    await dbConnection.open();
    print('Connected to database');
  } catch (e) {
    print('Error connecting to database: $e');
    return;
  }

  final router = Router()
    ..get('/tasks', (Request request) async {
      try {
        final result = await dbConnection.query('SELECT * FROM tasks');
        final tasks = result.map((row) {
          return {
            'id': row[0].toString(),
            'title': row[1],
            'description': row[2],
            'budget': row[3].toString(),
            'deadline': row[4].toIso8601String(),
            'status': row[5],
            'client_id': row[6].toString(),
          };
        }).toList();

        final tasksString = jsonEncode(tasks);
        return Response.ok(tasksString, headers: _headers);
      } catch (e) {
        print('Error fetching tasks: $e');
        return Response.internalServerError(body: 'Error fetching tasks');
      }
    })
    ..post('/tasks', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = Uri.splitQueryString(payload);

        final title = data['title']!;
        final description = data['description']!;
        final budget = double.parse(data['budget']!);
        final deadline = DateTime.parse(data['deadline']!);
        final clientId = data['client_id']!;

        await dbConnection.query(
          'INSERT INTO tasks (title, description, budget, deadline, client_id, status) VALUES (@title, @description, @budget, @deadline, @client_id, @status)',
          substitutionValues: {
            'title': title,
            'description': description,
            'budget': budget,
            'deadline': deadline,
            'client_id': int.parse(clientId),
            'status': 'pending',
          },
        );

        return Response.ok('Task created', headers: _headers);
      } catch (e) {
        print('Error creating task: $e');
        return Response.internalServerError(body: 'Error creating task');
      }
    })

     ..post('/login', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = Uri.splitQueryString(payload);
        final email = data['email']!;
        final password = hashPassword(data['password']!);

        final result = await dbConnection.query(
          'SELECT * FROM users WHERE email = @Email AND password = @Password',
          substitutionValues: {
            'Email': email,
            'Password': password,
          },
        );

        if (result.isNotEmpty) {
          final user = result.first;
          final userMap = {
            'id': user[0].toString(),
            'email': user[1],
            'name': user[3],
            'role': user[4],
            'phone_number': user[6],
            'age': user[5]?.toString(),
          };

          return Response.ok(jsonEncode(userMap), headers: _headers);
        } else {
          return Response.forbidden('Invalid email or password');
        }
      } catch (e) {
        print('Error logging in: $e');
        return Response.internalServerError(body: 'Error logging in');
      }
    })
         ..post('/register', (Request request) async {
          try {
            final payload = await request.readAsString();
            final data = Uri.splitQueryString(payload);

            final email = data['email']!;
            final password = data['password']!;
            final name = data['name']!;
            final role = data['role']!;
            final phoneNumber = data['phone_number']!;
            final age = int.parse(data['age']!);

            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegex.hasMatch(email)) {
              return Response.badRequest(body: 'Invalid email format');
            }

            if (password.length < 8) {
              return Response.badRequest(body: 'Password too short');
            }

            final hashedPassword = hashPassword(password);

            await dbConnection.query(
              'INSERT INTO users (email, password, name, role, phone_number, age) VALUES (@Email, @Password, @Name, @Role, @PhoneNumber, @Age)',
              substitutionValues: {
                'Email': email,
                'Password': hashedPassword,
                'Name': name,
                'Role': role,
                'PhoneNumber': phoneNumber,
                'Age': age,
              },
            );

            return Response.ok('User registered', headers: _headers);
          } catch (e) {
            print('Error registering user: $e');
            return Response.internalServerError(body: 'Error registering user');
          }
        })


    ..put('/tasks/<id>', (Request request, String id) async {
  try {
    final payload = await request.readAsString();
    final data = Uri.splitQueryString(payload);

    final status = data['status'];

    await dbConnection.query(
      'UPDATE tasks SET status = @status WHERE id = @id',
      substitutionValues: {
        'status': status,
        'id': int.parse(id),
      },
    );

    // Fetch worker_id for review
    final result = await dbConnection.query(
      'SELECT worker_id FROM applications WHERE task_id = @task_id AND status = @status',
      substitutionValues: {
        'task_id': int.parse(id),
        'status': 'assigned',
      },
    );

    final workerId = result.isNotEmpty ? result.first[0] : null;
    return Response.ok(jsonEncode({'worker_id': workerId}), headers: _headers);
  } catch (e) {
    print('Error updating task: $e');
    return Response.internalServerError(body: 'Error updating task');
  }
})

    //Kończenie zadań
   ..put('/tasks/<id>/complete', (Request request, String id) async {
  try {
    await dbConnection.query(
      'UPDATE tasks SET status = @status WHERE id = @id',
      substitutionValues: {
        'status': 'completed',
        'id': int.parse(id),
      },
    );

    await dbConnection.query(
      'UPDATE applications SET status = @status WHERE task_id = @task_id',
      substitutionValues: {
        'status': 'completed',
        'task_id': int.parse(id),
      },
    );

    return Response.ok('Task and applications completed', headers: _headers);
  } catch (e) {
    print('Error completing task: $e');
    return Response.internalServerError(body: 'Error completing task');
  }
})
  ..delete('/tasks/<id>', (Request request, String id) async {
    try {
      // Usuń powiązane aplikacje
      await dbConnection.query(
        'DELETE FROM applications WHERE task_id = @id',
        substitutionValues: {
          'id': int.parse(id),
        },
      );
       await dbConnection.query(
          'DELETE FROM reviews WHERE task_id = @id',
          substitutionValues: {
            'id': int.parse(id),
          },
        );
      // Usuń zadanie
      await dbConnection.query(
        'DELETE FROM tasks WHERE id = @id',
        substitutionValues: {
          'id': int.parse(id),
        },
      );

      return Response.ok('Task and related applications deleted', headers: _headers);
    } catch (e) {
      print('Error deleting task and related applications: $e');
      return Response.internalServerError(body: 'Error deleting task and related applications');
    }
  })

      ..get('/applications', (Request request) async {
  final taskId = request.url.queryParameters['task_id'];
  final workerId = request.url.queryParameters['worker_id'];
  final status = request.url.queryParameters['status'];

  if (taskId == null && workerId == null) {
    return Response.badRequest(body: 'Missing task_id or worker_id');
  }

  try {
    List<List<dynamic>> result = [];
    if (taskId != null && workerId == null) {
      final query = status != null
          ? 'SELECT applications.id, users.name AS worker_name, applications.status, applications.worker_id FROM applications JOIN users ON applications.worker_id = users.id WHERE applications.task_id = @task_id AND applications.status = @status'
          : 'SELECT applications.id, users.name AS worker_name, applications.status, applications.worker_id FROM applications JOIN users ON applications.worker_id = users.id WHERE applications.task_id = @task_id';
      result = await dbConnection.query(
        query,
        substitutionValues: {
          'task_id': int.parse(taskId),
          'status': status,
        },
      );
    } else if (workerId != null && taskId == null) {
      result = await dbConnection.query(
        'SELECT tasks.id, tasks.title, tasks.description, tasks.budget, tasks.deadline, applications.status FROM applications JOIN tasks ON applications.task_id = tasks.id WHERE applications.worker_id = @worker_id',
        substitutionValues: {'worker_id': int.parse(workerId)},
      );
    } else if (taskId != null && workerId != null) {
      result = await dbConnection.query(
        'SELECT * FROM applications WHERE task_id = @task_id AND worker_id = @worker_id',
        substitutionValues: {
          'task_id': int.parse(taskId),
          'worker_id': int.parse(workerId),
        },
      );
    }

    final applications = result.map((row) {
      if (taskId != null && workerId == null) {
        return {
          'id': row[0].toString(),
          'worker_name': row[1],
          'status': row[2],
          'worker_id': row[3].toString(),
        };
      } else if (workerId != null && taskId == null) {
        return {
          'id': row[0].toString(),
          'title': row[1],
          'description': row[2],
          'budget': row[3].toString(),
          'deadline': row[4].toIso8601String(),
          'status': row[5],
        };
      } else {
        return {
          'id': row[0].toString(),
          'task_id': row[1].toString(),
          'worker_id': row[2].toString(),
          'status': row[3],
        };
      }
    }).toList();

    final applicationsString = jsonEncode(applications);
    return Response.ok(applicationsString, headers: _headers);
  } catch (e) {
    print('Error fetching applications: $e');
    return Response.internalServerError(body: 'Error fetching applications');
  }
})



  ..post('/reviews', (Request request) async {
  try {
    final payload = await request.readAsString();
    final data = Uri.splitQueryString(payload);

    print('Received data: $data');

    final taskId = int.parse(data['task_id']!);
    final clientId = int.parse(data['client_id']!);
    final workerId = int.parse(data['worker_id']!);
    final rating = int.parse(data['rating']!);
    final comment = data['comment'] ?? '';

    await dbConnection.query(
      'INSERT INTO reviews (task_id, client_id, worker_id, rating, comment) VALUES (@task_id, @client_id, @worker_id, @rating, @comment)',
      substitutionValues: {
        'task_id': taskId,
        'client_id': clientId,
        'worker_id': workerId,
        'rating': rating,
        'comment': comment,
      },
    );

    return Response.ok('Review added', headers: _headers);
  } catch (e) {
    print('Error adding review: $e');
    return Response.internalServerError(body: 'Error adding review');
  }
})

  //wyświetlanie aplikacji

    ..post('/applications', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = Uri.splitQueryString(payload);

        final taskId = data['task_id']!;
        final workerId = data['worker_id']!;

        final existingApplication = await dbConnection.query(
          'SELECT * FROM applications WHERE task_id = @task_id AND worker_id = @worker_id',
          substitutionValues: {
            'task_id': int.parse(taskId),
            'worker_id': int.parse(workerId),
          },
        );

        if (existingApplication.isNotEmpty) {
          return Response.badRequest(body: 'Worker has already applied for this task');
        }

        await dbConnection.query(
          'INSERT INTO applications (task_id, worker_id, status) VALUES (@task_id, @worker_id, @status)',
          substitutionValues: {
            'task_id': int.parse(taskId),
            'worker_id': int.parse(workerId),
            'status': 'applied',
          },
        );

        return Response.ok('Application created', headers: _headers);
      } catch (e) {
        print('Error creating application: $e');
        return Response.internalServerError(body: 'Error creating application');
      }
    })
     ..put('/applications/<id>', (Request request, String id) async {
      try {
        // Pobierz id zadania na podstawie aplikacji
        final taskResult = await dbConnection.query(
          'SELECT task_id FROM applications WHERE id = @id',
          substitutionValues: {'id': int.parse(id)},
        );

        if (taskResult.isEmpty) {
          return Response.badRequest(body: 'Application not found');
        }

        final taskId = taskResult.first[0];

        // Sprawdź, czy zadanie jest już przypisane
        final existingTask = await dbConnection.query(
          'SELECT * FROM applications WHERE task_id = @task_id AND status = @status',
          substitutionValues: {
            'task_id': taskId,
            'status': 'assigned',
          },
        );

        if (existingTask.isNotEmpty) {
          return Response.badRequest(body: 'Task is already assigned to another worker');
        }

        // Zaktualizowanie statusu aplikacji na 'accepted'
        await dbConnection.query(
          'UPDATE applications SET status = @status WHERE id = @id',
          substitutionValues: {
            'status': 'accepted',
            'id': int.parse(id),
          },
        );

        // Zaktualizowanie statusu zadania na 'assigned'
        await dbConnection.query(
          'UPDATE tasks SET status = @status WHERE id = @taskId',
          substitutionValues: {
            'status': 'assigned',
            'taskId': taskId,
          },
        );

        return Response.ok('Application updated', headers: _headers);
      } catch (e) {
        print('Error updating application: $e');
        return Response.internalServerError(body: 'Error updating application');
      }
    })
   ..get('/users/<id>/average-rating', (Request request, String id) async {
  try {
    final result = await dbConnection.query(
      'SELECT AVG(rating) FROM reviews WHERE worker_id = @id',
      substitutionValues: {
        'id': int.parse(id),
      },
    );

    if (result.isNotEmpty && result.first[0] != null) {
      final averageRating = double.parse(result.first[0].toString());
      return Response.ok(jsonEncode({'average_rating': averageRating}), headers: _headers);
    } else {
      return Response.ok(jsonEncode({'average_rating': 0.0}), headers: _headers);
    }
  } catch (e) {
    print('Error fetching average rating: $e');
    return Response.internalServerError(body: 'Error fetching average rating');
  }
})


    ..get('/users/<id>', (Request request, String id) async {
  try {
    final result = await dbConnection.query(
      'SELECT * FROM users WHERE id = @id',
      substitutionValues: {
        'id': int.parse(id),
      },
    );

    if (result.isNotEmpty) {
      final user = result.first;
      final userMap = {
        'id': user[0].toString(),
        'email': user[1] ?? '',
        'name': user[3] ?? '',
        'role': user[4] ?? '',
        'phone_number': user[5] ?? '',
        'age': user[6]?.toString() ?? '',
      };

      return Response.ok(jsonEncode(userMap), headers: _headers);
    } else {
      return Response.notFound('User not found');
    }
  } catch (e) {
    print('Error fetching user details: $e');
    return Response.internalServerError(body: 'Error fetching user details');
  }
});


  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: _headers))
      .addHandler(router);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}