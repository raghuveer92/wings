import 'dart:async';

import 'package:wings/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {

  static SharedPreferences _preferencesInstance;
  static Future<bool> init() async {
    _preferencesInstance = await SharedPreferences.getInstance();
    return true;
  }

  static void dispose() {
    _preferencesInstance = null;
  }

  static saveString(String key, String value) {
    _preferencesInstance.setString(key, value);
  }

  static saveInt(String key, int value) {
    _preferencesInstance.setInt(key, value);
  }

  static saveBool(String key, bool value) {
    _preferencesInstance.setBool(key, value);
  }

  static saveDouble(String key, double value) {
    _preferencesInstance.setDouble(key, value);
  }

  static saveStringList(String key, List<String> value) {
    _preferencesInstance.setStringList(key, value);
  }

  static String getString(String key, [String defaultValue]) {
    return _preferencesInstance.getString(key) ?? defaultValue ;
  }

  static bool getBool(String key, [bool defValue]) {
    return _preferencesInstance.getBool(key) ?? defValue ?? false;
  }

  static int getInt(String key, [int defValue]) {
    return _preferencesInstance.getInt(key) ?? defValue ?? 0;
  }

  static int getDouble(String key, [int defValue]) {
    return _preferencesInstance.getDouble(key) ?? defValue ?? 0.0;
  }

  static clear() async {
    _preferencesInstance?.clear();
  }

  static remove(String key) async {
    return _preferencesInstance?.remove(key);
  }
}
