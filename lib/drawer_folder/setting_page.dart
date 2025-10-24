// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/view_Pages/parameters_list.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderServices>().loadSavedData();
    });
  }

  // save button
  Future<void> saveSetting() async {
    final provider = Provider.of<ProviderServices>(context, listen: false);
    await provider.saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Parameters saved successfully',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // clear confirmation dialog
  void showClearParametersAlert(BuildContext context) {
    final provider = Provider.of<ProviderServices>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear Parameters'),
          content: const Text('Do you want to clear all the parameters?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('No', style: TextStyle(color: AppColors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                provider.clearParameters();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Parameters cleared successfully',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Yes', style: TextStyle(color: AppColors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderServices>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final isTablet = width > 800;
    final scale = (width / 400).clamp(0.8, 1.4);
    final buttonFont = 16 * scale;
    final labelFont = 14 * scale;

    return Consumer<ProviderServices>(
      builder: (context, value, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
          drawer: AppDrawer(selectedScreen: 'settings'),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.03),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * 0.03),

                    // === Top Action Buttons ===
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: width * 0.025,
                      runSpacing: 12,
                      children: [
                        // Save button
                        ElevatedButton.icon(
                          onPressed: saveSetting,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkblue,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: height * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            "Save",
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: buttonFont,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Add Parameter
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ParametersListScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: height * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.list_alt_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Add Parameter",
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: buttonFont,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Clear Parameters
                        ElevatedButton(
                          onPressed: () => showClearParametersAlert(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.all(width * 0.03),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.04),

                    // === AHU Image Canvas ===
                    Container(
                      width: double.infinity,
                      height: isTablet ? height * 0.7 : height * 0.65,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Stack(
                        children: [
                          // background image
                          Center(
                            child: Image.asset(
                              "images/ahuimage.png",
                              width: width * 0.9,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),

                          // draggable parameter boxes
                          ...provider.parameters.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;

                            final maxWidth = width * 0.9;
                            final maxHeight = isTablet
                                ? height * 0.6
                                : height * 0.55; // image boundaries

                            return Positioned(
                              left: (item.dx).clamp(0.0, maxWidth - 100),
                              top: (item.dy).clamp(0.0, maxHeight - 40),
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  provider.updatePosition(
                                    index,
                                    (item.dx + details.delta.dx).clamp(
                                      0.0,
                                      maxWidth - 100,
                                    ),
                                    (item.dy + details.delta.dy).clamp(
                                      0.0,
                                      maxHeight - 40,
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.02,
                                    vertical: height * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${item.text}: ${provider.getFormattedValue(item.text, int.tryParse(item.value) ?? 0)}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: labelFont,
                                        ),
                                      ),
                                      SizedBox(width: width * 0.01),
                                      InkWell(
                                        onTap: () => provider.removeParameter(
                                          item.registerIndex ?? 0,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.05),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
