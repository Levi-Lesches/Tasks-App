import "package:flutter/material.dart";
import "package:tasks/data.dart";

class TaskTile extends StatelessWidget {
  final Task task;
  TaskTile(this.task) : super(key: ValueKey(task));

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(task.title),
    subtitle: task.description == null ? null : Text(task.description!),
    leading: IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () { }
    ),
  );
}
