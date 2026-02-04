import "package:collection/collection.dart";
import "package:shared/shared.dart";
import "package:test/test.dart";

import "merge_test.dart";
import "mock_db.dart";

extension on SyncService {
  Task? getTask(TaskID id) => tasks.firstWhereOrNull((task) => task.id == id);
}

const db = MockDatabase();

Future<(TasksServer, BaseTasksClient)> init2() async {
  final server = MockServer();
  final client = TasksClient(database: db);

  await server.init();
  await client.init();

  return (server, client);
}

Future<(TasksServer, BaseTasksClient, BaseTasksClient)> init3() async {
  final server = MockServer();
  final client1 = TasksClient(database: db);
  final client2 = TasksClient(database: db);
  await server.init();
  await client1.init();
  await client2.init();
  return (server, client1, client2);
}

void main() {
  test("Basic post", () async {
    final (server, client) = await init2();

    expect(client.tasks, isEmpty);
    expect(server.tasks, isEmpty);
    expect(server.version, 0);
    expect(client.version, 0);

    final category1 = Category(title: "Cat1");
    final task1 = Task(categoryID: category1.id, title: "Task1");

    expect(category1.isModified, isTrue, reason: "Created category should be modified");
    expect(task1.isModified, isTrue, reason: "Created task should be modified");
    expect(task1.isDeleted, isFalse, reason: "Created task should not be deleted");

    client.tasks.add(task1);
    await client.sync(server);

    final serverTask = server.getTask(task1.id);
    final clientTask = client.getTask(task1.id);

    expect(client.version, 1, reason: "Client version should be 1");
    expect(server.version, 1, reason: "Server version should be 1");

    expect(serverTask, isNotNull, reason: "Server did not save task");
    expect(serverTask!.version, 1, reason: "Server task version should be 1");

    expect(clientTask, isNotNull, reason: "Client did not save task");
    expect(clientTask!.version, 1, reason: "Client task version should be 1");
  });

  test("Basic delete", () async {
    final (server, client) = await init2();
    expect(server.version, isZero);
    expect(client.version, isZero);

    final cat2 = Category(title: "Cat2");
    final task2 = Task(categoryID: cat2.id, title: "Task2");
    client.tasks.add(task2);
    await client.sync(server);

    var clientTask = client.getTask(task2.id);
    var serverTask = server.getTask(task2.id);
    expect(client.version, 1);
    expect(server.version, 1);
    expect(clientTask, isNotNull);
    expect(clientTask!.version, 1);
    expect(serverTask, isNotNull);
    expect(serverTask!.version, 1);

    clientTask.deleted();
    expect(clientTask.isModified, isTrue);
    await client.sync(server);

    serverTask = server.getTask(task2.id);
    clientTask = client.getTask(task2.id);
    expect(client.version, 2, reason: "Client version should be 2");
    expect(server.version, 2, reason: "Server version should be 2");

    expect(clientTask, isNotNull);
    expect(clientTask!.version, 2);

    expect(serverTask, isNotNull);
    expect(serverTask!.version, 2);
  });

  void checkSync(List<SyncService> services, int length, int version) {
    for (final service in services) {
      expect(service.version, version);
      expect(service.tasks.length, length);
    }
  }

  test("Additions sync across clients", () async {
    final (server, client1, client2) = await init3();
    final services = [server, client1, client2];
    checkSync(services, 0, 0);

    final task = Task(categoryID: category.id, title: "Task1");
    client1.tasks.add(task);
    await client1.sync(server);
    await client2.sync(server);
    final client2Task = client2.getTask(task.id)!;
    expect(identical(task, client2Task), isFalse, reason: "Tasks are identical across clients");
    checkSync(services, 1, 1);

    final task2 = Task(categoryID: category.id, title: "Task2");
    client2.tasks.add(task2);
    expect(client1.getTask(task2.id), isNull);
    expect(client2.getTask(task2.id), isNotNull);
    await client2.sync(server);
    await client1.sync(server);
    checkSync(services, 2, 2);
    final task2Client1 = client1.getTask(task2.id)!;
    final task2Client2 = client2.getTask(task2.id)!;
    expect(identical(task2Client1, task2Client2), isFalse, reason: "Tasks are identical across clients");

    final task3 = Task(categoryID: category.id, title: "Task3");
    client1.tasks.add(task3);
    expect(server.tasks.length, 2);
    expect(client1.tasks.length, 3);
    expect(client2.tasks.length, 2);

    await client1.sync(server);
    expect(server.version, 3);
    expect(server.tasks.length, 3);
    expect(client1.version, 3);
    expect(client1.tasks.length, 3);
    expect(client2.version, 2);
    expect(client2.tasks.length, 2);

    await client2.sync(server);
    checkSync(services, 3, 3);

    var toDelete = client1.getTask(task2.id)!;
    var toCheck = client2.getTask(task2.id)!;
    expect(identical(toDelete, toCheck), isFalse);
    toDelete.deleted();
    expect(toDelete.isDeleted, isTrue);
    expect(toDelete.isModified, isTrue);
    expect(toCheck.isDeleted, isFalse);
    expect(toCheck.isModified, isFalse);

    await client1.sync(server);
    await client2.sync(server);
    checkSync(services, 3, 4);

    toDelete = client1.getTask(task2.id)!;
    toCheck = client2.getTask(task2.id)!;
    expect(identical(toDelete, toCheck), isFalse);
    expect(toDelete.isDeleted, isTrue);
    expect(toDelete.isModified, isFalse);
    expect(toCheck.isDeleted, isTrue);
    expect(toCheck.isModified, isFalse);
  });
}
