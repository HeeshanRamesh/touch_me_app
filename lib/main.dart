import 'package:flutter/material.dart';
import 'package:touch_me/pages/onbording1page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/firebase_options.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/pages/customer_home_scaffold.dart';
import 'package:touch_me/pages/merchant_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Next Look',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16.0)),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // Fade-in animation for slogan
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () async {
      if (!mounted) return;

      final _storage = const FlutterSecureStorage();
      final role = await _storage.read(key: 'user_role');

      Widget destination;

      if (role == 'customer') {
        final token = await _storage.read(key: 'auth_token') ?? '';
        final customerId = await _storage.read(key: 'user_id') ?? '';
        final userDataJson = await _storage.read(key: 'user_data') ?? '{}';
        final userData = json.decode(userDataJson) as Map<String, dynamic>;

        destination = CustomerHomeScaffold(
          token: token,
          customerId: customerId,
          user: userData,
        );
      } else if (role == 'merchant') {
        final ownerName = await _storage.read(key: 'ownerName') ?? 'Merchant';

        destination = MerchantPage(userName: ownerName);
      } else {
        // Not logged in, go to onboarding
        destination = const Onboarding1Page();
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double logoHeight = MediaQuery.of(context).size.height * 0.12;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_screen.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: logoHeight * 0.5),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}