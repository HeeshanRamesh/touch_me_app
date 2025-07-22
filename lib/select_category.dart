import 'package:flutter/material.dart';
import 'package:touch_me/spa_owner_login_screen.dart';
import 'signup_page.dart'; // Import SignUpPage
import 'merchant_signup_main.dart'; // Import the actual Saloon signup page

class SelectCategoryPage extends StatefulWidget {
  const SelectCategoryPage({super.key});

  @override
  _SelectCategoryPageState createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register your Saloon | SPA now',
                style: TextStyle(
                  fontSize: screenHeight * 0.032,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 58, 7, 78),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Welcome to the kingdom of Beauty',
                style: TextStyle(
                  fontSize: screenHeight * 0.022,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: SizedBox(
                  height: screenHeight * 0.2,
                  width: screenHeight * 0.2,
                  child: Image.asset(
                    'assets/app_icon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Text(
                            'Image Not Found',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                'Select Category',
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Saloon Owners
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color:
                      _selectedCategory == 'Saloon Owners'
                          ? const Color.fromARGB(255, 147, 117, 165)
                          : Colors.transparent,
                ),
                child: RadioListTile<String>(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  title: Text(
                    'Saloon Owners',
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                  subtitle: Text(
                    'Those who have the shop',
                    style: TextStyle(fontSize: screenHeight * 0.016),
                  ),
                  value: 'Saloon Owners',
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  activeColor: const Color(0xFF6A1B9A),
                  secondary: Image.asset(
                    'assets/saloon_icon.png',
                    height: screenHeight * 0.025,
                    width: screenHeight * 0.025,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.005),

              // Spa Owners
              // Container(
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.black, width: 1),
              //     borderRadius: BorderRadius.circular(8),
              //     color:
              //         _selectedCategory == 'Spa Owners'
              //             ? const Color.fromARGB(255, 147, 117, 165)
              //             : Colors.transparent,
              //   ),
              //   child: RadioListTile<String>(
              //     dense: true,
              //     contentPadding: const EdgeInsets.symmetric(
              //       horizontal: 10,
              //       vertical: 5,
              //     ),
              //     title: Text(
              //       'Spa Owners',
              //       style: TextStyle(fontSize: screenHeight * 0.02),
              //     ),
              //     subtitle: Text(
              //       'Those who have self service',
              //       style: TextStyle(fontSize: screenHeight * 0.016),
              //     ),
              //     value: 'Spa Owners',
              //     groupValue: _selectedCategory,
              //     onChanged: (value) {
              //       setState(() {
              //         _selectedCategory = value!;
              //       });
              //     },
              //     activeColor: const Color(0xFF6A1B9A),
              //     secondary: Image.asset(
              //       'assets/spa_icon.png',
              //       height: screenHeight * 0.025,
              //       width: screenHeight * 0.025,
              //     ),
              //   ),
              // ),
              // SizedBox(height: screenHeight * 0.005),

              // Customer
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color:
                      _selectedCategory == 'Customer'
                          ? const Color.fromARGB(255, 147, 117, 165)
                          : Colors.transparent,
                ),
                child: RadioListTile<String>(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  title: Text(
                    'Customer',
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                  subtitle: Text(
                    'Those who need Service',
                    style: TextStyle(fontSize: screenHeight * 0.016),
                  ),
                  value: 'Customer',
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  activeColor: const Color(0xFF6A1B9A),
                  secondary: Image.asset(
                    'assets/customer_icon.png',
                    height: screenHeight * 0.025,
                    width: screenHeight * 0.025,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Text(
                'Once you are done selecting your profession, proceed by clicking on the next button',
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  color: Colors.black,
                ),
              ),
               SizedBox(height: screenHeight * 0.03),

              // Next Button
              ElevatedButton(
                onPressed:
                    _selectedCategory == null
                        ? null
                        : () {
                          if (_selectedCategory == 'Customer') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          } else if (_selectedCategory == 'Saloon Owners') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const MerchantSignupMain(),
                              ),
                            );
                          }
                          else if (_selectedCategory == 'Spa Owners') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SpaOwnerLoginPage(),
                              ),
                            );
                          }
                          // Do nothing for Spa Owners or other categories
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  minimumSize: Size(double.infinity, screenHeight * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
