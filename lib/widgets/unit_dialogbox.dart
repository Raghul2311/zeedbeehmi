// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

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
  final _formKey = GlobalKey<FormState>(); // field form key
  bool isLoading = false; // loading indicator

  // Controllers
  final setTemperatureController = TextEditingController();
  final watervaluesetController = TextEditingController();
  final vfdtargetfreqController = TextEditingController();
  final freshaircontrolController = TextEditingController();
  final setspeedperController = TextEditingController();

  @override
  void dispose() {
    setTemperatureController.dispose();
    watervaluesetController.dispose();
    vfdtargetfreqController.dispose();
    freshaircontrolController.dispose();
    setspeedperController.dispose();
    super.dispose();
  }

  // Write function
  Future<void> writeParameter(
    BuildContext context,
    int address,
    String value,
    String paramName,
  ) async {
    try {
      final writeValue = (double.parse(value) * 100).toInt();
      await context.read<ProviderServices>().writeRegister(address, writeValue);
    } catch (_) {}
  }

  // Read function
  Future<void> readParameter(
    BuildContext context,
    int address,
    TextEditingController controller,
    String paramName,
  ) async {
    try {
      await context.read<ProviderServices>().fetchRegisters();
      if (!mounted) return;
      // provider parameters
      final latestValues = context.read<ProviderServices>().latestValues;
      if (address < latestValues.length) {
        final double value = latestValues[address] / 100;
        controller.text = value.toStringAsFixed(2);
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    // auto read parameters in there fields
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await readParameter(context, 29, setTemperatureController, "Set Temp");
      if (!mounted) return;
      await readParameter(context, 23, watervaluesetController, "Water Value");
      if (!mounted) return;
      await readParameter(context, 100, vfdtargetfreqController, "VFD Freq");
      if (!mounted) return;
      await readParameter(context, 24, freshaircontrolController, "Freshair");
      if (!mounted) return;
      await readParameter(context, 101, setspeedperController, "Speed %");
    });
  }

  // Validator
  String? numberValidator(String? value, String label, double min, double max) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < min || number > max) {
      return "$label must be between $min - $max";
    }
    return null;
  }

  // Custom textfield
  Widget _customTextfield(
    String label,
    TextEditingController controller, {
    String hintText = "",
    FormFieldValidator<String>? validator,
  }) {
    // color themes for fields
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkMode ? Colors.black12 : Colors.white;
    final labelColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        SpacerWidget.small,
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.28,
          height: 60,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: isDarkMode ? AppColors.green : AppColors.darkblue,
            style: TextStyle(color: labelColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              hintText: hintText,
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
            validator: validator,
          ),
        ),
      ],
    );
  }

  // Handle Set button
  void _handleSetButton() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    final parameters = [
      {
        "controller": setTemperatureController,
        "address": 29,
        "name": "Set Temp",
      },
      {
        "controller": watervaluesetController,
        "address": 23,
        "name": "Water Value",
      },
      {
        "controller": vfdtargetfreqController,
        "address": 100,
        "name": "VFD Frequency",
      },
      {
        "controller": freshaircontrolController,
        "address": 24,
        "name": "Freshair",
      },
      {"controller": setspeedperController, "address": 101, "name": "Speed %"},
    ];

    for (final param in parameters) {
      final controller = param["controller"] as TextEditingController;
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        await writeParameter(
          context,
          param["address"] as int,
          text,
          param["name"] as String,
        );
      }
    }

    setState(() => isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Parameters updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
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
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _customTextfield(
                    "Set Temperature",
                    setTemperatureController,
                    hintText: "15-25",
                    validator: (value) =>
                        numberValidator(value, "Set Temp", 15, 25),
                  ),
                  _customTextfield(
                    "Water Value",
                    watervaluesetController,
                    hintText: "0-100",
                    validator: (value) =>
                        numberValidator(value, "Water Value", 0, 100),
                  ),
                  _customTextfield(
                    "VFD Target Frequency",
                    vfdtargetfreqController,
                    hintText: "0-50",
                    validator: (value) =>
                        numberValidator(value, "VFD Freq", 0, 50),
                  ),
                  _customTextfield(
                    "Freshair Control",
                    freshaircontrolController,
                    hintText: "0-50",
                    validator: (value) =>
                        numberValidator(value, "Freshair", 0, 50),
                  ),
                  _customTextfield(
                    "Speed Percentage",
                    setspeedperController,
                    hintText: "0-100",
                    validator: (value) =>
                        numberValidator(value, "Speed %", 0, 100),
                  ),
                ],
              ),
              SpacerWidget.size32,
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: screenWidth * 0.20,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isLoading ? null : _handleSetButton,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            "Set Parameters",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
