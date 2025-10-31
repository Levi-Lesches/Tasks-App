import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:tasks/models.dart";
import "package:tasks/pages.dart";
import "package:tasks/services.dart";
import "package:tasks/widgets.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  await services.init();
  await models.init();
  await models.initFromOthers();
  runApp(const TasksApp());
}

/// The main app widget.
class TasksApp extends StatelessWidget {
  /// A const constructor.
  const TasksApp();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: "Flutter Demo",
    scaffoldMessengerKey: scaffoldKey,
    theme: ThemeData(
      useMaterial3: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -2),  // Desktop
      navigationRailTheme: NavigationRailThemeData(
        elevation: 8,
        indicatorColor: Colors.blueGrey.withAlpha(75),
        minWidth: 48,
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        elevation: 8,
        tileHeight: 48,
        labelTextStyle: WidgetStatePropertyAll(context.textTheme.bodyMedium),
        indicatorColor: Colors.blueGrey.withAlpha(75),
      ),
    ),
    routerConfig: router,
    debugShowCheckedModeBanner: false,
  );
}
