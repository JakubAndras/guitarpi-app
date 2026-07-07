import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/EffectPresetModel.dart';

class PresetSharedPreferences {
  static late SharedPreferences preferences;

  static Future init() async =>
      preferences = await SharedPreferences.getInstance();

  static String? getAllEffectPresets(String name) {
    return preferences.getString(name);
  }

  static Future setAllEffectPresets(String jsonEffectPresetModel) async {
    EffectPresetModel effectPresetModel =
        EffectPresetModel.fromJson(jsonDecode(jsonEffectPresetModel));

    await preferences.setString(effectPresetModel.name, jsonEffectPresetModel);
  }
}
