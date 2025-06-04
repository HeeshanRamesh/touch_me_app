// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:touch_me/customer_home_content.dart';
// import 'package:touch_me/upcoming_appointment_screen.dart';
// import 'custom_bottom_nav_bar.dart';
// import 'favourite_screen.dart';
// import 'services/services.dart';
// import 'inside_category_screen.dart';
// import 'one_saloon_inside_screen.dart';
// import 'profile_screen.dart';
// import 'search_screen.dart';

// class CustomerHomeScreen extends StatefulWidget {
//   const CustomerHomeScreen({super.key});

//   @override
//   State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
// }

// class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
//   int _selectedIndex = 0;
//   Future<List<Service>> _servicesFuture = Future.value([]);
//   String? _authToken;

//   @override
//   void initState() {
//     super.initState();
//     _loadTokenAndFetchServices();
//   }

//   Future<void> _loadTokenAndFetchServices() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');

//     if (token != null && token.isNotEmpty) {
//       setState(() {
//         _authToken = token;
//         _servicesFuture = ServiceApi().fetchServices(token, context);
//       });
//     }
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final customNavBar = CustomBottomNavBar(
//       currentIndex: _selectedIndex,
//       onTap: _onItemTapped,
//       onSearchPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const InsideCategoryScreen()),
//         );
//       },
//     );

//     final List<Widget> _screens = [
//       CustomerHomeContent(servicesFuture: _servicesFuture),
//       const UpcomingAppointmentScreen(),
//       const FavouriteScreen(),
//       const ProfileScreen(),
//     ];

//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: customNavBar,
//       floatingActionButton: customNavBar.getFloatingActionButton(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }
