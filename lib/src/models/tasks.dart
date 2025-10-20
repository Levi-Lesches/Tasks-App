import "package:tasks/data.dart";
import "package:tasks/services.dart";

import "model.dart";

class TasksModel extends DataModel {
  List<Task> tasks = [];
  List<Category> categories = [];

  @override
  Future<void> init() async {
    categories = await services.database.readCategories();
    tasks = await services.database.readTasks();
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
}
