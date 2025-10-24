// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fields/colors.dart';
import '../services_class/provider_services.dart';

class ParametersListScreen extends StatefulWidget {
  const ParametersListScreen({super.key});

  @override
  State<ParametersListScreen> createState() => _ParametersListScreenState();
}

class _ParametersListScreenState extends State<ParametersListScreen> {
  // controller ........
  final TextEditingController valueController = TextEditingController();
  bool isSaving = false; // boolean for save button

  List<int> selectedIndexes = []; // store the selected params..

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProviderServices>(context, listen: false);
    provider.fetchRegisters();
    provider.startAutoRefresh(); // auto refresh 5 seconds
  }

  // save the selected parameters
  void saveSelectedParameters() async {
    final provider = Provider.of<ProviderServices>(context, listen: false);
    provider.addParameters(selectedIndexes, provider.allParameters);
    setState(() => isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
     final provider = Provider.of<ProviderServices>(context);
    final parameters = provider.allParameters;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive configuration
    final crossAxisCount = width < 600
        ? 2
        : width < 900
            ? 3
            : 4; // automatically adjust columns based on screen width
    final textScale = (width / 400).clamp(0.8, 1.4); // text scaling factor
    final valueFontSize = 20 * textScale;
    final nameFontSize = 14 * textScale;
    final cardPadding = width * 0.025;
    final buttonHeight = height * 0.06;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Modbus Parameters",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.darkblue,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.green,
            onRefresh: () => provider.fetchRegisters(),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(width * 0.025),
                    itemCount: parameters.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: height * 0.015,
                      crossAxisSpacing: width * 0.025,
                      childAspectRatio: width < 600 ? 1.8 : 2.2,
                    ),
                    itemBuilder: (context, index) {
                      final param = parameters[index];
                      final isSelected = selectedIndexes.contains(index);

                      final value = index < provider.latestValues.length
                          ? provider.getFormattedValue(
                              param["name"] as String,
                              provider.latestValues[index],
                            )
                          : "--";

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedIndexes.remove(index);
                            } else {
                              if (selectedIndexes.length < 5) {
                                selectedIndexes.add(index);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Only 5 parameters can be selected at a time!",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(cardPadding * 0.6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.green
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                param["name"]!,
                                style: TextStyle(
                                  fontSize: nameFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: height * 0.008),
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: valueFontSize,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: height * 0.12),
              ],
            ),
          ),

          // Save Button
          Positioned(
            left: width * 0.04,
            right: width * 0.04,
            bottom: height * 0.03,
            child: SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveSelectedParameters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ? SizedBox(
                        width: buttonHeight * 0.5,
                        height: buttonHeight * 0.5,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        "Save Parameters",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
