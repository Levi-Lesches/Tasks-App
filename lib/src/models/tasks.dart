import "package:flutter/material.dart";
import "package:tasks/data.dart";
import "package:tasks/services.dart";
import "package:tasks/widgets.dart";

import "model.dart";

class TasksModel extends DataModel {
  List<Task> tasks = [];
  List<Category> categories = [];

  @override
  Future<void> init() async {
    categories = await services.database.readCategories();
    tasks = await services.database.readTasks();
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
}
