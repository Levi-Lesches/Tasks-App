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
}
