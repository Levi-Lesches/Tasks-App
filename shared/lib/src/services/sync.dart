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
}

class SyncException implements Exception {
  final String message;
  SyncException(this.message);

  @override
  String toString() => message;
}
