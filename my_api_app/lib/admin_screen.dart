import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  final String token;
  final String serverUrl;

  const AdminScreen({
    Key? key,
    required this.token,
    required this.serverUrl,
  }) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadGroups();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${widget.serverUrl}/api/services/app/User/GetUsers'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data['result']['items'] ?? []);
        });
      }
    } catch (e) {
      print('Failed to load users: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadGroups() async {
    // Mock groups for now - in real implementation, load from backend
    setState(() {
      _groups = [
        {'name': 'Sir Toto', 'members': 3, 'active': true},
        {'name': 'maam Jacky', 'members': 2, 'active': true},
        {'name': 'Radio 2', 'members': 5, 'active': false},
        {'name': 'Radio 3', 'members': 1, 'active': true},
        {'name': '000401', 'members': 0, 'active': false},
        {'name': '00001', 'members': 2, 'active': true},
        {'name': '000200', 'members': 4, 'active': true},
      ];
    });
  }

  Future<void> _createUser() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Implement user creation API call
              Navigator.pop(context);
              _showMessage('User creation feature coming soon!');
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4CAF50),
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Users Section
                  _buildSectionHeader('Users Management'),
                  SizedBox(height: 8),
                  _buildUsersSection(),
                  
                  SizedBox(height: 24),
                  
                  // Groups Section
                  _buildSectionHeader('Groups Management'),
                  SizedBox(height: 8),
                  _buildGroupsSection(),
                  
                  SizedBox(height: 24),
                  
                  // System Stats
                  _buildSectionHeader('System Statistics'),
                  SizedBox(height: 8),
                  _buildStatsSection(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createUser,
        backgroundColor: Color(0xFF2E7D32),
        child: Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUsersSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Users list
          ..._users.take(5).map((user) => Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(child: Text(user['name'] ?? 'Unknown')),
                Expanded(child: Text(user['emailAddress'] ?? 'No email')),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user['isActive'] == true ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['isActive'] == true ? 'Active' : 'Inactive',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          )).toList(),
          if (_users.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('No users found', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Group Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Text('Members', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Groups list
          ..._groups.map((group) => Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(child: Text(group['name'])),
                Text('${group['members']}'),
                SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: group['active'] ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group['active'] ? 'Active' : 'Inactive',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Users', '${_users.length}', Icons.people),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Active Groups', '${_groups.where((g) => g['active']).length}', Icons.group),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Online Users', '3', Icons.online_prediction),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Messages Today', '47', Icons.message),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
