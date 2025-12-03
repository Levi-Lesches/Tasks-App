import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:tasks/pages.dart";
import "package:tasks/widgets.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  runApp(const TasksApp());
}

/// The main app widget.
class TasksApp extends StatelessWidget {
  ThemeData getTheme(BuildContext context, ColorScheme colorScheme) => ThemeData(
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
      labelTextStyle: WidgetStatePropertyAll(
        context.textTheme.bodyMedium
          ?.copyWith(color: colorScheme.onSurface),
      ),
      indicatorColor: Colors.blueGrey.withAlpha(75),
    ),
    colorScheme: colorScheme,
  );

  /// A const constructor.
  const TasksApp();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: themeMode,
    builder: (context, value, child) => MaterialApp.router(
      title: "Flutter Demo",
      scaffoldMessengerKey: scaffoldKey,
      theme: getTheme(context, const ColorScheme.light()),
      darkTheme: getTheme(context, const ColorScheme.dark()),
      routerConfig: router,
      themeMode: value,
      debugShowCheckedModeBanner: false,
    ),
  );
}
