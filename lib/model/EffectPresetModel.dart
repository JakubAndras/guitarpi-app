class EffectPresetModel {
  String name;
  List<PresetModel> presets = List.empty();
  bool isExpanded = false;

  EffectPresetModel(this.name, this.presets);

  Map toJson() => {
        'name': name,
        'presets': presets,
      };

  factory EffectPresetModel.fromJson(dynamic json) {
    var jsonPresets = json['presets'] as List;
    List<PresetModel> presets =
    jsonPresets.map((e) => PresetModel.fromJson(e)).toList();
    return EffectPresetModel(json['name'] as String, presets);
  }
}

class PresetModel {
  String name;
  List<ParameterModel> parameters;

  PresetModel(this.name, this.parameters);

  Map toJson() => {
        'name': name,
        'parameters': parameters,
      };

  factory PresetModel.fromJson(dynamic json) {
    var jsonParameters = json['parameters'] as List;
    List<ParameterModel> parameters =
        jsonParameters.map((e) => ParameterModel.fromJson(e)).toList();
    return PresetModel(json['name'] as String, parameters);
  }
}

class ParameterModel {
  String name;
  int value;

  ParameterModel(this.name, this.value);

  Map toJson() => {
        'name': name,
        'value': value,
      };

  factory ParameterModel.fromJson(dynamic json) {
    return ParameterModel(json['name'] as String, json['value'] as int);
  }
}
