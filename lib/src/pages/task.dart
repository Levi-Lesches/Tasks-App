import "package:flutter/material.dart";
import "package:tasks/data.dart";

class TaskPage extends StatelessWidget {
  final Task task;
  const TaskPage(this.task);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Edit Task")),
    body: const Placeholder(),
  );
}
