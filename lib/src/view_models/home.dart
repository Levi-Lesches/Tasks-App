import "package:flutter/widgets.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";

import "view_model.dart";

/// The view model for the home page.
class HomeModel extends ViewModel {
  List<Category> get categories => models.tasks.categories;
  List<Task> get tasks => models.tasks.tasks;

  final categoryController = TextEditingController();

  bool isEditingCategory = false;

  Iterable<Task> get todaysTasks => models.tasks.tasksWithPriority(TaskPriority.today);

  @override
  Future<void> init() async {
    models.tasks.addListener(notifyListeners);
  }

  void addCategory() {
    isEditingCategory = true;
    categoryController.clear();
    notifyListeners();
  }

  void onFinishCategory(String value) {
    isEditingCategory = false;
    models.tasks.createCategory(value);
    notifyListeners();
  }

  void cancelCategory() {
    isEditingCategory = false;
    notifyListeners();
  }
}
