import 'package:postgres/postgres.dart';

Future<void> main() async {
  final dbConnection = PostgreSQLConnection(
    'localhost', // Host
    5432, // Port
    'outsource_it_db', // Database name
    username: 'postgres', // Your database username
    password: 'zaq1@WSX', // Your database password
  );

  await dbConnection.open();

  // Create tasks table with client_id
  await dbConnection.query('''
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      budget DOUBLE PRECISION NOT NULL,
      deadline TIMESTAMP NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      client_id INTEGER NOT NULL
    )
  ''');

  // Create users table if not exists
  await dbConnection.query('''
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      name TEXT NOT NULL,
      role TEXT NOT NULL
    )
  ''');

  // Create applications table if not exists
  await dbConnection.query('''
    CREATE TABLE IF NOT EXISTS applications (
      id SERIAL PRIMARY KEY,
      task_id INTEGER NOT NULL REFERENCES tasks(id),
      worker_id INTEGER NOT NULL REFERENCES users(id),
      status TEXT NOT NULL DEFAULT 'applied'
    )
  ''');
  await dbConnection.query('''
  CREATE TABLE IF NOT EXISTS reviews (
  id SERIAL PRIMARY KEY,
  task_id INTEGER REFERENCES tasks(id),
  client_id INTEGER REFERENCES users(id),
  worker_id INTEGER REFERENCES users(id),
  rating INTEGER NOT NULL,
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  ''');


  await dbConnection.close();
  print('Database initialized');
}
