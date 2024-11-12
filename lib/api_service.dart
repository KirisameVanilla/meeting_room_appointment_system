import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<void> registerUser(String email, String password) async {
    print('Email: $email, Password: $password');
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 201) {
      print('User registered successfully');
    } else {
      print('Failed to register: ${response.body}');
    }
  }

  Future<void> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      String token = jsonResponse['access_token'];
      print('Logged in successfully, token: $token');
    } else {
      print('Failed to log in: ${response.body}');
    }
  }
}