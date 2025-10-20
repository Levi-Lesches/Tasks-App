import "dart:convert";
import "dart:io";

import "package:path_provider/path_provider.dart";

import "service.dart";
import "package:tasks/data.dart";

typedef FromJson<T> = T Function(Json);

class DatabaseService extends Service {
  late final Directory dir;
  File get tasksFile => File(dir / "tasks.json");
  File get categoriesFile => File(dir / "categories.json");

  @override
  Future<void> init() async {
    dir = await getApplicationDocumentsDirectory();
    await tasksFile.create();
    await categoriesFile.create();
  }

  Future<List<T>> _readJsonList<T>(File file, FromJson<T> fromJson) async {
    final contents = await file.readAsString();
    if (contents.isEmpty) return [];
    final jsonList = (jsonDecode(contents) as List).cast<Json>();
    return jsonList.map(fromJson).toList();
  }

  Future<void> _writeJsonList<T extends JsonSerializable>(File file, List<T> elements) async {
    final jsonList = [
      for (final element in elements)
        element.toJson(),
    ];
    final json = jsonEncode(jsonList);
    await file.writeAsString(json);
  }

  Future<List<Category>> readCategories() =>
    _readJsonList(categoriesFile, Category.fromJson);

  Future<void> writeCategories(List<Category> categories) =>
    _writeJsonList(categoriesFile, categories);

  Future<List<Task>> readTasks() =>
    _readJsonList(tasksFile, Task.fromJson);

  Future<void> writeTasks(List<Task> tasks) =>
    _writeJsonList(tasksFile, tasks);
}
