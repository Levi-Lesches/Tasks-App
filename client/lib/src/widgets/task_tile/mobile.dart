import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/pages.dart";
import "package:tasks/src/widgets/task_tile/utils.dart";
import "package:tasks/widgets.dart";

class TaskTileMobile extends StatelessWidget {
  final Task task;
  const TaskTileMobile(this.task);

  @override
  Widget build(BuildContext context) => ListTile(
    title: oneLine(task.title),
    subtitle: task.description?.ifNotNull(oneLine),
    visualDensity: const VisualDensity(vertical: -2),
    shape: BoxBorder.symmetric(
      horizontal: BorderSide(color: Colors.black.withAlpha(50)),
    ),
    leading: mobileChip(task.priority.toChip()),
    trailing: IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => router.openTaskPage(task),
    ),
  );
}
