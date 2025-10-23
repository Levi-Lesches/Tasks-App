import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/services.dart";

import "package:tasks/view_models.dart";
import "package:tasks/widgets.dart";
import "package:url_launcher/url_launcher.dart";

/// The home page.
class HomePage extends ReactiveWidget<HomeModel> {
  @override
  HomeModel createModel() => HomeModel();

  Widget header(BuildContext context, String text) =>
    Text(text, style: context.textTheme.headlineSmall, textAlign: TextAlign.center);

  @override
  Widget build(BuildContext context, HomeModel model) => Scaffold(
    appBar: AppBar(
      title: const Text("Tasks"),
      actions: [
        IconButton(
          icon: const Icon(Icons.save),
          tooltip: "Backup",
          onPressed: () async {
            final dir = await services.database.saveBackup();
            final snackBar = SnackBar(
              content: const Text("Backup saved"),
              action: SnackBarAction(
                label: "Open",
                onPressed: () => launchUrl(dir.uri),
              ),
            );
            scaffoldKey.currentState?.showSnackBar(snackBar);
          },
        ),
        IconButton(
          icon: const Icon(Icons.open_in_new),
          tooltip: "Open data folder",
          onPressed: services.openFolder,
        ),
        IconButton(
          icon: const Icon(Icons.clear_all),
          tooltip: "Clear finished tasks",
          onPressed: models.tasks.clearFinishedTasks,
        ),
        MenuAnchor(
          builder: (context, controller, child) => IconButton(
            icon: const Icon(Icons.sort),
            onPressed: controller.open,
            tooltip: "Sort by",
          ),
          menuChildren: [
            MenuItemButton(
              onPressed: () => models.tasks.sortMode = SortMode.statusPriority,
              child: const Text("Status"),
            ),
            MenuItemButton(
              onPressed: () => models.tasks.sortMode = SortMode.priorityStatus,
              child: const Text("Priority"),
            ),
          ],
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (model.todaysTasks.isNotEmpty) ...[
          header(context, "Today's tasks"),
          for (final task in models.tasks.tasksWithPriority(TaskPriority.today)) ...[
            TaskTile(task),
            const Divider(),
          ],
        ],

        const SizedBox(height: 12),

        header(context, "All Lists"),
        for (final category in models.tasks.categories)
          if (category != doneCategory)
            CategoryTile(category: category),

        const Divider(),
        CategoryTile(category: doneCategory),

        if (model.isEditingCategory) CreateTextField(
          onCancel: model.cancelCategory,
          onSubmit: model.onFinishCategory,
          controller: model.categoryController,
          hint: "New Category",
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: model.addCategory,
      child: const Icon(Icons.add),
    ),
  );
}
