import "dart:io";

import "package:shared/data.dart";
import "package:shared/services.dart";

class MockDatabase implements DatabaseService {
  const MockDatabase();

  @override
  Directory get dir => Directory("./do_not_use");

  @override
  Future<int> getVersion() async => 0;

  @override
  Future<void> init() async { }

  @override
  Future<List<Category>> readCategories() async => [];

  @override
  Future<List<Task>> readTasks() async => [];

  @override
  Future<void> writeCategories(List<Category> categories) async { }

  @override
  Future<void> writeTasks(List<Task> tasks) async { }

  @override
  Future<Directory> saveBackup() async => Directory("./do_not_use");

  @override
  Future<void> saveVersion(int version) async { }

  @override
  Future<Settings?> readSettings() async => Settings();

  @override
  Future<void> writeSettings(Settings settings) async { }

  @override
  Future<void> restore(Directory newDir) async { }
}

class MockServer extends HostedTasksServer {
   MockServer() : super(database: const MockDatabase());

  @override
  Future<ServerResponse> upload({
    required int clientVersion,
    required Iterable<Task> newTasks,
    required Iterable<Category> newCategories,
  }) => super.upload(
    clientVersion: clientVersion,
    newTasks: newTasks.copyAll(Task.fromJson),
    newCategories: newCategories.copyAll(Category.fromJson),
  );

  @override
  Future<ServerResponse?> download(int version) async => ServerResponse(
    tasks: tasks.newerThan(version).copyAll(Task.fromJson),
    categories: categories.newerThan(version).copyAll(Category.fromJson),
    version: version,
  );
}
