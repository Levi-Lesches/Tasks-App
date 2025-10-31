import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/widgets.dart";

import "mobile.dart";
import "desktop.dart";

class TaskTile extends StatelessWidget {
  final Task task;
  TaskTile(this.task) : super(key: ValueKey(task));

  @override
  Widget build(BuildContext context) =>
    context.isMobile ? TaskTileMobile(task) : TaskTileDesktop(task);
}
