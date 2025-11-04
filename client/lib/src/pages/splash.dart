import "package:flutter/material.dart";
import "package:tasks/models.dart";
import "package:tasks/pages.dart";
import "package:tasks/services.dart";

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await services.init();
    await models.init();
    await models.initFromOthers();
    router.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Tasks")),
    body: const Center(child: CircularProgressIndicator()),
  );
}
