import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      
                      const SizedBox(height: 50),
                      // Important Notes Card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Important Notes:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildBulletPoint(
                              'Please arrive 15 minutes before your appointment',
                              Colors.blue.shade700,
                            ),
                            const SizedBox(height: 8),
                            _buildBulletPoint(
                              'Cancel at least 24 hours in advance',
                              Colors.blue.shade700,
                            ),
                            const SizedBox(height: 8),
                            _buildBulletPoint(
                              'We\'ll send you a reminder SMS',
                              Colors.blue.shade700,
                            ),
                            const SizedBox(height: 8),
                            _buildBulletPoint(
                              'Please save your booking ID: TM169756',
                              Colors.blue.shade700,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Need Help Card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Need Help?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Call us option
                            _buildContactRow(
                              icon: Icons.phone,
                              iconColor: Colors.pink,
                              label: 'Hotline: ',
                              value: '+94 77 7635225',
                              onTap: () => _launchPhone('+94777635225'),
                            ),
                            const SizedBox(height: 16),
                            
                            // Email option
                            _buildContactRow(
                              icon: Icons.email,
                              iconColor: Colors.blue,
                              label: 'Email: ',
                              value: 'touchme.bookings@outlook.com',
                              onTap: () => _launchEmail('touchme.bookings@outlook.com'),
                            ),
                            const SizedBox(height: 16),
                            
                            // Website option
                            _buildContactRow(
                              icon: Icons.language,
                              iconColor: Colors.green,
                              label: 'Website: ',
                              value: 'smarttouchdigisolutions.com',
                              onTap: () => _launchWebsite('https://smarttouchdigisolutions.com'),
                            ),
                            
                            // Additional contact option
                            // const SizedBox(height: 16),
                            // _buildContactRow(
                            //   icon: Icons.chat,
                            //   iconColor: Colors.purple,
                            //   label: 'Live Chat: ',
                            //   value: 'Available 24/7',
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Back to Home Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back or to home
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1D29),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 8, right: 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // Fixed contact row widget - shows full text
  Widget _buildContactRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8), // Increased padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Changed to start
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    // Removed overflow: TextOverflow.ellipsis to show full text
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Launch phone dialer
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorSnackBar('Could not launch phone dialer');
    }
  }

  // Launch email client
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request&body=Hello, I need help with...',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorSnackBar('Could not launch email client');
    }
  }

  // Launch website
  Future<void> _launchWebsite(String url) async {
    final Uri websiteUri = Uri.parse(url);
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Could not launch website');
    }
  }

  // Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}