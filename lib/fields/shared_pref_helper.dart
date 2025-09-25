import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';

class SharedPrefHelper {
  static const _paramKey = "draggable_parameters";
  static const _checkedIndexesKey = "checked_parameter_indexes";
  static const String _ipHistorykey = "ip_history";
  static const int _maxHistory = 5;
  static const String _lastIpKey = "last_device_ip";

  // To save the parameters
  static Future<void> saveParameters(List<ParameterModel> params) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(params.map((p) => p.toJson()).toList());
    prefs.setString(_paramKey, jsonString);
  }

  // To get the parameters
  static Future<List<ParameterModel>> getParameters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_paramKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => ParameterModel.fromJson(e)).toList();
  }

  // save selected chekbox indexes
  static Future<void> saveCheckedIndexes(List<int> indexes) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = indexes.map((e) => e.toString()).toList();
    await prefs.setStringList(_checkedIndexesKey, stringList);
  }

  // Load selected checkbox indexes
  static Future<List<int>> getCheckedIndexes() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(_checkedIndexesKey);
    if (stringList == null) return [];
    return stringList.map(int.parse).toList();
  }

  // save IP address
  static Future<void> saveIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastIpKey, ip);
  }

  // Get IP address
  static Future<String?> getIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastIpKey);
  }

  // save ip with history and Limit
  static Future<void> saveIpHistory(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_ipHistorykey) ?? [];
    history.remove(ip);
    history.insert(0, ip);

    if (history.length > _maxHistory) {
      history = history.sublist(0, _maxHistory);
    }
    await prefs.setStringList(_ipHistorykey, history);
  }

  // Get all IP history
  static Future<List<String>> getIpHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_ipHistorykey) ?? [];
  }

  // clear all History
  static Future<void> clearIpHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ipHistorykey);
  }
}
