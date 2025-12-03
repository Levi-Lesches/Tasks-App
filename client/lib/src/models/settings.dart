import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/services.dart";

import "model.dart";

class SettingsModel extends DataModel {
  late final Settings _settings;
  Settings get settings => _settings;

  ThemeMode get themeMode => ThemeMode.values[settings.themeModeIndex];
  set themeMode(ThemeMode mode) => settings.themeModeIndex = mode.index;

  @override
  Future<void> init() async {
    var settings = await services.database.readSettings();
    if (settings == null) {
      settings = Settings();
      await services.database.writeSettings(settings);
    }
    _settings = settings;
  }

  Future<void> save() => services.database.writeSettings(settings);
}
