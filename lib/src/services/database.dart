import "dart:convert";
import "dart:io";

import "service.dart";
import "package:tasks/data.dart";

typedef FromJson<T> = T Function(Json);

abstract class BaseDatabase extends Service {
  Future<List<Category>> readCategories();
  Future<void> writeCategories(List<Category> categories);
  Future<List<Task>> readTasks();
  Future<void> writeTasks(List<Task> tasks);
}

class DatabaseService extends BaseDatabase {
  final Directory dir;
  DatabaseService(this.dir);

  File get tasksFile => File(dir / "tasks.json");
  File get categoriesFile => File(dir / "categories.json");
  File get versionFile => File(dir / "version.json");
  final encoder = const JsonEncoder.withIndent("  ");

  @override
  Future<void> init() async {
    await dir.create(recursive: true);
    await tasksFile.create();
    await categoriesFile.create();
    await versionFile.create();
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
    final json = encoder.convert(jsonList);
    await file.writeAsString(json);
  }

  @override
  Future<List<Category>> readCategories() =>
    _readJsonList(categoriesFile, Category.fromJson);

  @override
  Future<void> writeCategories(List<Category> categories) =>
    _writeJsonList(categoriesFile, categories);

  @override
  Future<List<Task>> readTasks() =>
    _readJsonList(tasksFile, Task.fromJson);

  @override
  Future<void> writeTasks(List<Task> tasks) =>
    _writeJsonList(tasksFile, tasks);

  Future<Directory> saveBackup() async {
    final now = DateTime.now();
    final backupDir = Directory(dir / "backups" / formatTimestamp(now));
    await backupDir.create(recursive: true);
    await categoriesFile.copy(backupDir / "categories.json");
    await tasksFile.copy(backupDir / "tasks.json");
    return backupDir;
  }

  Future<void> saveVersion(int version) =>
    versionFile.writeAsString(version.toString());

  Future<int> getVersion() async {
    final contents = await versionFile.readAsString();
    return contents.isEmpty ? 0 : int.parse(contents);
  }
}
