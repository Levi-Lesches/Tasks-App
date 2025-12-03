import "dart:math";

import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/services.dart";
import "package:tasks/widgets.dart";

enum SortMode {
  statusPriority,
  priorityStatus,
}

class TasksModel extends DataModel {
  List<Task> tasks = [];
  List<Category> allLists = [];
  List<Category> activeLists = [];
  SortMode _sortMode = SortMode.priorityStatus;
  DateTime lastUpdated = DateTime.now();
  SortMode get sortMode => _sortMode;
  int get version => services.client.version;
  set sortMode(SortMode mode) {
    _sortMode = mode;
    _sortTasks();
  }

  @override
  Future<void> init() async {
    models.server.addListener(onServerSync);
    allLists = await services.database.readCategories();
    tasks = await services.database.readTasks();
    _sortTasks();
    sync(quiet: true).ignore();
  }

  void onServerSync() {
    showSnackBar("Received sync from client");
    tasks = models.server.tasks;
    allLists = models.server.lists;
    _sortTasks();
    notifyListeners();
  }

  // Trinket works by first downloading, then uploading
  // Tasks have a modified flag on client, version flag on server
  // The server and client both have version numbers
  // Download: POST w/ client version. Server returns all tasks that have been updated since then + server_version
  // Upload: POST w/ modified events. Server returns server_version++
  Future<void> sync({bool quiet = false}) async {
    try {
      services.client.tasks = tasks;
      services.client.categories = allLists;
      final didChange = await services.client.sync();
      if (didChange) {
        showSnackBar("Synced tasks to server");
        tasks = services.client.tasks;
        allLists = services.client.categories;
        _sortTasks();
        notifyListeners();
      } else {
        if (!quiet) showSnackBar("No changes to sync");
      }
    } on SyncException catch (error) {
      if (!quiet) showSnackBar("Could not sync: $error");
    }
  }

  num _generateSortKey(Task task) => switch (_sortMode) {
    SortMode.priorityStatus => task.priority.index * TaskStatus.values.length + task.status.index,
    SortMode.statusPriority => task.status.index * TaskPriority.values.length + task.priority.index,
  };

  void _sortTasks() {
    activeLists = models.settings.settings.listOrder
      .map((listID) => allLists.byID(listID))
      .nonNulls
      .notDeleted
      .toList();
    for (final list in allLists.notDeleted) {
      if (activeLists.byID(list.id) != null) continue;
      // This non-deleted list is not in the sort order
      activeLists.add(list);
      models.settings.settings.listOrder.add(list.id);
    }
    models.settings.save();
    tasks = tasks.sortedBy(_generateSortKey);
    notifyListeners();
  }

  void reorderList(int oldIndex, int newIndex) {
    final item = activeLists.removeAt(oldIndex);
    activeLists.insert(newIndex, item);
    models.settings.settings.listOrder = [
      for (final list in activeLists)
        list.id,
    ];
    models.settings.save();
    _sortTasks();
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
    await services.database.writeCategories(allLists);
    _sortTasks();
  }

  Future<Category> createCategory(String title) async {
    final category = Category(title: title);
    allLists.add(category);
    activeLists.add(category);
    await saveCategories();
    return category;
  }

  TaskPriority priorityForCategory(Category category) {
    final tasks = getTasksForCategory(category);
    if (tasks.isEmpty) return TaskPriority.normal;
    final index = tasks
      .map((task) => task.priority.index)
      .reduce(min);
    return TaskPriority.values[index];
  }

  Future<void> moveTask(Task task, Category list) async {
    task.categoryID = list.id;
    task.modified();
    await saveTasks();
  }

  Future<bool> harden() async {
    // Save all modified tasks and categories and increment version
    var didChange = false;
    final newVersion = services.client.version + 1;
    final toUpdate = <Syncable>[...allLists, ...tasks].modified;
    for (final item in toUpdate) {
      item.version = newVersion;
      didChange = true;
    }
    if (didChange) {
      await services.database.writeTasks(tasks);
      await services.database.writeCategories(allLists);
      await services.database.saveVersion(newVersion);
      services.client.version = newVersion;
    }
    return didChange;
  }
}
