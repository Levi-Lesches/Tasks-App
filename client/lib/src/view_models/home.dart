import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/widgets.dart";

import "view_model.dart";

/// The view model for the home page.
class HomeModel extends ViewModel {
  late final categoryEditor = TextEditor(models.tasks.createCategory);
  late final taskEditor = TextEditor(createTask);
  late final titleEditor = TextEditor(updateTitle);
  late final descriptionEditor = TextEditor(updateDescription);

  List<Category> get categories => models.tasks.categories;
  int categoryIndex = 0;
  Category get category => categories[categoryIndex];

  @override
  Future<void> init() async {
    models.tasks.addListener(onUpdate);
    categoryEditor.addListener(notifyListeners);
    taskEditor.addListener(notifyListeners);
    titleEditor.addListener(notifyListeners);
    descriptionEditor.addListener(notifyListeners);
    onUpdate();
  }

  void onUpdate() {
    tasks = models.tasks.getTasksForCategory(category).toList();
    finishedTasks = models.tasks.getTasksForCategory(category, done: true).toList();
    notifyListeners();
  }

  List<Task> tasks = [];
  List<Task> finishedTasks = [];
  void selectCategory(int newIndex) {
    categoryIndex = newIndex;
    onUpdate();
  }

  void updateDescription(String value) {
    category.description = value.nullIfEmpty;
    models.tasks.saveCategories();
  }

  void updateTitle(String value) {
    if (value.trim().isEmpty) return;
    category.title = value;
    models.tasks.saveCategories();
  }

  void createTask(String title) {
    models.tasks.createTask(category, title);
  }

  Future<void> deleteCategory() async {
    if (models.tasks.categories.length == 1) {
      return showSnackBar("Cannot delete the last category");
    }
    await models.tasks.deleteCategory(category);
    categoryIndex = 0;
    onUpdate();
    notifyListeners();
  }
}
