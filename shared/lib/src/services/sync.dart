import "package:shared/data.dart";
import "database.dart";
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

  Future<bool> harden() async {
    // Save all modified tasks and categories and increment version
    var didChange = false;
    final newVersion = version + 1;
    final toUpdate = <Syncable>[...categories, ...tasks].modified;
    for (final item in toUpdate) {
      item.version = newVersion;
      didChange = true;
    }
    if (didChange) {
      await database.writeTasks(tasks);
      await database.writeCategories(categories);
      await database.saveVersion(newVersion);
      version = newVersion;
    }
    return didChange;
  }
}

class SyncException implements Exception {
  final String message;
  SyncException(this.message);

  @override
  String toString() => message;
}
