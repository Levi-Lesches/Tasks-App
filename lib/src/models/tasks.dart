import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/services.dart";
import "package:tasks/widgets.dart";

import "model.dart";

enum SortMode {
  statusPriority,
  priorityStatus,
}

class TasksModel extends DataModel {
  List<Task> tasks = [];
  List<Category> categories = [];
  SortMode _sortMode = SortMode.priorityStatus;
  SortMode get sortMode => _sortMode;
  set sortMode(SortMode mode) {
    _sortMode = mode;
    _sortTasks();
  }

  @override
  Future<void> init() async {
    categories = await services.database.readCategories();
    tasks = await services.database.readTasks();
    _sortTasks();
    if (!categories.contains(doneCategory)) {
      categories.add(doneCategory);
      await services.database.writeCategories(categories);
    }
  }

  num _generateSortKey(Task task) => switch (_sortMode) {
    SortMode.priorityStatus => task.priority.index * TaskStatus.values.length + task.status.index,
    SortMode.statusPriority => task.status.index * TaskPriority.values.length + task.priority.index,
  };

  void _sortTasks() {
    tasks = tasks.sortedBy(_generateSortKey);
    notifyListeners();
  }

  void _showTaskUndoPrompt(Task task) {
    final snackBar = SnackBar(
      content: Text("Deleted $task"),
      action: SnackBarAction(label: "Undo", onPressed: () => addTask(task)),
    );
    scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  Iterable<Task> getTasksForCategory(Category category) =>
    tasks.where((task) => task.categoryID == category.id);

  Iterable<Task> tasksWithPriority(TaskPriority priority) =>
    tasks.where((task) => task.priority == priority);

  Future<Category> createCategory(String title) async {
    final category = Category(title: title);
    categories.add(category);
    await services.database.writeCategories(categories);
    return category;
  }

  Future<void> createTask(Category category, String title) =>
    addTask(Task(title: title, categoryID: category.id));

  Future<void> saveTasks() async {
    await services.database.writeTasks(tasks);
    _sortTasks();
    notifyListeners();
  }

  Future<void> deleteTask(Task task) async {
    tasks.remove(task);
    await saveTasks();
    _showTaskUndoPrompt(task);
  }

  Future<void> addTask(Task task) async {
    tasks.add(task);
    await saveTasks();
  }

  Future<void> clearFinishedTasks() async {
    for (final task in tasks) {
      if (task.status != TaskStatus.done) continue;
      task.originalCategoryID = task.categoryID;
      task.categoryID = doneCategory.id;
    }
    await saveTasks();
  }

  Future<void> restoreTask(Task task) async {
    task.categoryID = task.originalCategoryID!;
    task.originalCategoryID = null;
    await saveTasks();
  }

  Category? getCategory(CategoryID? id) =>
    categories.firstWhereOrNull((category) => category.id == id);

  Task? byID(TaskID taskID) => tasks.firstWhereOrNull((task) => task.id == taskID);
}
