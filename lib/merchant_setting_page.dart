import 'package:flutter/material.dart';
import 'package:touch_me/about_screen.dart';
import 'package:touch_me/merchant_about_page.dart';
import 'package:touch_me/merchant_profile_edit_page.dart';

class MerchantSettingPage extends StatefulWidget {
  const MerchantSettingPage({Key? key}) : super(key: key);

  @override
  State<MerchantSettingPage> createState() => _MerchantSettingPageState();
}

class _MerchantSettingPageState extends State<MerchantSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
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
                shrinkWrap: true, // Ensures ListView takes only needed space
                physics: const NeverScrollableScrollPhysics(), // Disables ListView scrolling
                padding: const EdgeInsets.all(8.0),
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile Settings'),
                    trailing: Icon(Icons.chevron_right),
                     onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MerchantProfileEditPage()),
                      );
                    },
                  ),
                  //Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('About App'),
                    trailing: Icon(Icons.chevron_right),
                     onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MerchantAboutScreen()),
                      );
                    },
                  ),
                  //Divider(height: 1),
                  // ListTile(
                  //   leading: Icon(Icons.add_task),
                  //   title: Text('Add Member'),
                  //   trailing: Icon(Icons.chevron_right),
                   
                  // ),
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