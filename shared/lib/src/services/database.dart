import "dart:convert";
import "dart:io";

import "package:shared/data.dart";
import "service.dart";

extension on File {
  static const _encoder = JsonEncoder.withIndent("  ");

  Future<List<T>> readJsonList<T>(FromJson<T> fromJson) async {
    final contents = await readAsString();
    if (contents.isEmpty) return [];
    final jsonList = (jsonDecode(contents) as List).cast<Json>();
    return jsonList.map(fromJson).toList();
  }

  Future<T?> readJson<T>(FromJson<T> fromJson) async {
    final contents = await readAsString();
    if (contents.isEmpty) return null;
    final json = jsonDecode(contents) as Json;
    return fromJson(json);
  }

  Future<void> writeJsonList<T extends JsonSerializable>(List<T> elements) async {
    final jsonList = elements.toJson().toList();
    final json = _encoder.convert(jsonList);
    await writeAsString(json);
  }

  Future<void> writeJson(JsonSerializable data) async {
    final json = data.toJson();
    final contents = _encoder.convert(json);
    await writeAsString(contents);
  }
}

class DatabaseService extends Service {
  final Directory dir;
  DatabaseService(this.dir);

  File get _tasksFile => File(dir / "tasks.json");
  File get _categoriesFile => File(dir / "categories.json");
  File get _versionFile => File(dir / "version.json");
  File get _settingsFile => File(dir / "settings.json");

  @override
  Future<void> init() async {
    await dir.create(recursive: true);
    await _tasksFile.create();
    await _categoriesFile.create();
    await _versionFile.create();
    await _settingsFile.create();
  }

  Future<List<Category>> readCategories() =>
    _categoriesFile.readJsonList(Category.fromJson);

  Future<void> writeCategories(List<Category> categories) =>
    _categoriesFile.writeJsonList(categories);

  Future<List<Task>> readTasks() =>
    _tasksFile.readJsonList(Task.fromJson);

  Future<void> writeTasks(List<Task> tasks) =>
    _tasksFile.writeJsonList(tasks);

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

  Future<Settings?> readSettings() =>
    _settingsFile.readJson(Settings.fromJson);

  Future<void> writeSettings(Settings settings) =>
    _settingsFile.writeJson(settings);
}
