import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/services.dart";

import "model.dart";

class SettingsModel extends DataModel {
  late final Settings _settings;
  Settings get settings => _settings;

  ThemeMode get themeMode => ThemeMode.values[settings.themeModeIndex];
  set themeMode(ThemeMode mode) => settings.themeModeIndex = mode.index;

  Future<void> changeTheme() async {
    themeMode = switch(themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    await save();
  }

  bool isReady = false;

  @override
  Future<void> init() async {
    var settings = await services.database.readSettings();
    if (settings == null) {
      settings = Settings();
      await services.database.writeSettings(settings);
    }
    _settings = settings;
    isReady = true;
    notifyListeners();
  }

  Future<void> save() async {
    await services.database.writeSettings(settings);
    notifyListeners();
  }
}
