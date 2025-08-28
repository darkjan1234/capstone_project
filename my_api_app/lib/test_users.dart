// Test users for PTT system
// You can use these credentials to login with multiple devices

class TestUsers {
  static const List<Map<String, String>> users = [
    {
      'username': 'admin',
      'password': '123qwe',
      'name': 'Admin User',
      'role': 'Admin'
    },
    {
      'username': 'user1',
      'password': '123qwe',
      'name': 'Test User 1',
      'role': 'User'
    },
    {
      'username': 'user2', 
      'password': '123qwe',
      'name': 'Test User 2',
      'role': 'User'
    },
    {
      'username': 'radio1',
      'password': '123qwe',
      'name': 'Radio Operator 1',
      'role': 'User'
    },
    {
      'username': 'radio2',
      'password': '123qwe', 
      'name': 'Radio Operator 2',
      'role': 'User'
    },
  ];

  static Map<String, String>? getUserByUsername(String username) {
    try {
      return users.firstWhere((user) => user['username'] == username);
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllUsernames() {
    return users.map((user) => user['username']!).toList();
  }
}
