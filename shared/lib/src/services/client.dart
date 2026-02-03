import "package:shared/data.dart";

import "server.dart";
import "sync.dart";

class TasksClient extends SyncService {
  TasksClient({required super.database});

  void handleResponse(ServerResponse response) {
    version = response.version;
    tasks.merge(response.tasks);
    categories.merge(response.categories);
  }

  Future<bool> sync(TasksServer server) async {
    final oldVersion = version;

    // 1. Get all new items from the server
    var response = await server.download(version);
    if (response == null) throw SyncException("Could not download from server");
    handleResponse(response);

    // 2. Upload all new items to the server
    response = await server.upload(
      clientVersion: version,
      newTasks: tasks.modifiedOrNewerThan(response.version),
      newCategories: categories.modifiedOrNewerThan(response.version),
    );
    handleResponse(response);

    // 3. Update the local database
    await database.writeCategories(categories);
    await database.writeTasks(tasks);
    await database.saveVersion(version);

    return version > oldVersion;
  }
}
