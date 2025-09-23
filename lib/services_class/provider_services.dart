import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zedbeemodbus/fields/shared_pref_helper.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';
import 'package:zedbeemodbus/services_class/modbus_services.dart';

class ProviderServices extends ChangeNotifier {
  ModbusServices? _modbusServices;
  final List<ParameterModel> _parameters = [];
  List<int> _latestValues = [];
  List<int> _checkedIndexes = [];
  Timer? _autoRefreshTimer;
  bool _isWriting = false;
  bool _isSwitchLoading = false;
  String _currentIp = "127.0.0.1";

  bool get isSwitchLoading => _isSwitchLoading;
  List<ParameterModel> get parameters => _parameters;
  List<int> get latestValues => _latestValues;
  List<int> get checkedIndexes => _checkedIndexes;
  String get currentIp => _currentIp;

  // load saved ip form shared prefs
  Future<void> init() async {
    String? saveIp = await SharedPrefHelper.getIp();
    _currentIp = saveIp ?? "127.0.0.1";
    _modbusServices = ModbusServices(ip: _currentIp);

  }

  // update IP dyamically
  Future<void> updateIp(String newIp) async {
    _currentIp = newIp;
    await SharedPrefHelper.saveIp(newIp);
    _modbusServices = ModbusServices(ip: currentIp);
    notifyListeners();
  }

  // Load saved parameters + checked index
  Future<void> loadSavedData() async {
    final savedParams = await SharedPrefHelper.getParameters();
    final savedIndexes = await SharedPrefHelper.getCheckedIndexes();
    _parameters
      ..clear()
      ..addAll(savedParams);
    _checkedIndexes = savedIndexes;
    notifyListeners();
  }

  // Save current parameters + checked indexes
  Future<void> saveData() async {
    await SharedPrefHelper.saveParameters(_parameters);
    await SharedPrefHelper.saveCheckedIndexes(_checkedIndexes);
  }

  // parameter name with there units .....

  final List<Map<String, String>> allParameters = [
    {"name": "Status", "unit": ""},
    {"name": "Frequency", "unit": "Hz"},
    {"name": "Auto/Manual", "unit": ""},
    {"name": "Flowrate", "unit": "m³/h"},
    {"name": "Water Pressure", "unit": "bar"},
    {"name": "Duct Pressure", "unit": "bar"},
    {"name": "Running Hours 1", "unit": "hr"},
    {"name": "Running Hours 2", "unit": "hr"},
    {"name": "BTU 1", "unit": "kWh"},
    {"name": "BTU 2", "unit": "kWh"},
    {"name": "Water In", "unit": "°C"},
    {"name": "Water Out", "unit": "°C"},
    {"name": "Supply Temp", "unit": "°C"},
    {"name": "Return Temp", "unit": "°C"},
    {"name": "Stop Condition", "unit": ""},
    {"name": "Fire Status", "unit": ""},
    {"name": "Trip Status", "unit": ""},
    {"name": "Filter Status", "unit": ""},
    {"name": "NONC Status", "unit": ""},
    {"name": "Run Status", "unit": ""},
    {"name": "Auto/Manual Status", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "Water Value", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "Voltage", "unit": "V"},
    {"name": "Current", "unit": "A"},
    {"name": "Power", "unit": "kW"},
    {"name": "Delta T Avg", "unit": "°C"},
    {"name": "Set Temperature", "unit": "°C"},
    {"name": "Min Frequency", "unit": "Hz"},
    {"name": "Max Frequency", "unit": "Hz"},
    {"name": "VAV Number", "unit": ""},
    {"name": "PID Constant", "unit": ""},
    {"name": "Ductset Pressure", "unit": "bar"},
    {"name": "Max FlowRate", "unit": "m³/h"},
    {"name": "Min FlowRate", "unit": "m³/h"},
    {"name": "Pressure Constant", "unit": ""},
    {"name": "Inlet Threshold", "unit": ""},
    {"name": "Actuator Direction", "unit": ""},
    {"name": "Actuator Type", "unit": ""},
    {"name": "Min Act Position", "unit": ""},
    {"name": "Ramp Up Sel", "unit": ""},
    {"name": "Water Delta T", "unit": ""},
    {"name": "Pressure Temp Sel", "unit": "°C"},
    {"name": "N/A", "unit": ""},
    {"name": "Flowmeter Type", "unit": ""},
    {"name": "7 Span", "unit": ""},
    {"name": "6 Span", "unit": ""},
    {"name": "Min Set Temp", "unit": "°C"},
    {"name": "Max Set Temp", "unit": "°C"},
    {"name": "1", "unit": ""},
    {"name": "9600", "unit": ""},
    {"name": "0", "unit": ""},
    {"name": "1", "unit": ""},
    {"name": "Schedule ON/OFF", "unit": ""},
    {"name": "Schedule ON Time", "unit": ""},
    {"name": "Schedule OFF Time", "unit": ""},
    {"name": "Poll Time", "unit": ""},
  ];
  // float Data Types Parameters ........
  final List<String> floatValueNames = [
    "Frequency",
    "Water In",
    "Water Out",
    "Supply Temp",
    "Return Temp",
    "Delta T Avg",
    "Set Temperature",
    "Min Frequency",
    "Max Frequency",
    "Max FlowRate",
    "Min FlowRate",
    "Pressure Constant",
    "Inlet Threshold",
    "Pressure Temp Sel",
    "Min Set Temp",
    "Max Set Temp",
  ];
  // intergers function status ....
  String getFormattedValue(String name, int rawValue) {
    String value;
    if (name == "Status" || name == "Schedule ON/OFF") {
      value = rawValue == 1 ? "ON" : "OFF";
    } else if (name == "Auto/Manual Status") {
      value = rawValue == 0
          ? "OFF"
          : rawValue == 1
          ? "AUTO"
          : rawValue == 2
          ? "MANUAL"
          : "--";
    } else if (name == "Actuator Direction") {
      value = rawValue == 0
          ? "Forward"
          : rawValue == 1
          ? "Reverse"
          : "--";
    } else if (name == "Trip Status") {
      value = rawValue == 0
          ? "Healthy"
          : rawValue == 1
          ? "Tripped"
          : "--";
    } else if (name == "Fire Status") {
      value = rawValue == 0
          ? "No Fire"
          : rawValue == 1
          ? "Fire Event"
          : "--";
    } else if (name == "Filter Status") {
      value = rawValue == 0
          ? "Clean"
          : rawValue == 1
          ? "Dirty"
          : "--";
    } else if (floatValueNames.contains(name)) {
      value = (rawValue / 100).toStringAsFixed(2);
    } else {
      value = rawValue.toString();
    }

    final param = allParameters.firstWhere(
      (p) => p["name"] == name,
      orElse: () => {"unit": ""},
    );
    final unit = param["unit"] ?? "";
    return unit.isNotEmpty ? "$value $unit" : value;
  }

