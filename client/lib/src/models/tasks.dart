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
    try {
      categories.merge(await services.client.readCategories());
      categories.removeWhere((c) => c.id == doneCategory.id);
      tasks.merge(await services.client.readTasks());
      await saveCategories();
      await saveTasks();
      _sortTasks();
      lastUpdated = DateTime.now();
      showSnackBar("Sync complete");
    } on ClientException {
      return;  // server is not available, wait for later
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
    showSnackBar("Deleted $task", SnackBarAction(label: "Undo", onPressed: () => addTask(task)));
  }

  void _showCategoryUndoPrompt(Category category, List<Task> tasks) {
    final message = "Deleted $category (${tasks.length} tasks)";
    final action = SnackBarAction(label: "Undo", onPressed: () async {
      await addCategory(category);
      for (final task in tasks) {
        await addTask(task);
      }
    },);
    showSnackBar(message, action);
  }

  Iterable<Task> getTasksForCategory(Category category, {bool done = false}) =>
    tasks
      .where((task) => task.categoryID == category.id)
      .where((task) => (task.status == TaskStatus.done) == done);

  Iterable<Task> tasksWithPriority(TaskPriority priority) =>
    tasks.where((task) => task.priority == priority);

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
    tasks.remove(task);
    await saveTasks();
    _showTaskUndoPrompt(task);
  }

  Future<void> addTask(Task task) async {
    tasks.add(task);
    await saveTasks();
  }

  Category? getCategory(CategoryID? id) =>
    categories.firstWhereOrNull((category) => category.id == id);

  Task? byID(TaskID taskID) => tasks.firstWhereOrNull((task) => task.id == taskID);

  Future<void> deleteCategory(Category category) async {
    final queue = [...getTasksForCategory(category)];
    for (final task in queue) {
      tasks.remove(task);
    }
    categories.remove(category);
    await saveTasks();
    await saveCategories();
    _showCategoryUndoPrompt(category, queue);
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
