// ignore_for_file: unused_local_variable, deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';
import 'package:zedbeemodbus/widgets/unit_dialogbox.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String currentTime = ''; // store current time
  bool _isLoading = false; // loading indicator
  List<ParameterModel> savedParams = []; // To save the parameters

  @override
  void initState() {
    super.initState();
    updateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) => updateTime());
    final provider = context.read<ProviderServices>(); // To read the live data
    provider.startAutoRefresh(); // refresh every 5 seconds...
    // store the loaded parameter and show ....
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderServices>().loadSavedData();
    });
  }

  // To get the upadated time...........
  void updateTime() {
    final nowUtc = DateTime.now().toUtc();
    final istTime = nowUtc.add(const Duration(hours: 5, minutes: 30));
    final formatted = DateFormat('hh:mm:ss a').format(istTime);
    if (!mounted) return;
    setState(() => currentTime = formatted);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final provider = context.watch<ProviderServices>();
    final latestValue = provider.latestValues;
    final statusValue = latestValue.isNotEmpty ? latestValue[0] : 0;

    // Responsive sizing
    final fontScale = (width / 400).clamp(0.8, 1.4);
    final labelFont = 20 * fontScale;
    final statusFont = 24 * fontScale;
    final timeFont = 18 * fontScale;
    final buttonFont = 16 * fontScale;

    final isTablet = width > 800;

    return Consumer<ProviderServices>(
      builder: (context, value, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
          drawer: AppDrawer(selectedScreen: 'ahumodel'),
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.green,
              onRefresh: () async {
                provider.latestValues;
                await Future.delayed(const Duration(seconds: 7));
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === CONTROL BAR (Top Row) ===
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.015,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: width * 0.025,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 12,
                        children: [
                          // Unit button
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const UnitDialogbox(),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green.shade300,
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.03,
                                vertical: height * 0.015,
                              ),
                            ),
                            icon: Icon(Icons.ad_units, size: labelFont),
                            label: Text(
                              "Unit Operation",
                              style: TextStyle(fontSize: buttonFont),
                            ),
                          ),

                          if (_isLoading)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  color: AppColors.green,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'OFF',
                                style: TextStyle(
                                  fontSize: statusFont,
                                  fontWeight: FontWeight.bold,
                                  color: statusValue == 1
                                      ? Colors.grey[600]
                                      : Colors.red,
                                ),
                              ),
                              SizedBox(width: width * 0.02),
                              Switch(
                                value: statusValue == 1,
                                onChanged: _isLoading
                                    ? null
                                    : (value) async {
                                        final newStatus = value ? 1 : 0;
                                        setState(() => _isLoading = true);
                                        await context
                                            .read<ProviderServices>()
                                            .writeRegisterInstant(0, newStatus);
                                        await Future.delayed(
                                            const Duration(seconds: 5));
                                        setState(() => _isLoading = false);
                                      },
                                activeColor: Colors.green,
                                inactiveTrackColor: Colors.grey[300],
                                inactiveThumbColor: Colors.red,
                              ),
                              SizedBox(width: width * 0.02),
                              Text(
                                'ON',
                                style: TextStyle(
                                  fontSize: statusFont,
                                  fontWeight: FontWeight.bold,
                                  color: statusValue == 1
                                      ? Colors.green
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: width * 0.02),
                          Text(
                            currentTime,
                            style: TextStyle(
                              fontSize: timeFont,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // === AHU IMAGE CONTAINER ===
                    Container(
                      width: double.infinity,
                      height: isTablet
                          ? height * 0.7
                          : height * 0.6, // adjust height by device type
                      margin: EdgeInsets.symmetric(vertical: height * 0.015),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          // Dynamic background
                          Center(
                            child: Image.asset(
                              statusValue == 1
                                  ? "images/gif.gif"
                                  : "images/ahuimage.png",
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),

                          // === PARAMETER OVERLAYS ===
                          ...provider.parameters.map((param) {
                            final dynamic scaleFactor = isTablet ? 1.5 : 1.0;
                            return Positioned(
                              left: param.dx * scaleFactor,
                              top: param.dy * scaleFactor,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.03,
                                  vertical: height * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${param.text}: ${param.value.isEmpty ? '--' : provider.getFormattedValue(param.text, int.tryParse(param.value) ?? 0)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: labelFont,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.04),
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
