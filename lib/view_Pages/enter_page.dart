import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/view_Pages/pin_screen.dart';

class EnterPage extends StatefulWidget {
  const EnterPage({super.key});

  @override
  State<EnterPage> createState() => _EnterPageState();
}

class _EnterPageState extends State<EnterPage> {
  @override
  Widget build(BuildContext context) {
    // media query width size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
     // Dark theme color
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white54 : AppColors.darkblue;
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // theme background color
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: BoxDecoration(
            // color: Colors.grey.shade200
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 190),
                Text(
                  "AIR HANDLING UNIT",
                  style: GoogleFonts.openSans(
                    fontSize: 70,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                  ),
                ),
                SpacerWidget.size64,
                Image.asset("images/logo.png", width: screenWidth * 0.3),
                SpacerWidget.size64,
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext content) => const PinScreen(),
                    );
                  },
                  // Go to Button............
                  child: Container(
                    width: screenWidth / 5,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade500,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: textColor,
                          blurRadius: 5,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Go To",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
