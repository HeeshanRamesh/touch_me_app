import 'package:flutter/material.dart';
import 'package:touch_me/pages/about_screen.dart';
import 'package:touch_me/pages/login_page.dart';
import 'package:touch_me/pages/profile_personal_details_screen.dart';
import 'package:touch_me/pages/support_page.dart';
import 'package:touch_me/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  
  String? _profileImageUrl;
  String _userName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = await _storage.read(key: 'user_id');
      final token = await _storage.read(key: 'auth_token');

      if (userId != null && token != null) {
        final response = await _authService.getUserProfile(userId, token);

        if (response['success']) {
          final userData = response['user'];
          setState(() {
            _profileImageUrl = userData['profileImage'];
            final firstName = userData['first_name'] ?? '';
            final lastName = userData['last_name'] ?? '';
            _userName = '$firstName $lastName'.trim();
            if (_userName.isEmpty) _userName = 'User';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading profile: $e');
    }
  }

  // Refresh profile when returning from personal details screen
  Future<void> _navigateToPersonalDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePersonalDetailsScreen(),
      ),
    );
    // Reload profile after returning
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = 90;
    final Color iconBgColor = const Color(0xFFF3D6F6);
    final Color mainColor = const Color(0xFF52214C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Profile',
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 14),
            // Profile Avatar with loading state
            _isLoading
                ? CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundColor: mainColor.withOpacity(0.2),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF52214C)),
                    ),
                  )
                : CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundColor: mainColor,
                    backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage('assets/profile_image.png') as ImageProvider,
                  ),

            // const SizedBox(height: 12),
            // // Display user name
            // Text(
            //   _userName,
            //   style: TextStyle(
            //     color: mainColor,
            //     fontSize: 18,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.person,
                    label: "Personal Details",
                    iconBg: iconBgColor,
                    iconColor: mainColor,
                    onTap: _navigateToPersonalDetails,
                  ),
                  // _ProfileMenuItem(
                  //   icon: Icons.credit_card,
                  //   label: "Payment Method",
                  //   iconBg: iconBgColor,
                  //   iconColor: mainColor,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const PaymentMethodScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  _ProfileMenuItem(
                    icon: Icons.info,
                    label: "About",
                    iconBg: iconBgColor,
                    iconColor: mainColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help,
                    label: "Support and Info",
                    iconBg: iconBgColor,
                    iconColor: mainColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupportPage(),
                        ),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.logout,
                    label: "Log out",
                    iconBg: iconBgColor,
                    iconColor: mainColor,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final parts = _userName.split(' ');
    String initials = '';
    
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials += parts[0][0].toUpperCase();
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      initials += parts[1][0].toUpperCase();
    }
    
    return initials.isNotEmpty ? initials : 'U';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to log out from the app?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Clear all secure storage
                        await _storage.deleteAll();
                        // Perform logout action
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF52214C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'YES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF52214C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'NO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 26),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black45),
      onTap: onTap,
    );
  }
}