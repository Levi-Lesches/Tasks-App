import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "package:tasks/models.dart";
import "package:tasks/services.dart";
import "package:tasks/view_models.dart";
import "package:tasks/widgets.dart";

extension on ThemeMode {
  IconData get icon => switch (this) {
    ThemeMode.light => Icons.light_mode,
    ThemeMode.dark => Icons.dark_mode,
    ThemeMode.system => Icons.brightness_auto,
  };
}

/// The home page.
class TaskListPage extends ReactiveWidget<HomeModel> {
  @override
  HomeModel createModel() => HomeModel();

  Widget header(BuildContext context, String text) =>
    Text(text, style: context.textTheme.headlineSmall, textAlign: TextAlign.center);

  @override
  Widget build(BuildContext context, HomeModel model) => ResponsiveSidebar(
    key: model.appBarKey,
    sidebar: Sidebar(
      title: "My Lists",
      items: [
        for (final category in model.categories)
          NavigationDestination(
            label: category.title,
            icon: iconChip(models.tasks.priorityForCategory(category).toChip()),
          ),
        ],
      onSelected: model.selectCategory,
      selectedIndex: model.categoryIndex,
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: model.categoryEditor.isEditing
          ? CreateTextField(
            editor: model.categoryEditor,
            hint: "New List",
          )
          : OutlinedButton.icon(
            label: const Text("Add List"),
            icon: const Icon(Icons.add),
            onPressed: () => model.categoryEditor.startEditing(""),
          ),
      ),
    ),
    appBar: (leading) => AppBar(
      leading: leading,
      key: model.appBarKey,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Text("Tasks"),
          const SizedBox(width: 12),
          if (models.tasks.version == 0)
            Text("(Not synced)", style: context.textTheme.labelMedium)
          else
            Text("(v${models.tasks.version})", style: context.textTheme.labelMedium),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.sync),
          tooltip: "Sync",
          onPressed: models.tasks.sync,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: "Delete list",
          onPressed: model.deleteCategory,
        ),
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
          icon: Icon(models.settings.themeMode.icon),
          tooltip: "Switch theme",
          onPressed: models.settings.changeTheme,
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
    body: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              ToggleTextField(
                editor: model.titleEditor,
                hint: "Enter a title",
                getValue: () => model.category.title,
                style: context.textTheme.displaySmall,
              ),

              const SizedBox(height: 8),

              ToggleTextField(
                editor: model.descriptionEditor,
                hint: "Enter a description",
                getValue: () => model.category.description,
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w300),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: Text("Title", style: context.titleStyle),
                    ),
                  ),
                  SizedBox(
                    width: TaskTile.statusWidth(context),
                    child: Text(
                      "Status",
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: TaskTile.priorityWidth(context),
                    child: Text(
                      "Priority",
                      textAlign: TextAlign.center,
                      style: context.titleStyle,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: CreateTextField(
                  editor: model.taskEditor,
                  hint: "Add a task...",
                  rounded: true,
                ),
              ),
              const Divider(),

              for (final task in model.tasks) ...[
                TaskTile(task),
                const Divider(),
              ],
            ],
          ),
        ),
        const Divider(),
        ExpansionTile(
          enabled: model.finishedTasks.isNotEmpty,
          title: Text("Finished tasks (${model.finishedTasks.length})"),
          children: [
            for (final task in model.finishedTasks)
              TaskTile(task),
            const SizedBox(height: 12),
          ],
        ),
      ],
    ),
  );
}
