import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_screen.dart';

class AuthService {
  static String get baseUrl => dotenv.env['URL'] ?? 'http://localhost:3000';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/login');

      print('=== REQUEST INFO ===');
      print('URL: $url');
      print('Base URL from env: $baseUrl');
      print('==================');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      // Print the full response
      print('=== LOGIN RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Token: ${responseData['token']}');
      print('User: ${responseData['user']}');
      print('=====================');

      if (response.statusCode == 200 && responseData['token'] != null) {
        return {
          'success': true,
          'token': responseData['token'],
          'user': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('=== LOGIN ERROR ===');
      print('Error: $e');
      print('==================');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveLoginData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_id', user['id']);
    await prefs.setString('username', user['username']);
    await prefs.setString('email', user['email']);
    await prefs.setString('phone_number', user['phoneNumber']);
    await prefs.setString('role', user['role']);
  }

  Future<Map<String, String?>> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'user_id': prefs.getString('user_id'),
      'username': prefs.getString('username'),
      'email': prefs.getString('email'),
      'phone_number': prefs.getString('phone_number'),
      'role': prefs.getString('role'),
    };
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final result = await AuthService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    print('=== LOGIN RESULT ===');
    print('Success: ${result['success']}');
    print('Full Result: $result');
    print('===================');

    if (result['success']) {
      // Extract token and user data
      final token = result['token'];
      final user = result['user'];

      print('=== USER DATA ===');
      print('Token: $token');
      print('User ID: ${user['id']}');
      print('Username: ${user['username']}');
      print('Email: ${user['email']}');
      print('Phone: ${user['phoneNumber']}');
      print('Role: ${user['role']}');
      print('================');

      // Save login data locally
      await _saveLoginData(token, user);

      // Login successful - navigate to home
      print('Login successful! Navigating to home...');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );

      // Show success message with username
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${user['username']}!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Login failed - stay on login screen and show error
      print('Login failed: ${result['error']}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );

      // Clear password field on failed login
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Logging in...'),
                        ],
                      )
                    : Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
