import "package:shared/data.dart";
import "service.dart";

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

abstract class BaseTasksServer extends Service {
  Future<ServerResponse> upload({
    required int clientVersion,
    required Iterable<Task> newTasks,
    required Iterable<Category> newCategories,
  });

  Future<ServerResponse?> download(int version);
}
