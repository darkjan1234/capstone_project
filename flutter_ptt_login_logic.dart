// Flutter PTT Login Logic with Region-based Access Control
// Place this in your Flutter app's authentication service

import 'dart:convert';
import 'package:http/http.dart' as http;

class PttAuthService {
  static const String baseUrl = 'https://localhost:44301/api';
  
  // User types in PTT system
  enum PttUserType {
    superAdmin,    // Can see all regions and groups
    ppoAdmin,      // Can see only their region's groups
    fieldUser      // Can see only groups they're member of
  }
  
  // Current user info
  class PttUser {
    final int id;
    final String username;
    final String name;
    final String regionCode;
    final String pttRole;
    final PttUserType userType;
    final String token;
    
    PttUser({
      required this.id,
      required this.username,
      required this.name,
      required this.regionCode,
      required this.pttRole,
      required this.userType,
      required this.token,
    });
    
    factory PttUser.fromJson(Map<String, dynamic> json) {
      PttUserType userType;
      String pttRole = json['pttRole'] ?? '';
      
      if (pttRole == 'SuperAdmin') {
        userType = PttUserType.superAdmin;
      } else if (pttRole == 'PPOAdmin') {
        userType = PttUserType.ppoAdmin;
      } else {
        userType = PttUserType.fieldUser;
      }
      
      return PttUser(
        id: json['userId'],
        username: json['userName'],
        name: json['name'],
        regionCode: json['regionCode'] ?? '',
        pttRole: pttRole,
        userType: userType,
        token: json['accessToken'],
      );
    }
  }
  
  // Login method
  static Future<PttUser?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/TokenAuth/Authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userNameOrEmailAddress': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return PttUser.fromJson(data['result']);
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  // Get accessible groups based on user type
  static Future<List<PttGroup>> getAccessibleGroups(PttUser user) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/app/PttSecurity/GetAccessibleGroups'),
        headers: {
          'Authorization': 'Bearer ${user.token}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List<dynamic> groupsJson = data['result'];
          return groupsJson.map((json) => PttGroup.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting groups: $e');
      return [];
    }
  }
  
  // Get users that current user can communicate with
  static Future<List<PttUser>> getCommunicableUsers(PttUser currentUser) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/app/PttSecurity/GetCommunicableUsers'),
        headers: {
          'Authorization': 'Bearer ${currentUser.token}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List<dynamic> usersJson = data['result'];
          return usersJson.map((json) => PttUser.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }
  
  // Check if user can communicate with a specific group
  static Future<bool> canCommunicateWithGroup(PttUser user, int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/app/PttSecurity/CanCommunicateWithGroup?groupId=$groupId'),
        headers: {
          'Authorization': 'Bearer ${user.token}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking communication permission: $e');
      return false;
    }
  }
}

// PTT Group model
class PttGroup {
  final int id;
  final String name;
  final String description;
  final String regionCode;
  final String groupType;
  final bool isActive;
  final int memberCount;
  
  PttGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.regionCode,
    required this.groupType,
    required this.isActive,
    required this.memberCount,
  });
  
  factory PttGroup.fromJson(Map<String, dynamic> json) {
    return PttGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      regionCode: json['regionCode'] ?? '',
      groupType: json['groupType'] ?? '',
      isActive: json['isActive'] ?? true,
      memberCount: json['memberCount'] ?? 0,
    );
  }
}

// Example usage in Flutter app:
/*
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  Future<void> _login() async {
    final user = await PttAuthService.login(
      _usernameController.text,
      _passwordController.text,
    );
    
    if (user != null) {
      // Navigate to appropriate screen based on user type
      switch (user.userType) {
        case PttUserType.superAdmin:
          Navigator.pushReplacement(context, 
            MaterialPageRoute(builder: (_) => SuperAdminDashboard(user: user)));
          break;
        case PttUserType.ppoAdmin:
          Navigator.pushReplacement(context, 
            MaterialPageRoute(builder: (_) => PpoAdminDashboard(user: user)));
          break;
        case PttUserType.fieldUser:
          Navigator.pushReplacement(context, 
            MaterialPageRoute(builder: (_) => FieldUserDashboard(user: user)));
          break;
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PTT Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
