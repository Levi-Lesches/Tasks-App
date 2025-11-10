import "dart:convert";
import "dart:io";

import "package:shared/data.dart";
import "service.dart";

class SyncService extends Service {
  int version = 0;
  List<Task> tasks = [];
  List<Category> categories = [];
  final DatabaseService database;
  SyncService({required this.database});

  @override
  Future<void> init() async {
    version = await database.getVersion();
    tasks = await database.readTasks();
    categories = await database.readCategories();
  }
}

class DatabaseService extends Service {
  static const _encoder = JsonEncoder.withIndent("  ");

  final Directory dir;
  DatabaseService(this.dir);

  File get _tasksFile => File(dir / "tasks.json");
  File get _categoriesFile => File(dir / "categories.json");
  File get _versionFile => File(dir / "version.json");

  @override
  Future<void> init() async {
    await dir.create(recursive: true);
    await _tasksFile.create();
    await _categoriesFile.create();
    await _versionFile.create();
  }

  Future<List<T>> _readJsonList<T>(File file, FromJson<T> fromJson) async {
    final contents = await file.readAsString();
    if (contents.isEmpty) return [];
    final jsonList = (jsonDecode(contents) as List).cast<Json>();
    return jsonList.map(fromJson).toList();
  }

  Future<void> _writeJsonList<T extends JsonSerializable>(File file, List<T> elements) async {
    final jsonList = elements.toJson().toList();
    final json = _encoder.convert(jsonList);
    await file.writeAsString(json);
  }

  Future<List<Category>> readCategories() =>
    _readJsonList(_categoriesFile, Category.fromJson);

  Future<void> writeCategories(List<Category> categories) =>
    _writeJsonList(_categoriesFile, categories);

  Future<List<Task>> readTasks() =>
    _readJsonList(_tasksFile, Task.fromJson);

  Future<void> writeTasks(List<Task> tasks) =>
    _writeJsonList(_tasksFile, tasks);

  Future<Directory> saveBackup() async {
    final now = DateTime.now();
    final backupDir = Directory(dir / "backups" / formatTimestamp(now));
    await backupDir.create(recursive: true);
    await _categoriesFile.copy(backupDir / "categories.json");
    await _tasksFile.copy(backupDir / "tasks.json");
    return backupDir;
  }

  Future<void> saveVersion(int version) =>
    _versionFile.writeAsString(version.toString());

  Future<int> getVersion() async {
    final contents = await _versionFile.readAsString();
    return contents.isEmpty ? 0 : int.parse(contents);
  }
}
