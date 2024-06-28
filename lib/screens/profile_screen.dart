import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: authProvider.isAuthenticated
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Name: ${authProvider.user!['name']}'),
                  Text('Email: ${authProvider.user!['email']}'),
                  Text('Age: ${authProvider.user!['age']}'),
                  Text('Phone Number: ${authProvider.user!['phone_number']}'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                    child: const Text('Edit Profile'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await authProvider.deleteAccount();
                        Navigator.pushNamedAndRemoveUntil(context, '/register', (route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account deleted successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to delete account')),
                        );
                      }
                    },
                    child: const Text('Delete Account'),
                  ),
                ],
              )
            : const Text('Not logged in'),
      ),
    );
  }
}
