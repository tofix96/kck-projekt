import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  Map<String, dynamic>? _user;

  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService();

  Map<String, dynamic>? get user => _user;

  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    final user = await _authService.login(email, password);
    _user = user;
    notifyListeners();
  }

  Future<void> register(String email, String password, String name, String role, String phoneNumber, String age) async {
    await _authService.register(email, password, name, role, phoneNumber, age);
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_user != null) {
      await _authService.deleteAccount(_user!['id']);
      _user = null;
      notifyListeners();
    }
  }
}
