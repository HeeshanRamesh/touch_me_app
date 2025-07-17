import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/add_member_page.dart';

class GetMembersScreen extends StatefulWidget {
  const GetMembersScreen({super.key});

  @override
  State<GetMembersScreen> createState() => _GetMembersScreenState();
}

class _GetMembersScreenState extends State<GetMembersScreen> {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getMembers();
  }

  // Function to send GET request to retrieve members
  Future<void> _getMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Retrieve merchantId from secure storage
      String? merchantId = await storage.read(key: "merchantId");
      if (merchantId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: Merchant ID not found. Please log in again.';
        });
        return;
      }

      // Replace with your actual API base URL
      const String baseUrl = 'https://api.touchmeapp.com';
      final String apiUrl = '$baseUrl/api/merchants/$merchantId/members';

      // Get authentication token if needed
      String? authToken = await storage.read(key: "authToken");

      Map<String, String> headers = {'Content-Type': 'application/json'};

      // Add authorization header if token exists
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Handle different response structures
        List<dynamic> membersData;
        if (responseData is List) {
          membersData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          membersData = responseData['data'];
        } else if (responseData is Map && responseData.containsKey('members')) {
          membersData = responseData['members'];
        } else {
          membersData = [];
        }

        setState(() {
          _members = membersData.map((member) => Map<String, dynamic>.from(member)).toList();
          _isLoading = false;
        });
      } else {
        // Handle error response
        String errorMessage = 'Failed to load members';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use default message
        }

        setState(() {
          _isLoading = false;
          _errorMessage = '$errorMessage (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error: ${e.toString()}';
      });
    }
  }

  // Function to delete a member
  Future<void> _deleteMember(String memberId, String memberName) async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete $memberName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Retrieve merchantId from secure storage
      String? merchantId = await storage.read(key: "merchantId");
      if (merchantId == null) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Merchant ID not found. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Replace with your actual API base URL
      const String baseUrl = 'https://api.touchmeapp.com';
      final String apiUrl = '$baseUrl/api/merchants/$merchantId/members/$memberId';

      // Get authentication token if needed
      String? authToken = await storage.read(key: "authToken");

      Map<String, String> headers = {'Content-Type': 'application/json'};

      // Add authorization header if token exists
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: headers,
      );

      // Hide loading indicator
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the members list
        _getMembers();
      } else {
        // Handle error response
        String errorMessage = 'Failed to delete member';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use default message
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);

      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getMembers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getMembers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _members.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No members found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first team member to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _getMembers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFF6A1B9A),
                                backgroundImage: member['profile_image'] != null
                                    ? NetworkImage(member['profile_image'])
                                    : null,
                                child: member['profile_image'] == null
                                    ? Text(
                                        (member['name'] ?? 'N/A')
                                            .split(' ')
                                            .map((e) => e.isNotEmpty ? e[0] : '')
                                            .take(2)
                                            .join()
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                member['name'] ?? 'No Name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (member['role'] != null)
                                    Text(
                                      member['role'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  if (member['email'] != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            member['email'],
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 2),
                                  if (member['phone'] != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          member['phone'],
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _deleteMember(
                                      member['id']?.toString() ?? '',
                                      member['name'] ?? 'Unknown',
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
