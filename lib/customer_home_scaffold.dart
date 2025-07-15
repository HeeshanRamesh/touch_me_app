import 'package:flutter/material.dart';
import 'package:touch_me/appoinment_calender.dart';
import 'package:touch_me/appoinment_screen.dart';
import 'package:touch_me/customer_home_content.dart';
import 'package:touch_me/customer_profile/customer_profile.dart';
import 'package:touch_me/favourite_screen.dart';
import 'package:touch_me/new_inside_sallon.dart';
import 'package:touch_me/payment_page.dart';
import 'package:touch_me/search_page.dart';
import 'custom_bottom_nav_bar.dart';
import 'my_gift_cards_screen.dart';
import 'merchant_list_screen.dart';
import 'services/merchant_service.dart';
import 'models/merchant.dart';

// Dummy placeholder screens for demo
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) => Center(child: Text("Search Page"));
}

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Center(child: Text("Profile Page"));
// }

class CustomerHomeScaffold extends StatefulWidget {
  final String token;
  final String customerId;
  final Map<String, dynamic> user;

  const CustomerHomeScaffold({
    super.key,
    required this.token,
    required this.customerId,
    required this.user,
  });

  @override
  State<CustomerHomeScaffold> createState() => _CustomerHomeScaffoldState();
}

class _CustomerHomeScaffoldState extends State<CustomerHomeScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Different tabs/screens
    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = CustomerHomeContent(
          token: widget.token,
          customerId: widget.customerId,
          user: widget.user,
        );
        break;
      case 1:
        body =  const AppointmentScreen();
        break;
      case 2:
        body = const FavouriteScreen();
        break;
      case 3:
        body = const ProfileScreen();
        break;
      default:
        body = const SearchPage(token: "token",);//Center(child: Text("Not Found"));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(child: body),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
