// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';

class UnitDialogbox extends StatefulWidget {
  const UnitDialogbox({super.key});

  @override
  State<UnitDialogbox> createState() => _UnitDialogboxState();
}

class _UnitDialogboxState extends State<UnitDialogbox> {
  // Controllers
  final setTemperatureController = TextEditingController();
  final watervaluesetController = TextEditingController();
  final vfdtargetfreqController = TextEditingController();
  final freshaircontrolController = TextEditingController();
  final setspeedperController = TextEditingController();
  // laoding flags
  bool isTemperature = false;
  bool isWatervalue = false;
  bool isVfdfrequency = false;
  bool isFreshair = false;
  bool isSpeedcontrol = false;

  // Error messages for each field
  String? temperatureError;
  String? watervalueError;
  String? vfdtargetfreqError;
  String? freshaircontrolError;
  String? setspeedperError;

  @override
  void dispose() {
    setTemperatureController.dispose();
    watervaluesetController.dispose();
    vfdtargetfreqController.dispose();
    freshaircontrolController.dispose();
    setspeedperController.dispose();
    super.dispose();
  }

  // Save button widget
  Widget saveButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 50,
      width: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Custom TextField widget
  Widget customTextfield(
    String label,
    TextEditingController controller, {
    String? errorText,
    String hintText = "",
  }) {
    // Theme colour ......
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkMode ? Colors.black12 : Colors.white;
    final labelColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        SpacerWidget.small,
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.30,
          height: 60,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: isDarkMode ? AppColors.green : AppColors.darkblue,
            style: TextStyle(color: labelColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              hintText: hintText,
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.green),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
          ),
        ),
      ],
    );
  }

  // Validation functions
  String? validateTemperature(String value) {
    if (value.isEmpty) return "Set Temperature value";
    final number = double.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < 15 || number > 25) return "Temperature between 15 to 25";
    return null;
  }

  String? validateWatervalue(String value) {
    if (value.isEmpty) return "Set Water value";
    final number = int.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < 0 || number > 100) return "Water value between 0 to 100";
    return null;
  }

  String? validatevfdFrequency(String value) {
    if (value.isEmpty) return "Set VFD Frequency";
    final number = double.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < 0 || number > 50) return "VFD Frequecny between 0 to 50";
    return null;
  }

  String? validateFreshairControl(String value) {
    if (value.isEmpty) return "Set Freshair Control";
    final number = int.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < 0 || number > 100) return "Freshair Control between 0 to 50";
    return null;
  }

  String? validateSpeedPercentage(String value) {
    if (value.isEmpty) return "Set Speed Percentage";
    final number = int.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < 0 || number > 100) return "Speed Percentage between 0 to 100";
    return null;
  }

  // write function
  Future<void> writeParameter(
    BuildContext context,
    int address,
    String value,
    String paramName,
  ) async {
    try {
      final writeValue = (double.parse(value) * 100).toInt();
      await context.read<ProviderServices>().writeRegister(address, writeValue);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$paramName changed to $value°C",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to changed $paramName: $e°C",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Alert Dialogue Widget ...........
  @override
  Widget build(BuildContext context) {
    // media quries for height & width ....
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SizedBox(
        height: screenHeight * 0.70,
        width: screenWidth * 0.50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Unit Operation",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SpacerWidget.size32,
              // Temperature Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customTextfield(
                    "Set Temperature",
                    setTemperatureController,
                    errorText: temperatureError,
                  ),
                  SpacerWidget.size32w,
                  saveButton("Save", () async {
                    setState(() {
                      temperatureError = validateTemperature(
                        setTemperatureController.text.trim(),
                      );
                    });
                    if (temperatureError == null) {
                      setState(() {
                        isTemperature = true; // start loading
                      });
                      // Delay time
                      await Future.delayed(const Duration(seconds: 5));
                      // write register
                      await writeParameter(
                        context,
                        29,
                        setTemperatureController.text.trim(),
                        "Set Temperature",
                      );
                      setState(() {
                        isTemperature = false;
                        // close the dialog box
                        Navigator.pop(context);
                      });
                      setTemperatureController.clear();
                    }
                  }),
                  SpacerWidget.size8w,
                  if (isTemperature)
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                ],
              ),
              SpacerWidget.size16,
              // Frequency Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customTextfield(
                    "Water Value",
                    watervaluesetController,
                    errorText: watervalueError,
                  ),
                  SpacerWidget.size32w,
                  saveButton("Save", () async {
                    setState(() {
                      watervalueError = validateWatervalue(
                        watervaluesetController.text.trim(),
                      );
                    });
                    if (watervalueError == null) {
                      setState(() {
                        isWatervalue = true;
                      });
                      // Delay time
                      await Future.delayed(const Duration(seconds: 5));
                      // Write Register
                      await writeParameter(
                        context,
                        23,
                        watervaluesetController.text.trim(),
                        "Water Value",
                      );
                      setState(() {
                        isWatervalue = false;
                        Navigator.pop(context);
                      });
                      watervaluesetController.clear();
                    }
                  }),
                  SpacerWidget.size8w,
                  if (isWatervalue)
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                ],
              ),
              SpacerWidget.size16,
              // VFD Target Freq
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customTextfield(
                    "VFD Target Frequency",
                    vfdtargetfreqController,
                    errorText: vfdtargetfreqError,
                  ),
                  SpacerWidget.size32w,
                  saveButton("Save", () async {
                    setState(() {
                      vfdtargetfreqError = validatevfdFrequency(
                        vfdtargetfreqController.text.trim(),
                      );
                    });
                    if (vfdtargetfreqError == null) {
                      setState(() {
                        isVfdfrequency = true;
                      });
                      await Future.delayed(const Duration(seconds: 5));
                      // Write Register
                      await writeParameter(
                        context,
                        100,
                        vfdtargetfreqController.text.trim(),
                        "VFD Target Frequency",
                      );
                      setState(() {
                        isVfdfrequency = false;
                        Navigator.pop(context);
                      });
                      vfdtargetfreqController.clear();
                    }
                  }),
                  SpacerWidget.size8w,
                  if (isVfdfrequency)
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customTextfield(
                    "Freshair Value",
                    freshaircontrolController,
                    errorText: freshaircontrolError,
                  ),
                  SpacerWidget.size32w,
                  saveButton("Save", () async {
                    setState(() {
                      freshaircontrolError = validateFreshairControl(
                        freshaircontrolController.text.trim(),
                      );
                    });
                    if (freshaircontrolError == null) {
                      setState(() {
                        isFreshair = true;
                      });
                      await Future.delayed(Duration(seconds: 5));
                      // Write Register
                      await writeParameter(
                        context,
                        24,
                        freshaircontrolController.text.trim(),
                        "Freshair Control",
                      );
                      setState(() {
                        isFreshair = false;
                      });

                      freshaircontrolController.clear();
                    }
                  }),
                  SpacerWidget.size8w,
                  if (isFreshair)
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                ],
              ),
              SpacerWidget.size16,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customTextfield(
                    "Speed Percentage",
                    setspeedperController,
                    errorText: setspeedperError,
                  ),
                  SpacerWidget.size32w,
                  saveButton("Save", () async {
                    setState(() {
                      setspeedperError = validateSpeedPercentage(
                        setspeedperController.text.trim(),
                      );
                    });
                    if (setspeedperError == null) {
                      setState(() {
                        isSpeedcontrol = true;
                      });
                      await Future.delayed(Duration(seconds: 5));
                      await writeParameter(
                        context,
                        101,
                        setspeedperController.text.trim(),
                        "Speed Control",
                      );
                      setState(() {
                        isSpeedcontrol = false;
                      });
                      setspeedperController.clear();
                    }
                  }),
                  SpacerWidget.size8w,
                  if (isSpeedcontrol)
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      // close button ...
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Close",
            style: TextStyle(fontSize: 16, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
