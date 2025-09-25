// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/drawer_folder/home_screen.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/shared_pref_helper.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';
import 'package:zedbeemodbus/widgets/toggle_button.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  // Global keys..
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // app bar key
  final _formKey = GlobalKey<FormState>(); // text filed key
  bool isLoading = false; // Parameter indicator

  // controllers for fields ...
  final minTemController = TextEditingController();
  final maxTempController = TextEditingController();
  final minFlowController = TextEditingController();
  final maxFlowController = TextEditingController();
  final maxFreqController = TextEditingController();
  final minFreqController = TextEditingController();
  final btucontroller = TextEditingController(); //
  final valvecontroller = TextEditingController();
  final actuatordircontroller = TextEditingController(); //
  final inletcontroller = TextEditingController();
  final deltacontroller = TextEditingController();
  final pressurecontroller = TextEditingController();
  final ductprecontroller = TextEditingController();
  final waterprescontroller = TextEditingController();
  final PDIcontroller = TextEditingController();
  final minspeedcontroller = TextEditingController(); //
  final maxspeedcontroller = TextEditingController(); //
  final ipcontroller = TextEditingController(); //ip
  // Total 17 controllers ....

  @override
  void dispose() {
    minTemController.dispose();
    maxTempController.dispose();
    minFlowController.dispose();
    maxFlowController.dispose();
    maxFreqController.dispose();
    minFreqController.dispose();
    valvecontroller.dispose();
    inletcontroller.dispose();
    deltacontroller.dispose();
    pressurecontroller.dispose();
    waterprescontroller.dispose();
    ductprecontroller.dispose();
    PDIcontroller.dispose();
    ipcontroller.dispose();
    super.dispose();
  }

  // write function in same textfield
  Future<void> writeParameter(
    BuildContext context,
    int address,
    String value,
    String paramName,
  ) async {
    try {
      // Accept int or float values ...
      final writeValue = (double.parse(value) / 100).toInt();

      await context.read<ProviderServices>().writeRegister(address, writeValue);
    } catch (_) {}
  }

  // Read Function in same field
  Future<void> readParameter(
    BuildContext context,
    int address,
    TextEditingController controller,
    String paramName,
  ) async {
    try {
      // Fetch latest values from provider
      await context.read<ProviderServices>().fetchRegisters();
      if (!mounted) return; // ✅ prevents crash
      final latestValues = context.read<ProviderServices>().latestValues;

      if (address < latestValues.length) {
        // Divide by 100 for float values
        final double value = latestValues[address] / 100;
        controller.text = value.toStringAsFixed(2);
      }
    } catch (_) {}
  }

  String? _validationError; // error val
  bool setLoading = false;
  // save ip address in array
  List<String> ipHistory = [];

  // validate the IP format
  void _validateIp(String value) {
    if (value.isEmpty) {
      setState(() => _validationError = "Enter valid IP Address");
      return;
    }
    // format of standard ip address
    final RegExp ipRegex = RegExp(
      r"^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]?|0)\.){3}"
      r"(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]?|0)$",
    );

    if (!ipRegex.hasMatch(value)) {
      setState(() => _validationError = "Invalid IP format (e.g., 127.0.0.1)");
    } else {
      setState(() => _validationError = null);
    }
  }

  // load ip history function
  Future<void> loadIpHistory() async {
    final history = await SharedPrefHelper.getIpHistory();
    setState(() {
      ipHistory = history;
    });
  }

  @override
  void initState() {
    super.initState();
    // Automatically load the values in fields
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return; // ✅ prevents crash
      final lastIp = await SharedPrefHelper.getIp();
      if (lastIp != null && lastIp.isNotEmpty) {
        ipcontroller.text = lastIp;
        _validateIp(lastIp);
      }
      // Get the ip history
      loadIpHistory();
      // read parameters values
      await readParameter(context, 49, minTemController, "Min Temp");
      await readParameter(context, 50, maxTempController, "Max Temp");
      await readParameter(context, 36, minFlowController, "Min Flowrate");
      await readParameter(context, 35, maxFlowController, "Max Flowrate");
      await readParameter(context, 30, minFreqController, "Min Freq");
      await readParameter(context, 31, maxFreqController, "Max Freq");
      await readParameter(context, 23, valvecontroller, "water value");
      await readParameter(context, 38, inletcontroller, "Inlet Threshold");
      await readParameter(context, 43, deltacontroller, "WaterdeltaT");
      await readParameter(context, 4, waterprescontroller, "Water Pressure");
      await readParameter(context, 5, ductprecontroller, "Duct Pressure");
      await readParameter(context, 37, pressurecontroller, "Pressure Constant");
      await readParameter(context, 33, PDIcontroller, "PDI Constant");
    });
  }

  // set button function .....
  void _handleSetButton() async {
    if (minTemController.text.isEmpty &&
        maxTempController.text.isEmpty &&
        minFlowController.text.isEmpty &&
        maxFlowController.text.isEmpty &&
        minFreqController.text.isEmpty &&
        maxFreqController.text.isEmpty &&
        valvecontroller.text.isEmpty &&
        inletcontroller.text.isEmpty &&
        deltacontroller.text.isEmpty &&
        waterprescontroller.text.isEmpty &&
        pressurecontroller.text.isEmpty &&
        PDIcontroller.text.isEmpty) {
      return;
    }
    // validate fields ..
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isLoading = true; // show loading
    });

    // Delay time
    await Future.delayed(const Duration(seconds: 2));
    // mapping register start here .....

    final parameter = [
      {"controller": minTemController, "address": 49, "name": "Min Temp"},
      {"controller": maxTempController, "address": 50, "name": "Max Temp"},
      {"controller": minFlowController, "address": 36, "name": "Min Flowrate"},
      {"controller": maxFlowController, "address": 35, "name": "Max Flowrate"},
      {"controller": minFreqController, "address": 30, "name": "Min Freq"},
      {"controller": maxFreqController, "address": 31, "name": "Max Freq"},
      {"controller": valvecontroller, "address": 23, "name": "Water valve"},
      {"controller": inletcontroller, "address": 38, "name": "Inlet Threshold"},
      {"controller": deltacontroller, "address": 43, "name": "Water Delta"},
      {"controller": waterprescontroller, "address": 4, "name": "Water Pres"},
      {"controller": ductprecontroller, "address": 5, "name": "Duct Pressure"},
      {"controller": pressurecontroller, "address": 37, "name": "Pressure"},
      {"controller": PDIcontroller, "address": 33, "name": "PDI Constant"},
    ];
    // loop and call writeParameter
    for (final param in parameter) {
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
    setState(() {
      isLoading = false; // stop loading
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Parameters set successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Text field widget ...

  Widget _customTextfield(
    String label,
    TextEditingController controller, {
    String hintText = "", // hint text
    FormFieldValidator<String>? validator, // text field validator
  }) {
    final screenWidth = MediaQuery.of(context).size.width; // width
    // dark theme color
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkMode ? Colors.black12 : Colors.white;
    final labelColor = isDarkMode ? Colors.white : Colors.black87;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        SpacerWidget.small,
        SizedBox(
          width: screenWidth * 0.30,
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

  // validator for text fields
  String? numberValidator(String? value, String label, double min, double max) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final number = double.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < min || number > max) {
      return "Value must be between $min - $max";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Consumer(
      builder: (context, value, child) {
        return Scaffold(
          // Floating app bar  ......
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endContained,
          key: _scaffoldKey,
          appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
          drawer: AppDrawer(selectedScreen: 'configure'),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade400),
                    child: Center(
                      child: Text(
                        "Configuration Parameter",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 55,
                          width: screenWidth * 0.14,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              _handleSetButton(); // parameter button function
                            },
                            child: Center(
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      "Set Parameter",
                                      style: GoogleFonts.openSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SpacerWidget.size32,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _customTextfield(
                              "Min Temp",
                              minTemController,
                              hintText: "0-50",
                              validator: (value) =>
                                  numberValidator(value, "Min Temp", 0, 50),
                            ),
                            SpacerWidget.size16w,
                            _customTextfield(
                              "Max Temp",
                              maxTempController,
                              hintText: "0-50",
                              validator: (value) =>
                                  numberValidator(value, "Max Temp", 0, 50),
                            ),
                            SpacerWidget.size16w,
                            _customTextfield(
                              "Min Flowrate",
                              minFlowController,
                              hintText: "0-50",
                              validator: (value) =>
                                  numberValidator(value, "Min Flowrate", 0, 50),
                            ),
                            SpacerWidget.size16w,
                          ],
                        ),
                        Row(
                          children: [
                            _customTextfield(
                              "Max Flowrate",
                              maxFlowController,
                              hintText: "0-50",
                              validator: (value) =>
                                  numberValidator(value, "Max Flowrate", 0, 50),
                            ),
                            SpacerWidget.size16w,
                            _customTextfield(
                              "Max Freq",
                              maxFreqController,
                              hintText: "0-50",
                              validator: (value) => numberValidator(
                                value,
                                "Max Frequency",
                                0,
                                50,
                              ),
                            ),
                            SpacerWidget.size16w,
                            _customTextfield(
                              "Min Freq",
                              minFreqController,
                              hintText: "0-50",
                              validator: (value) => numberValidator(
                                value,
                                "Min Frequecny",
                                0,
                                50,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _customTextfield(
                              "water valve",
                              valvecontroller,
                              hintText: "0-100",
                              validator: (value) =>
                                  numberValidator(value, "Water value", 0, 100),
                            ),
                            SpacerWidget.size16w,
                            _customTextfield(
                              "Inlet Threshold",
                              inletcontroller,
                              hintText: "0-15",
                              validator: (value) => numberValidator(
                                value,
                                "Inlet Threshold",
                                0,
                                15,
                              ),
                            ),
                            SpacerWidget.size16w,
                            _customTextfield(
                              "water delta T",
                              deltacontroller,
                              hintText: "0-10",
                              validator: (value) =>
                                  numberValidator(value, "Water Delta", 0, 10),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _customTextfield(
                              "Water Pressure",
                              waterprescontroller,
                              hintText: "0-50",
                              validator: (value) => numberValidator(
                                value,
                                "Water Pressure",
                                0,
                                50,
                              ),
                            ),
                            SpacerWidget.size16w,
                            _customTextfield(
                              "Duct pressure",
                              ductprecontroller,
                              hintText: "0-2500",
                              validator: (value) => numberValidator(
                                value,
                                "Duct Pressure",
                                0,
                                2500,
                              ),
                            ),
                            SpacerWidget.size16w,
                            _customTextfield(
                              "Pressure constant",
                              pressurecontroller,
                              hintText: "0-5",
                              validator: (value) => numberValidator(
                                value,
                                "Pressure Constant",
                                0,
                                5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _customTextfield(
                              "PDI constant",
                              PDIcontroller,
                              hintText: "0-10",
                              validator: (value) =>
                                  numberValidator(value, "PDI Constant", 0, 10),
                            ),
                          ],
                        ),
                        SpacerWidget.size32,
                        // configuration toggle button
                        Row(
                          children: [
                            // Internal and External
                            CustomToggleContainer(
                              title: "BTU Selection",
                              options: ["Internal", "External"],
                              fillColor: Colors.green,
                              splashColor: Colors.green.shade100,
                              titleColor: Colors.green,
                            ),
                            SpacerWidget.size64w,
                            // temp & pressure
                            CustomToggleContainer(
                              title: "Control",
                              options: ["Temperature", "Pressure"],
                              fillColor: Colors.red,
                              splashColor: Colors.red.shade100,
                              titleColor: Colors.red,
                            ),
                            SpacerWidget.size64w,
                            // Actuator Direction
                            CustomToggleContainer(
                              title: "Actuator Direction",
                              options: ['Forward', 'Reverse'],
                              fillColor: Colors.blue,
                              splashColor: Colors.blue.shade100,
                              titleColor: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  // ip container
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade400),
                    child: Center(
                      child: Text(
                        "IP Configuration",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SpacerWidget.size32,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth / 3,
                          child: TextFormField(
                            controller: ipcontroller,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  ipcontroller.clear();
                                },
                                icon: Icon(Icons.close_rounded),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _validationError == null
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              labelText: "IP Address",
                              hintText: "e.g., 192.168.1.1",
                              border: OutlineInputBorder(),
                              errorText: _validationError,
                            ),
                            onChanged: _validateIp,
                            onFieldSubmitted: _validateIp,
                          ),
                        ),
                        SpacerWidget.medium,
                        TextButton(
                          onPressed: () async {
                            await SharedPrefHelper.clearIpHistory();
                            setState(() {
                              ipHistory.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "IP history cleared",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor: Colors.amberAccent,
                                ),
                              );
                            });
                          },
                          child: Text(
                            "Clear All",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // Recent ip section ..
                        if (ipHistory.isNotEmpty) ...[
                          SpacerWidget.large,
                          Text(
                            "Recent IPs :",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SpacerWidget.medium,
                          // ip address stored as map
                          Wrap(
                            spacing: 10,
                            children: ipHistory.map((ip) {
                              return ChoiceChip(
                                label: Text(ip),
                                selected: ipcontroller.text == ip,
                                onSelected: (_) {
                                  setState(() {
                                    ipcontroller.text = ip;
                                    _validateIp(ip);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        SizedBox(height: 40),
                        // set IP button
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkblue,
                                  disabledBackgroundColor: AppColors.darkblue,
                                ),
                                onPressed:
                                    _validationError == null &&
                                        ipcontroller.text.isNotEmpty &&
                                        !setLoading
                                    ? () async {
                                        setState(() {
                                          setLoading = true;
                                        });
                                        final newIp = ipcontroller.text;
                                        try {
                                          // save & store history & update ip                                  await SharedPrefHelper.saveIp(newIp);
                                          await SharedPrefHelper.saveIpHistory(
                                            newIp,
                                          );
                                          // save last ip
                                          await SharedPrefHelper.saveIp(newIp);
                                          // update ip
                                          await context
                                              .read<ProviderServices>()
                                              .updateIp(newIp);
                                          await Future.delayed(
                                            const Duration(seconds: 3),
                                          );
                                          // success message in home screen
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.amber,
                                              content: Text(
                                                "IP Address $newIp connected!",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => HomeScreen(),
                                            ),
                                          );
                                        } finally {
                                          if (mounted) {
                                            if (mounted) {
                                              setState(
                                                () => setLoading = false,
                                              );
                                              await loadIpHistory();
                                            }
                                          }
                                        }
                                      }
                                    : null,
                                child: setLoading
                                    // circle indicator
                                    ? SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        "Set IP",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: 20),
                            // cancel button
                            SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  disabledBackgroundColor: Colors.redAccent,
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 200),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
