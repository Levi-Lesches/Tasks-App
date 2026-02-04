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
    final didChange = tasks.merge(newTasks)
      || categories.merge(newCategories);
    version = max(version, clientVersion);
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
    await database.saveVersion(version);
    return ServerResponse(
      tasks: newTasks,
      categories: newCategories,
      version: version,
    );
  }

  @override
  Future<ServerResponse?> download(int version) async {
    await harden();
    return ServerResponse(
      tasks: tasks.newerThan(version),
      categories: categories.newerThan(version),
      version: version,
    );
  }
}
