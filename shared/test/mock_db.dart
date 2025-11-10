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
}

class MockServer extends HostedTasksServer {
   MockServer() : super(database: const MockDatabase());

  @override
  Future<ServerResponse> upload({
    required Iterable<Task> newTasks,
    required Iterable<Category> newCategories,
  }) => super.upload(
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
