import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outsource it'),
        actions: authProvider.isAuthenticated
            ? [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    authProvider.logout();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ]
            : [],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Hasło reklamujące
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Too busy? Let us handle it! Outsource with us today!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            if (!authProvider.isAuthenticated) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Login'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Register'),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/all-tasks');
                },
                child: const Text('View All Tasks'),
              ),
            ),
            if (authProvider.isAuthenticated && authProvider.user!['role'] == 'client') ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create-task');
                  },
                  child: const Text('Create Task'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/client-task-list');
                  },
                  child: const Text('View My Tasks'),
                ),
              ),
            ],
            if (authProvider.isAuthenticated && authProvider.user!['role'] == 'moderator') ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/moderator-task-list');
                  },
                  child: const Text('Manage Tasks'),
                ),
              ),
            ],
            if (authProvider.isAuthenticated && authProvider.user!['role'] == 'worker') ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/worker-task-list');
                  },
                  child: const Text('View Available Tasks'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/worker-assigned-tasks');
                  },
                  child: const Text('View Assigned Tasks'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
