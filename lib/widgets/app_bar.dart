import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zedbeemodbus/main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black38 : Color(0xFF003D76);
    final textColor = Colors.white;
    return AppBar(
      backgroundColor: backgroundColor,
      leading: IconButton(
        icon: Icon(Icons.menu, color: textColor),
        tooltip: "Menu",
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text("Menu", style: TextStyle(color: textColor)),
      actions: [
        IconButton(
          onPressed: () {
            themeNotifier.toggleTheme(); // Toggle the theme globally change
          },
          icon: Icon(
            isDarkMode ? Icons.wb_sunny : Icons.dark_mode,
            color: Colors.white,
          ),
          color: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Image.asset('images/logo.png', height: 36),
        ),
      ],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
