import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/view_Pages/pin_screen.dart';

class EnterPage extends StatefulWidget {
  const EnterPage({super.key});

  @override
  State<EnterPage> createState() => _EnterPageState();
}

class _EnterPageState extends State<EnterPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Dark theme color detection
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : AppColors.darkblue;

    // Responsive ratios
    final titleFontSize = width * 0.08; // dynamic title font size
    final buttonWidth = width * 0.5;
    final buttonHeight = height * 0.07;
    final logoWidth = width * 0.35;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: height,
            width: width,
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.15),

                // App Title
                Text(
                  "AIR HANDLING UNIT",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: titleFontSize,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: width * 0.01,
                  ),
                ),

                SizedBox(height: height * 0.08),

                // Logo (scales dynamically)
                Image.asset(
                  "images/logo.png",
                  width: logoWidth,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: height * 0.08),

                // Go To Button
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext content) => const PinScreen(),
                    );
                  },
                  child: Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade500,
                      borderRadius: BorderRadius.circular(buttonHeight / 2),
                      boxShadow: [
                        BoxShadow(
                          color: textColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Go To",
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.05,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
