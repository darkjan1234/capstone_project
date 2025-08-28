import 'package:flutter/material.dart';
import 'group_hierarchy.dart';
import 'ptt_service.dart';

class GroupHierarchyScreen extends StatefulWidget {
  final String token;
  final String serverUrl;
  final String userId;
  final String userRole;

  const GroupHierarchyScreen({
    Key? key,
    required this.token,
    required this.serverUrl,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  @override
  State<GroupHierarchyScreen> createState() => _GroupHierarchyScreenState();
}

class _GroupHierarchyScreenState extends State<GroupHierarchyScreen> {
  final PttService _pttService = PttService();
  GroupNode? _selectedNode;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializePtt();
  }

  Future<void> _initializePtt() async {
    try {
      await _pttService.initialize(widget.token);
      await _pttService.connectToHub(widget.serverUrl);
      
      _pttService.connectionStatusChanged.listen((connected) {
        setState(() {
          _isConnected = connected;
        });
      });
    } catch (e) {
      print('Failed to initialize PTT: $e');
    }
  }

  Future<void> _joinGroup(GroupNode node) async {
    try {
      await _pttService.joinGroup(node.id);
      setState(() {
        _selectedNode = node;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${node.name} (${node.role})'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join group: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GroupNode>(
      future: GroupHierarchy.fetchHierarchyFromAPI(widget.token, widget.serverUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Color(0xFF4CAF50),
            appBar: AppBar(
              title: Text('Group Hierarchy'),
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Color(0xFF4CAF50),
            appBar: AppBar(
              title: Text('Group Hierarchy'),
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load hierarchy',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Using offline data',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        final hierarchy = snapshot.data ?? GroupHierarchy.buildHierarchy();
        final availableNodes = GroupHierarchy.getNodesForUser(widget.userRole);

        return _buildHierarchyScreen(hierarchy, availableNodes);
      },
    );
  }

  Widget _buildHierarchyScreen(GroupNode hierarchy, List<GroupNode> availableNodes) {

    return Scaffold(
      backgroundColor: Color(0xFF4CAF50),
      appBar: AppBar(
        title: Text('Group Hierarchy'),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _isConnected ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current selection
          if (_selectedNode != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Color(0xFF2E7D32),
              child: Text(
                'Current Group: ${_selectedNode!.name} (${_selectedNode!.role})',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // User info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: Colors.white.withOpacity(0.1),
            child: Text(
              'Logged in as: ${widget.userId} (${widget.userRole})',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),

          // Hierarchy tree
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Group Hierarchy Structure',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildHierarchyTree(hierarchy, 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyTree(GroupNode node, int level) {
    final isAvailable = GroupHierarchy.getNodesForUser(widget.userRole).contains(node);
    final isSelected = _selectedNode?.id == node.id;

    return Container(
      margin: EdgeInsets.only(left: level * 20.0, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node
          GestureDetector(
            onTap: isAvailable ? () => _joinGroup(node) : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                  ? Colors.orange
                  : isAvailable 
                    ? (node.isAdmin ? Color(0xFF2E7D32) : Colors.blue.shade600)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    node.isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    node.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      node.role,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isAvailable)
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Children
          if (node.hasChildren)
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Column(
                children: node.children.map((child) => 
                  _buildHierarchyTree(child, level + 1)
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pttService.dispose();
    super.dispose();
  }
}
