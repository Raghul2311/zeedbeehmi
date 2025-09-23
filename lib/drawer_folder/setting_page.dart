// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/view_Pages/parameters_list.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Key to access app bar...
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  // To store the draggable items.........
  final List<ParameterModel> draggableItems = [];

  @override
  void initState() {
    super.initState();
    // Get the loaded parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderServices>().loadSavedData();
    });
  }

  // Save button for selected parameters ....
  void saveSetting() async {
    final provider = Provider.of<ProviderServices>(context, listen: false);
    await provider.saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parameter Saved', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // media queryies for height and width
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // provider function for parameters...............
    final provider = Provider.of<ProviderServices>(context);
    // Alert box for parameter ........
    void showClearParametersAlert(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Clear Parameters'),
            content: const Text('Do you want to clear all the parameters?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(); // Dismiss the dialog for "No"
                },
                child: Text('No', style: TextStyle(color: AppColors.green)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(); // Dismiss the dialog for "Yes"
                  provider.clearParameters(); // clear params
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Parmeter Cleared successfully",
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

    return Consumer<ProviderServices>(
      builder: (context, value, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
          drawer: AppDrawer(selectedScreen: 'settings'),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpacerWidget.size32,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Save Button
                        InkWell(
                          onTap: () {
                            // save Parameters Function
                            saveSetting();
                          },
                          child: Container(
                            height: 50,
                            width: 130,
                            decoration: BoxDecoration(
                              color: AppColors.darkblue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, color: Colors.white),
                                SpacerWidget.size8w,
                                Text(
                                  "Save",
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SpacerWidget.size16w,
                        // Add Parameter Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParametersListScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.list_alt_rounded,
                                  color: Colors.white,
                                ),
                                SpacerWidget.size8w,
                                Text(
                                  "Add Parameter",
                                  style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SpacerWidget.size16w,
                        // clear all parmeter
                        GestureDetector(
                          onTap: () {
                            showClearParametersAlert(context);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SpacerWidget.size32,
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        height: screenHeight * 0.70,
                        width: screenWidth,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            // Static image inside container
                            Center(
                              child: Image.asset(
                                "images/ahuimage.png",
                                height: screenHeight,
                                width: screenWidth * 0.90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Draggable parameters
                            ...provider.parameters.asMap().entries.map((e) {
                              final index = e.key;
                              final item = e.value;
                              return Positioned(
                                left: item.dx,
                                top: item.dy,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    provider.updatePosition(
                                      index,
                                      (item.dx + details.delta.dx).clamp(
                                        0.0,
                                        1050.0,
                                      ),
                                      (item.dy + details.delta.dy).clamp(
                                        0.0,
                                        500.0,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "${item.text}: ${provider.getFormattedValue(item.text, int.tryParse(item.value) ?? 0)}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              provider.removeParameter(
                                                item.registerIndex!,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
