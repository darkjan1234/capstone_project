import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupNode {
  final String id;
  final String name;
  final String role; // 'ADMIN' or 'USER'
  final List<GroupNode> children;
  final GroupNode? parent;

  GroupNode({
    required this.id,
    required this.name,
    required this.role,
    this.children = const [],
    this.parent,
  });

  bool get isAdmin => role == 'ADMIN';
  bool get isUser => role == 'USER';
  bool get hasChildren => children.isNotEmpty;
}

class GroupHierarchy {
  // API integration method
  static Future<GroupNode> fetchHierarchyFromAPI(String token, String serverUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/services/app/PttGroup/GetGroupHierarchy'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _buildHierarchyFromAPI(data['result']['items']);
      } else {
        throw Exception('Failed to load hierarchy: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hierarchy: $e');
      return buildHierarchy(); // Fallback to static hierarchy
    }
  }

  static GroupNode _buildHierarchyFromAPI(List<dynamic> apiData) {
    if (apiData.isEmpty) return buildHierarchy();

    // Find root node (no parent)
    final rootData = apiData.firstWhere(
      (item) => item['parentGroupId'] == null,
      orElse: () => null,
    );

    if (rootData == null) return buildHierarchy();

    return _buildNodeFromAPI(rootData, apiData);
  }

  static GroupNode _buildNodeFromAPI(Map<String, dynamic> nodeData, List<dynamic> allData) {
    final children = allData
        .where((item) => item['parentGroupId'] == nodeData['id'])
        .map((child) => _buildNodeFromAPI(child, allData))
        .toList();

    return GroupNode(
      id: nodeData['id'].toString(),
      name: nodeData['name'] ?? 'Unknown',
      role: _mapGroupTypeToRole(nodeData['groupType']),
      children: children,
    );
  }

  static String _mapGroupTypeToRole(int? groupType) {
    switch (groupType) {
      case 1: return 'ADMIN';
      case 2: return 'USER';
      case 3: return 'MIXED';
      default: return 'USER';
    }
  }

  static GroupNode buildHierarchy() {
    // Main ADMIN at the top
    final mainAdmin = GroupNode(
      id: 'main_admin',
      name: 'Main Admin',
      role: 'ADMIN',
    );

    // First branch - USER with sub-admins
    final user1 = GroupNode(
      id: 'user_1',
      name: 'User Branch 1',
      role: 'USER',
      parent: mainAdmin,
    );

    final admin1_1 = GroupNode(
      id: 'admin_1_1',
      name: 'Admin 1.1',
      role: 'ADMIN',
      parent: user1,
    );

    final admin1_2 = GroupNode(
      id: 'admin_1_2', 
      name: 'Admin 1.2',
      role: 'ADMIN',
      parent: user1,
    );

    final user1_1 = GroupNode(
      id: 'user_1_1',
      name: 'User 1.1',
      role: 'USER',
      parent: admin1_1,
    );

    final user1_2 = GroupNode(
      id: 'user_1_2',
      name: 'User 1.2', 
      role: 'USER',
      parent: admin1_2,
    );

    // Second branch - ADMIN with users
    final admin2 = GroupNode(
      id: 'admin_2',
      name: 'Admin Branch 2',
      role: 'ADMIN',
      parent: mainAdmin,
    );

    final user2_1 = GroupNode(
      id: 'user_2_1',
      name: 'User 2.1',
      role: 'USER',
      parent: admin2,
    );

    final admin2_1 = GroupNode(
      id: 'admin_2_1',
      name: 'Admin 2.1',
      role: 'ADMIN',
      parent: admin2,
    );

    final admin2_2 = GroupNode(
      id: 'admin_2_2',
      name: 'Admin 2.2',
      role: 'ADMIN',
      parent: admin2,
    );

    final user2_2 = GroupNode(
      id: 'user_2_2',
      name: 'User 2.2',
      role: 'USER',
      parent: admin2_1,
    );

    final user2_3 = GroupNode(
      id: 'user_2_3',
      name: 'User 2.3',
      role: 'USER',
      parent: admin2_2,
    );

    // Third branch - ADMIN with users
    final admin3 = GroupNode(
      id: 'admin_3',
      name: 'Admin Branch 3',
      role: 'ADMIN',
      parent: mainAdmin,
    );

    final user3_1 = GroupNode(
      id: 'user_3_1',
      name: 'User 3.1',
      role: 'USER',
      parent: admin3,
    );

    final admin3_1 = GroupNode(
      id: 'admin_3_1',
      name: 'Admin 3.1',
      role: 'ADMIN',
      parent: admin3,
    );

    final admin3_2 = GroupNode(
      id: 'admin_3_2',
      name: 'Admin 3.2',
      role: 'ADMIN',
      parent: admin3,
    );

    final user3_2 = GroupNode(
      id: 'user_3_2',
      name: 'User 3.2',
      role: 'USER',
      parent: admin3_1,
    );

    final user3_3 = GroupNode(
      id: 'user_3_3',
      name: 'User 3.3',
      role: 'USER',
      parent: admin3_2,
    );

    // Fourth branch - ADMIN with users
    final admin4 = GroupNode(
      id: 'admin_4',
      name: 'Admin Branch 4',
      role: 'ADMIN',
      parent: mainAdmin,
    );

    final user4_1 = GroupNode(
      id: 'user_4_1',
      name: 'User 4.1',
      role: 'USER',
      parent: admin4,
    );

    final admin4_1 = GroupNode(
      id: 'admin_4_1',
      name: 'Admin 4.1',
      role: 'ADMIN',
      parent: admin4,
    );

    final admin4_2 = GroupNode(
      id: 'admin_4_2',
      name: 'Admin 4.2',
      role: 'ADMIN',
      parent: admin4,
    );

    final admin4_3 = GroupNode(
      id: 'admin_4_3',
      name: 'Admin 4.3',
      role: 'ADMIN',
      parent: admin4,
    );

    final user4_2 = GroupNode(
      id: 'user_4_2',
      name: 'User 4.2',
      role: 'USER',
      parent: admin4_1,
    );

    final user4_3 = GroupNode(
      id: 'user_4_3',
      name: 'User 4.3',
      role: 'USER',
      parent: admin4_2,
    );

    final user4_4 = GroupNode(
      id: 'user_4_4',
      name: 'User 4.4',
      role: 'USER',
      parent: admin4_3,
    );

    // Build the tree structure
    return GroupNode(
      id: 'main_admin',
      name: 'Main Admin',
      role: 'ADMIN',
      children: [
        GroupNode(
          id: 'user_1',
          name: 'User Branch 1',
          role: 'USER',
          children: [
            GroupNode(
              id: 'admin_1_1',
              name: 'Admin 1.1',
              role: 'ADMIN',
              children: [user1_1],
            ),
            GroupNode(
              id: 'admin_1_2',
              name: 'Admin 1.2', 
              role: 'ADMIN',
              children: [user1_2],
            ),
          ],
        ),
        GroupNode(
          id: 'admin_2',
          name: 'Admin Branch 2',
          role: 'ADMIN',
          children: [
            user2_1,
            GroupNode(
              id: 'admin_2_1',
              name: 'Admin 2.1',
              role: 'ADMIN',
              children: [user2_2],
            ),
            GroupNode(
              id: 'admin_2_2',
              name: 'Admin 2.2',
              role: 'ADMIN', 
              children: [user2_3],
            ),
          ],
        ),
        GroupNode(
          id: 'admin_3',
          name: 'Admin Branch 3',
          role: 'ADMIN',
          children: [
            user3_1,
            GroupNode(
              id: 'admin_3_1',
              name: 'Admin 3.1',
              role: 'ADMIN',
              children: [user3_2],
            ),
            GroupNode(
              id: 'admin_3_2',
              name: 'Admin 3.2',
              role: 'ADMIN',
              children: [user3_3],
            ),
          ],
        ),
        GroupNode(
          id: 'admin_4',
          name: 'Admin Branch 4',
          role: 'ADMIN',
          children: [
            user4_1,
            GroupNode(
              id: 'admin_4_1',
              name: 'Admin 4.1',
              role: 'ADMIN',
              children: [user4_2],
            ),
            GroupNode(
              id: 'admin_4_2',
              name: 'Admin 4.2',
              role: 'ADMIN',
              children: [user4_3],
            ),
            GroupNode(
              id: 'admin_4_3',
              name: 'Admin 4.3',
              role: 'ADMIN',
              children: [user4_4],
            ),
          ],
        ),
      ],
    );
  }

  static List<GroupNode> getAllNodes(GroupNode root) {
    List<GroupNode> allNodes = [root];
    for (var child in root.children) {
      allNodes.addAll(getAllNodes(child));
    }
    return allNodes;
  }

  static List<GroupNode> getNodesForUser(String userRole) {
    final hierarchy = buildHierarchy();
    final allNodes = getAllNodes(hierarchy);
    
    if (userRole == 'ADMIN') {
      // Admins can see all nodes
      return allNodes;
    } else {
      // Users can only see user nodes and their direct admin
      return allNodes.where((node) => 
        node.role == 'USER' || 
        (node.role == 'ADMIN' && node.children.any((child) => child.role == 'USER'))
      ).toList();
    }
  }
}
