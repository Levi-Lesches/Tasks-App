import "package:shared/data.dart";
import "service.dart";
import "sync.dart";

typedef AsyncFunc<T> = Future<void> Function(T);

class ServerResponse {
  final Iterable<Task> tasks;
  final Iterable<Category> categories;
  final int version;

  const ServerResponse({
    required this.tasks,
    required this.categories,
    required this.version,
  });

  ServerResponse.fromJson(Json json) :
    tasks = json.toList("tasks", Task.fromJson),
    categories = json.toList("categories", Category.fromJson),
    version = json["version"];

  Json toJson() => {
    "tasks": tasks.toJson(),
    "categories": categories.toJson(),
    "version": version,
  };
}

abstract class TasksServer extends Service {
  Future<ServerResponse> upload({
    required Iterable<Task> newTasks,
    required Iterable<Category> newCategories,
  });

  Future<ServerResponse?> download(int version);
}

class HostedTasksServer extends SyncService implements TasksServer {
  HostedTasksServer({required super.database});

  @override
  Future<ServerResponse> upload({
    required Iterable<Task> newTasks,
    required Iterable<Category> newCategories,
  }) async {
    final didChange = tasks.merge(newTasks) || categories.merge(newCategories);
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
  Future<ServerResponse?> download(int version) async => ServerResponse(
    tasks: tasks.newerThan(version),
    categories: categories.newerThan(version),
    version: version,
  );
}
