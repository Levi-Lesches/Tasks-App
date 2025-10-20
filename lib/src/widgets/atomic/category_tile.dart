import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/widgets.dart";

class CategoryTile extends StatefulWidget {
  final Category category;

  CategoryTile({
    required this.category,
  }) : super(key: ValueKey(category));

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool isEditingTask = false;
  final taskController = TextEditingController();
  final controller = ExpansibleController();
  final taskEditFocus = FocusNode();

  void cancelTask() {
    setState(() => isEditingTask = false);
  }

  Future<void> createTask(String title) async {
    await models.tasks.createTask(widget.category, title);
    taskController.clear();
    taskEditFocus.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    taskController.dispose();
    controller.dispose();
    taskEditFocus.dispose();
  }

  @override
  Widget build(BuildContext context) => ExpansionTile(
    controller: controller,
    title: ListTile(
      title: Text(widget.category.title),
      contentPadding: EdgeInsets.zero,
      subtitle: widget.category.description.ifNotNull(Text.new),
      // trailing: widget.category == doneCategory ? null :
    ),
    leading: IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () { },
    ),
    children: [
      Row(
        children: [
          Expanded(child: Text("Name", textAlign: TextAlign.center, style: context.textTheme.labelLarge)),
          SizedBox(width: 130, child: Text("Due Date", textAlign: TextAlign.center, style: context.textTheme.labelLarge)),
          SizedBox(
            width: 150,
            child: Text(
              widget.category == doneCategory ? "Original List"
                : models.tasks.sortMode == SortMode.statusPriority ? "↑ Status" : "Status",
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge,
            ),
          ),
          SizedBox(
            width: 112,
            child: Text(
              models.tasks.sortMode == SortMode.priorityStatus ? "↑ Priority" : "Priority",
              textAlign: TextAlign.center,
              style: context.textTheme.labelLarge,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),

      for (final task in models.tasks.getTasksForCategory(widget.category)) ...[
        TaskTile(task),
      ],

      ListTile(
        title: CreateTextField(
          focusNode: taskEditFocus,
          onCancel: cancelTask,
          onSubmit: createTask,
          controller: taskController,
          hint: "New Task",
        ),
      ),
    ],
  );
}
