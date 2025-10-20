import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";

import "package:tasks/view_models.dart";
import "package:tasks/widgets.dart";

/// The home page.
class HomePage extends ReactiveWidget<HomeModel> {
  @override
  HomeModel createModel() => HomeModel();

  Widget header(BuildContext context, String text) =>
    Text(text, style: context.textTheme.headlineSmall, textAlign: TextAlign.center);

  @override
  Widget build(BuildContext context, HomeModel model) => Scaffold(
    appBar: AppBar(title: const Text("Tasks")),
    body: ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (model.todaysTasks.isNotEmpty) ...[
          header(context, "Today's tasks"),
          for (final task in models.tasks.tasksWithPriority(TaskPriority.today))
            TaskTile(task),
        ],

        header(context, "All categories"),
        for (final category in models.tasks.categories)
          CategoryTile(category),

        if (model.isEditingCategory)
          TextField(
            controller: model.categoryController,
            autofocus: true,
            onSubmitted: model.onFinishCategory,
          ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: model.addCategory,
      child: const Icon(Icons.add),
    ),
  );
}
