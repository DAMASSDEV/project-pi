import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    return 'https://api-nutrify.damassdev.my.id';
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
          'message': 'Server returned status code ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to backend: $e'};
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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('logged_in_email', email);
          await prefs.setString('logged_in_username', email);
          if (data['user'] != null) {
            if (data['user']['name'] != null) {
              await prefs.setString('logged_in_name', data['user']['name']);
            }
            if (data['user']['has_completed_personalization'] != null) {
              await prefs.setBool(
                'has_completed_personalization',
                data['user']['has_completed_personalization'] == true,
              );
            }
          }
        }
        return data;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['detail'] ?? 'Sign in failed';
          return {'success': false, 'message': message};
        } catch (_) {
          return {
            'success': false,
            'message': 'Sign in failed with status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to backend: $e'};
    }
  }

  Future<Map<String, dynamic>> signUp(
    String name,
    String email,
    String password,
  ) async {
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
          return {
            'success': false,
            'message': 'Sign up failed with status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to backend: $e'};
    }
  }

  Future<Map<String, dynamic>> savePersonalization(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/api/personalization');
    try {
      final prefs = await SharedPreferences.getInstance();
      final emailKey = data['email'] ?? 'default_user';
      await prefs.setString(
        'cached_personalization_$emailKey',
        jsonEncode(data),
      );

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final message =
              errorData['detail'] ?? 'Failed to save personalization';
          return {'success': false, 'message': message};
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed with status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to backend: $e'};
    }
  }

  Future<Map<String, dynamic>> checkHealth() async {
    final url = Uri.parse('$baseUrl/health');
    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'status': 'unhealthy',
          'error': 'Status code ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'unhealthy', 'error': e.toString()};
    }
  }

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    final url = Uri.parse(
      '$baseUrl/api/foods/search?q=${Uri.encodeComponent(query)}',
    );
    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final results = decoded['results'] as List<dynamic>? ?? [];
        return results.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> scanFood(String foodName) async {
    final url = Uri.parse('$baseUrl/api/meals/scan');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'food_name': foodName}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Status code ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> scanFoodImage(String filePath) async {
    final url = Uri.parse('$baseUrl/api/meals/scan-image');
    try {
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Status code ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> saveMeal(Map<String, dynamic> mealData) async {
    final url = Uri.parse('$baseUrl/api/meals');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(mealData),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'meal': decoded};
      } else {
        return {
          'success': false,
          'message': 'Status code ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<dynamic>> getMeals(String email) async {
    final url = Uri.parse(
      '$baseUrl/api/meals?email=${Uri.encodeComponent(email)}',
    );
    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> deleteMeal(int mealId) async {
    final url = Uri.parse('$baseUrl/api/meals/$mealId');
    try {
      final response = await _client.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Status code ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateMeal(
    int mealId,
    Map<String, dynamic> mealData,
  ) async {
    final url = Uri.parse('$baseUrl/api/meals/$mealId');
    try {
      final response = await _client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(mealData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Status code ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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
          final message =
              errorData['detail'] ?? 'Gagal mengirim email pemulihan.';
          return {'success': false, 'message': message};
        } catch (_) {
          return {
            'success': false,
            'message': 'Gagal dengan status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> getPersonalization(String email) async {
    final url = Uri.parse(
      '$baseUrl/api/personalization/${Uri.encodeComponent(email)}',
    );
    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body) as Map<String, dynamic>;
        if (res['success'] == true && res['data'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'cached_personalization_$email',
            jsonEncode(res['data']),
          );
        }
        return res;
      } else {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('cached_personalization_$email');
        if (cached != null) {
          return {
            'success': true,
            'data': jsonDecode(cached) as Map<String, dynamic>,
          };
        }
        return {
          'success': false,
          'message': 'Status code ${response.statusCode}',
        };
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_personalization_$email');
      if (cached != null) {
        return {
          'success': true,
          'data': jsonDecode(cached) as Map<String, dynamic>,
        };
      }
      return {'success': false, 'message': e.toString()};
    }
  }
}
