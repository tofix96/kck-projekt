import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

   Future<void> register(String email, String password, String name, String role, String phoneNumber, String age) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
        'phone_number': phoneNumber,
        'age': age,
      },
    );

    if (response.statusCode == 400) {
      final errorMessage = response.body;
      throw Exception(errorMessage);
    } else if (response.statusCode != 200) {
      throw Exception('Failed to register');
    }
  }


  Future<void> deleteAccount(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account');
    }
  }
  //user_details po id
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user details');
    }
  }
}
