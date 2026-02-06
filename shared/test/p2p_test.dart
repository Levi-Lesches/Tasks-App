import "package:shared/data.dart";
import "package:shared/services.dart";
import "package:test/test.dart";

import "mock_db.dart";

extension on SyncService {
  void expectTaskTitle(TaskID id, String title) {
    final task = tasks.byID(id);
    expect(task, isNotNull);
    if (task == null) return;
    expect(task.title, title);
  }
}

void main() => test("Peer-to-Peer", () async {
  final list = Category(title: "List");
  final mobile = HybridServer(database: const MockDatabase());
  final pc = HybridServer(database: const MockDatabase());
  final server = MockServer();
  expect(server.version, 0);
  final task1 = Task(title: "Task1", categoryID: list.id);
  final task2 = Task(title: "Task2", categoryID: list.id);

  // 1. Add task1 to the phone - v0
  mobile.tasks.add(task1);
  expect(mobile.version, 0);

  // 2. Add task2 to the PC - v0
  pc.tasks.add(task2);
  expect(pc.version, 0);

  // 3. Sync both devices to the server - both at v2
  await mobile.sync(server);
  expect(mobile.version, 1);
  expect(server.version, 1);

  await pc.sync(server);
  expect(pc.version, 2);
  expect(server.version, 2);
  expect(mobile.version, 1);

  await mobile.sync(server);  // get the PC tasks
  expect(server.version, 2);
  expect(pc.version, 2);
  expect(mobile.version, 2);

  // 4. Modify task2 on the phone - v2
  final mt2 = mobile.tasks.byID(task2.id);
  expect(mt2, isNotNull); if (mt2 == null) return;
  expect(identical(mt2, task2), false);
  expect(mt2.title, task2.title);
  mt2.title = "New Task2";
  mt2.modified();
  pc.expectTaskTitle(task2.id, task2.title);

  // 5. Modify task1 on the PC - v2
  final pt1 = pc.tasks.byID(task1.id);
  expect(pt1, isNotNull); if (pt1 == null) return;
  expect(pt1.title, task1.title);
  pt1.title = "New Task1";
  pt1.modified();
  mobile.expectTaskTitle(task1.id, task1.title);

  // 6. Sync phone with PC - both at v4
  await mobile.sync(pc);
  expect(mobile.version, 4);
  expect(pc.version, 4);

  pc.expectTaskTitle(task2.id, "New Task2");
  mobile.expectTaskTitle(task1.id, "New Task1");

  // 7. Sync both with server - v3
  expect(server.version, 2);
  await mobile.sync(server);
  expect(mobile.version, 4);
  expect(server.version, 4);

  await pc.sync(server);
  expect(pc.version, 4);
  expect(server.version, 4);

  // 8. Check all devices have the correct task1 + task2 and are all v4
  for (final device in [mobile, pc, server]) {
    expect(device.version, 4);
    device.expectTaskTitle(task1.id, "New Task1");
    device.expectTaskTitle(task2.id, "New Task2");
  }
});
