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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Outsource it',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 20,
            ),
            iconTheme: IconThemeData(
              color: Colors.black87, // Kolor ikon w AppBar
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.lightBlue.shade200),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.black87),
              padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              textStyle: WidgetStateProperty.all<TextStyle>(
                const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/create-task': (context) => const CreateTaskScreen(),
          '/task-list': (context) => TaskListScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit-profile': (context) => EditProfileScreen(),
          '/moderator-task-list': (context) => const ModeratorTaskListScreen(),
          '/worker-task-list': (context) => const WorkerTaskListScreen(),
          '/client-task-list': (context) => const ClientTaskListScreen(),
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
