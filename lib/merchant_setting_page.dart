import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/about_screen.dart';
import 'package:touch_me/merchant_about_page.dart';
import 'package:touch_me/merchant_profile_edit_page.dart';
import 'package:touch_me/merchant_change_password_page.dart';
import 'package:touch_me/merchant_payment_method.dart';

class MerchantSettingPage extends StatefulWidget {
  final String? merchantId; // Add merchantId parameter
  const MerchantSettingPage({Key? key, this.merchantId}) : super(key: key);

  @override
  State<MerchantSettingPage> createState() => _MerchantSettingPageState();
}

class _MerchantSettingPageState extends State<MerchantSettingPage> {
  final storage = const FlutterSecureStorage();
  String? _merchantId; 

  @override
  void initState() {
    super.initState();
    _loadMerchantId();
  }

  Future<void> _loadMerchantId() async {
    // First try to use the passed merchantId, then fall back to storage
    if (widget.merchantId != null && widget.merchantId!.isNotEmpty) {
      _merchantId = widget.merchantId;
    } else {
      _merchantId = await storage.read(key: 'merchantId');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Name
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: const Text(
                          "Settings",
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Appointment Date Card
              Card(
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile Settings'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MerchantProfileEditPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text('About App'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MerchantAboutScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.key),
                      title: Text('Change Password'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        // Pass the actual merchantId, not a string literal
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MerchantChangePasswordPage(
                              merchantId: _merchantId, // ✅ Pass the actual merchant ID
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.payment),
                      title: Text('Payment Methods'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentMethodsPage()
                          ), 
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}