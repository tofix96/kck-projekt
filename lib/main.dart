import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/edit_task_screen.dart';
import 'screens/moderator_task_list_screen.dart';
import 'screens/worker_task_list_screen.dart';
import 'screens/client_task_list_screen.dart';
import 'screens/worker_assigned_tasks_list_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/all_task_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Outsource it',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.transparent, // Ustawienie tła jako przezroczyste
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, // Kolor tła AppBar
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.black87, // Kolor tekstu w AppBar
              fontSize: 20,
            ),
            iconTheme: IconThemeData(
              color: Colors.black87, // Kolor ikon w AppBar
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.lightBlue.shade200), // Kolor tła przycisku
              foregroundColor: WidgetStateProperty.all<Color>(Colors.black87), // Kolor tekstu
              padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              textStyle: WidgetStateProperty.all<TextStyle>(
                TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegistrationScreen(),
          '/create-task': (context) => CreateTaskScreen(),
          '/task-list': (context) => TaskListScreen(),
          '/profile': (context) => ProfileScreen(),
          '/edit-profile': (context) => EditProfileScreen(),
          '/moderator-task-list': (context) => ModeratorTaskListScreen(),
          '/worker-task-list': (context) => WorkerTaskListScreen(),
          '/client-task-list': (context) => ClientTaskListScreen(),
          '/worker-assigned-tasks': (context) => WorkerAssignedTasksScreen(),
          '/all-tasks': (context) => AllTasksScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/task-detail') {
            final task = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) {
                return TaskDetailScreen(task: task);
              },
            );
          } else if (settings.name == '/edit-task') {
            final task = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) {
                return EditTaskScreen(task: task);
              },
            );
          }
          return null;
        },
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/wallpaper/bg_style.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              child!,
            ],
          );
        },
      ),
    );
  }
}
