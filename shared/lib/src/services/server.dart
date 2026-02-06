import "dart:math";

import "package:shared/data.dart";

import "server_base.dart";
import "sync.dart";

mixin TasksServer on SyncService implements BaseTasksServer {
  @override
  Future<ServerResponse> upload({
    required int clientVersion,
    required Iterable<Task> newTasks,
    required Iterable<Category> newCategories,
  }) async {
    // These three lines are split to avoid short-circuiting.
    final tasksChanged = tasks.merge(newTasks);
    final categoriesChanged = categories.merge(newCategories);
    final didChange = tasksChanged || categoriesChanged;
    version = max(version, clientVersion);
    await database.saveVersion(version);
    if (!didChange) {
      return ServerResponse(
        tasks: <Task>[],
        categories: <Category>[],
        version: version,
      );
    }
    version++;
    for (final item in <Syncable>[...newTasks, ...newCategories]) {
      item.version = version;
    }
    await database.writeTasks(tasks);
    await database.writeCategories(categories);
    return ServerResponse(
      tasks: newTasks,
      categories: newCategories,
      version: version,
    );
  }

  @override
  Future<ServerResponse> download(int clientVersion) async {
    await harden();
    return ServerResponse(
      tasks: tasks.newerThan(clientVersion),
      categories: categories.newerThan(clientVersion),
      version: version,
    );
  }
}
