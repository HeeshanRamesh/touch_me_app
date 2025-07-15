import 'package:flutter/material.dart';
import 'package:touch_me/add_services_screen.dart';

class MerchantCatalogPage extends StatefulWidget {
  const MerchantCatalogPage({Key? key}) : super(key: key);

  @override
  State<MerchantCatalogPage> createState() => _MerchantCatalogPageState();
}

class _MerchantCatalogPageState extends State<MerchantCatalogPage> {
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
                          "Catalog",
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
                    leading: Icon(Icons.list),
                    title: Text('Service menu'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddServiceScreen()),
                      );
                    },
                  ),
                  //Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.card_membership),
                    title: Text('Memberships'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  //Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.local_offer),
                    title: Text('Products'),
                    trailing: Icon(Icons.chevron_right),
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