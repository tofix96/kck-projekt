import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
                    child: Text('Edit Profile'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await authProvider.deleteAccount();
                        Navigator.pushNamedAndRemoveUntil(context, '/register', (route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Account deleted successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete account')),
                        );
                      }
                    },
                    child: Text('Delete Account'),
                  ),
                ],
              )
            : Text('Not logged in'),
      ),
    );
  }
}