  // add Parameters Functions ........
  void addParameters(List<int> indexes, List<Map<String, String>> allParams) {
    for (var i in indexes) {
      if (!_parameters.any((param) => param.registerIndex == i)) {
        _parameters.add(
          ParameterModel(
            text: allParams[i]["name"]!,
            dx: 50,
            dy: 100 + _parameters.length * 60,
            registerIndex: i,
          ),
        );
      }
    }
    // Parameters by index values .........
    _checkedIndexes.addAll(indexes.where((i) => !_checkedIndexes.contains(i)));
    notifyListeners();
  }

  // Remove Parameters Function ...........
  void removeParameter(int registerIndex) {
    _parameters.removeWhere((param) => param.registerIndex == registerIndex);
    _checkedIndexes.remove(registerIndex);
    notifyListeners();
  }

  // Remove by index ..........
  void removeParameterByIndex(int index) {
    if (index >= 0 && index < _parameters.length) {
      _checkedIndexes.remove(_parameters[index].registerIndex);
      _parameters.removeAt(index);
      notifyListeners();
    }
  }

  // Parameter Positions ............
  void updatePosition(int index, double dx, double dy) {
    if (index >= 0 && index < _parameters.length) {
      final item = _parameters[index];
      _parameters[index] = ParameterModel(
        text: item.text,
        dx: dx,
        dy: dy,
        registerIndex: item.registerIndex,
        value: item.value,
      );
      notifyListeners();
    }
  }

  // Get all the Parmeters by Registers .........
  Future<void> fetchRegisters() async {
    if (_isWriting || _modbusServices == null) return;
    try {
      _latestValues = await _modbusServices!.readRegisters(0, 59);
      for (var param in _parameters) {
        if (param.registerIndex != null &&
            param.registerIndex! < _latestValues.length) {
          param.value = _latestValues[param.registerIndex!].toString();
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching registers: $e");
    }
  }

  // Write Parameters Function ............
  Future<void> writeRegister(int address, int value) async {
    if (_modbusServices == null) return;
    _isWriting = true;
    stopAutoRefresh(); // stop refresh
    try {
      await _modbusServices!.writeRegister(address, value);
      await Future.delayed(const Duration(milliseconds: 100));
      await fetchRegisters();
    } finally {
      _isWriting = false;
      startAutoRefresh(); // start refresh
    }
  }

  // ON/OFF toggle switch button .......
  void setswitchLoading(bool loading) {
    _isSwitchLoading = loading;
    notifyListeners();
  }

  // Write Register with integers ......
  Future<void> writeRegisterInstant(int address, int value) async {
    if (_modbusServices == null) return;
    setswitchLoading(true);
    try {
      await _modbusServices!.writeRegister(address, value);
    } catch (e) {
      debugPrint("Instant write error: $e");
    } finally {
      setswitchLoading(false);
    }
  }

  // Auto referesh function  .....
  void startAutoRefresh() {
    if (_autoRefreshTimer?.isActive ?? false) return;
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => fetchRegisters(),
    );
  }

  // cancel refresh .......
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
  }

  // selected Parameters
  bool isParameterSelected(int registerIndex) {
    return _parameters.any((param) => param.registerIndex == registerIndex);
  }

  // clear all Parameters ....
  void clearParameters() {
    _parameters.clear();
    _checkedIndexes.clear();
    notifyListeners();
  }

  // show the selected parameter in multiple screen .....
  void setParameters(List<ParameterModel> param) {
    _parameters
      ..clear()
      ..addAll(param);
    notifyListeners();
  }
}
