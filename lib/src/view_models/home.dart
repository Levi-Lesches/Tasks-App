import "package:tasks/data.dart";
import "package:tasks/models.dart";

import "view_model.dart";

/// The view model for the home page.
class HomeModel extends ViewModel {
  List<Category> get categories => models.tasks.categories;
  Map<TaskPriority, Iterable<Task>> get tasksByPriority => {
    for (final priority in TaskPriority.values)
      priority: models.tasks.tasks.where((task) => task.priority == priority),
  };

  @override
  Future<void> init() async {

  }
}
