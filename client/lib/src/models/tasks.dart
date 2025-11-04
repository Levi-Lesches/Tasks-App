import "dart:math";

import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:http/http.dart";
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
  DateTime lastUpdated = DateTime.now();
  SortMode get sortMode => _sortMode;
  set sortMode(SortMode mode) {
    _sortMode = mode;
    _sortTasks();
  }

  @override
  Future<void> init() async {
    categories = await services.database.readCategories();
    categories.removeWhere((c) => c.id == doneCategory.id);
    tasks = await services.database.readTasks();
    await sync();
  }

  // Trinket works by first downloading, then uploading
  // Tasks have a modified flag on client, version flag on server
  // The server and client both have version numbers
  // Download: POST w/ client version. Server returns all tasks that have been updated since then + server_version
  // Upload: POST w/ modified events. Server returns server_version++
  Future<void> sync() async {
    if (!services.client.isReady) {
      await services.client.init();
      if (!services.client.isReady) {
        return showSnackBar("No servers found");
      }
    }
    try {
      var didChange = false;
      didChange |= categories.merge(await services.client.readCategories());
      categories.removeWhere((c) => c.id == doneCategory.id);
      didChange |= tasks.merge(await services.client.readTasks());
      await saveCategories();
      await saveTasks();
      _sortTasks();

      await services.client.writeTasks(tasks);
      await services.client.writeCategories(categories);

      lastUpdated = DateTime.now();
      if (didChange) {
        showSnackBar("Tasks synced to ${services.client.serverType?.name}");
      } else {
        showSnackBar("No changes");
      }
    } on ClientException {
      showSnackBar("Could not reach server");
      services.client.onLostConnection();
      return;  // server is not available, wait for later
    } on Exception catch (error) {
      showSnackBar("Error with sync: $error");
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
    showSnackBar("Deleted $task", SnackBarAction(label: "Undo", onPressed: () => task.modified()));
  }

  void _showCategoryUndoPrompt(Category category, List<Task> tasks) {
    final message = "Deleted $category (${tasks.length} tasks)";
    final action = SnackBarAction(
      label: "Undo",
      onPressed: () async {
        category.modified();
        for (final task in tasks) {
          task.modified();
        }
      },
    );
    showSnackBar(message, action);
  }

  Iterable<Task> getTasksForCategory(Category category, {bool done = false}) => tasks
    .where((task) => task.categoryID == category.id)
    .where((task) => (task.status == TaskStatus.done) == done)
    .where((task) => !task.isDeleted);

  Iterable<Task> tasksWithPriority(TaskPriority priority) => tasks
    .where((task) => task.priority == priority)
    .where((task) => !task.isDeleted);

  Future<Category> createCategory(String title) async {
    final category = Category(title: title);
    categories.add(category);
    await saveCategories();
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
    task.deleted();
    await saveTasks();
    _showTaskUndoPrompt(task);
  }

  Future<void> addTask(Task task) async {
    task.modified();
    tasks.add(task);
    await saveTasks();
  }

  Task? byID(TaskID taskID) => tasks.firstWhereOrNull((task) => task.id == taskID);

  Future<void> deleteCategory(Category category) async {
    final categoryTasks = getTasksForCategory(category).toList();
    for (final task in categoryTasks) {
      task.deleted();
    }
    category.deleted();
    await saveTasks();
    await saveCategories();
    _showCategoryUndoPrompt(category, categoryTasks);
  }

  Future<void> saveCategories() async {
    await services.database.writeCategories(categories);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    categories.add(category);
    await saveCategories();
  }

  TaskPriority priorityForCategory(Category category) {
    final tasks = getTasksForCategory(category);
    if (tasks.isEmpty) return TaskPriority.normal;
    final index = tasks
      .map((task) => task.priority.index)
      .reduce(min);
    return TaskPriority.values[index];
  }
}
