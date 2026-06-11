import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final url = Uri.parse('$baseUrl/api/chat');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Server returned status code ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to backend: $e'
      };
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/signin');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['detail'] ?? 'Sign in failed';
          return {'success': false, 'message': message};
        } catch (_) {
          return {'success': false, 'message': 'Sign in failed with status ${response.statusCode}'};
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to backend: $e'
      };
    }
  }

  Future<Map<String, dynamic>> signUp(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/signup');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['detail'] ?? 'Sign up failed';
          return {'success': false, 'message': message};
        } catch (_) {
          return {'success': false, 'message': 'Sign up failed with status ${response.statusCode}'};
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to backend: $e'
      };
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/forgot-password');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['detail'] ?? 'Failed to send recovery email';
          return {'success': false, 'message': message};
        } catch (_) {
          return {'success': false, 'message': 'Failed with status ${response.statusCode}'};
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to backend: $e'
      };
    }
  }

  Future<Map<String, dynamic>> checkHealth() async {
    final url = Uri.parse('$baseUrl/health');
    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {'status': 'unhealthy', 'error': 'Status code ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'unhealthy', 'error': e.toString()};
    }
  }
}


