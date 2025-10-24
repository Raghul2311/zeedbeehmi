// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zedbeemodbus/drawer_folder/home_screen.dart';
import 'package:zedbeemodbus/fields/colors.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  bool _isLoading = false; // for next button
  // pin controller
  final TextEditingController pinController = TextEditingController();
  // pin validate function.................
  void _validatePin() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (pinController.text == '1111') {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pin Incorrect'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
   final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Responsive sizing ratios
    final dialogWidth = width * 0.8; // 80% of screen width
    final dialogHeight = height * 0.45; // 45% of screen height
    final buttonHeight = height * 0.06;
    final buttonWidth = width * 0.35;
    final fontSize = width * 0.045;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: AppColors.lightblue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, // Responsive padding
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Enter Your PIN",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: fontSize,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.04),
                TextFormField(
                  cursorColor: Colors.white,
                  controller: pinController,
                  maxLength: 4,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize * 0.9,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    suffixIcon: Icon(
                      Icons.lock,
                      color: AppColors.green,
                      size: fontSize,
                    ),
                    filled: true,
                    fillColor: const Color(0xff2C2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.04,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),
                InkWell(
                  onTap: _isLoading ? null : _validatePin,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: buttonHeight,
                    width: buttonWidth,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: buttonHeight * 0.4,
                              height: buttonHeight * 0.4,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              "NEXT",
                              style: GoogleFonts.openSans(
                                fontSize: fontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
