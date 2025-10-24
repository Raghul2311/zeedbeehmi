// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:zedbeemodbus/view_Pages/enter_page.dart';
import 'package:zedbeemodbus/fields/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // loading time
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EnterPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get device size
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Responsive logo
            Image.asset(
              "images/logo.png",
              height: height * 0.15, // 15% of screen height
              width: width * 0.4, // 40% of screen width
              fit: BoxFit.contain,
            ),
            SizedBox(height: height * 0.05), // responsive vertical spacing
            SizedBox(
              height: height * 0.08, // 8% of screen height
              width: height * 0.08,  // keep it square
              child: CircularProgressIndicator(
                strokeWidth: height * 0.008, // stroke scales too
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
