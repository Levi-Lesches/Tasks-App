import "dart:io";

import "package:shared/shared.dart";

void main() async {
  final dir = Platform.isLinux ? "./data" : r"C:\Users\Levi\Documents\Tasks App";
  final dir2 = Directory(dir);
  final database = DatabaseService(dir2);
  final version = await database.getVersion();
  final tasks = await database.readTasks();
  final categories = await database.readCategories();
  for (final task in [...tasks, ...categories]) {
    if (task.version == -1) {
      task.version = version;
      task.isDeleted = true;
    }
  }
  await database.writeCategories(categories);
  await database.writeTasks(tasks);

}