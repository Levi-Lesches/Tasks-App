import "dart:math";

import "package:shared/data.dart";

import "server_base.dart";
import "sync.dart";

class TasksClient = SyncService with BaseTasksClient;

mixin BaseTasksClient on SyncService {
  void _handleResponse(ServerResponse response) {
    version = max(version, response.version);
    tasks.merge(response.tasks);
    categories.merge(response.categories);
  }

  Future<bool> sync(BaseTasksServer server) async {
    final oldVersion = version;

    // 1. Get all new items from the server
    var response = await server.download(version);
    if (response == null) throw SyncException("Could not download from server");
    _handleResponse(response);

    // 2. Upload all new items to the server
    response = await server.upload(
      clientVersion: version,
      newTasks: tasks.modifiedOrNewerThan(response.version),
      newCategories: categories.modifiedOrNewerThan(response.version),
    );
    _handleResponse(response);

    // 3. Update the local database
    await database.writeCategories(categories);
    await database.writeTasks(tasks);
    await database.saveVersion(version);

    return version > oldVersion;
  }
}
