import 'package:flutter/material.dart';
import 'onbording1page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
        fontFamily: 'Poppins', // Set your font here if you like
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
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Onboarding1Page(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
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
              // Add a logo here if you have one
              // Center(
              //   child: Image.asset('assets/logo.png', height: logoHeight),
              // ),
              const Spacer(),
              //const SizedBox(height: 18),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 24.0),
              //   child: Text(
              //     'A product of VVH Solutions',
              //     style: TextStyle(
              //       fontSize: 12,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.black54,
              //       letterSpacing: 1.1,
              //       shadows: [
              //         Shadow(
              //           blurRadius: 3,
              //           color: Colors.white,
              //           offset: Offset(0, 1),
              //         ),
              //       ],
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
