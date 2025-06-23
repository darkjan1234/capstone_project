import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://10.0.2.2:44311/api/services/app/UserLogin';

  Future<List<dynamic>> getUserLoginAttempts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/GetUserLoginAttempts'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // If secured endpoint, add token:
        // 'Authorization': 'Bearer YOUR_TOKEN'
      },
    );

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['result']['items']; // depends sa response
    } else {
      throw Exception('Failed to load login attempts');
    }
  }
}
