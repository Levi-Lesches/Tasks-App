import "package:flutter/material.dart";

import "package:tasks/models.dart";
import "package:tasks/pages.dart";
import "package:tasks/services.dart";
import "package:tasks/widgets.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    ),
    routerConfig: router,
  );
}
