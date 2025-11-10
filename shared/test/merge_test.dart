import "package:shared/data.dart";
import "package:test/test.dart";

final category = Category(title: "Category");

void main() => group("merge()", () {
  test("returns false on empty list", () {
    final task1 = Task(categoryID: category.id, title: "Task1");
    final tasks = <Task>[task1];
    final didChange = tasks.merge([]);
    expect(didChange, isFalse);
    expect(tasks.length, 1);
  });

  test("returns true when an item is added to an empty list", () {
    final tasks = <Task>[];
    final task = Task(categoryID: category.id, title: "Task");
    final didChange = tasks.merge([task]);
    expect(didChange, isTrue);
    expect(tasks.length, 1);
    expect(tasks.first, task);
  });

  test("returns true when an item is added to a non-empty list", () {
    final task1 = Task(categoryID: category.id, title: "Task1");
    final task2 = Task(categoryID: category.id, title: "Task2");
    final tasks = <Task>[task1];
    final didChange = tasks.merge([task2]);
    expect(didChange, isTrue);
    expect(tasks.length, 2);
    expect(tasks.contains(task2), isTrue);
  });

  test("returns false when no items are changed", () {
    final task1 = Task(categoryID: category.id, title: "Task1", version: 1);
    final tasks = <Task>[task1];
    final didChange = tasks.merge([task1]);
    expect(didChange, isFalse);
    expect(tasks.length, 1);
    expect(tasks.first, task1);
  });

  test("returns true when an item is modified", () {
    final task1 = Task(categoryID: category.id, title: "Task1", version: 1);
    final tasks = [task1];

    final copy = Task.fromJson(task1.toJson());
    copy.title = "Task1.1";
    copy.modified();
    expect(task1.id, copy.id);

    final didChange = tasks.merge([copy]);
    expect(didChange, isTrue);
    expect(tasks.length, 1);
    expect(tasks.first, copy);
  });

  test("returns true when a newer version is received", () {
    final task1 = Task(categoryID: category.id, title: "Task1", version: 1);
    final tasks = [task1];

    final copy = Task.fromJson(task1.toJson());
    copy.title = "Task1.1";
    copy.version = 2;
    expect(task1.id, copy.id);
    expect(copy.version, greaterThan(task1.version));

    final didChange = tasks.merge([copy]);
    expect(didChange, isTrue);
    expect(tasks.length, 1);
    expect(tasks.first, copy);
  });

  test("returns true when an item is deleted", () {
    final task1 = Task(categoryID: category.id, title: "Task1", version: 1);
    final tasks = [task1];

    final copy = Task.fromJson(task1.toJson());
    copy.deleted();
    expect(task1.id, copy.id);
    expect(copy.isModified, isTrue);
    expect(copy.isDeleted, isTrue);

    expect(tasks.first.isDeleted, isFalse);
    final didChange = tasks.merge([copy]);
    expect(didChange, isTrue);
    expect(tasks.length, 1);
    expect(tasks.first, copy);
    expect(tasks.first.isDeleted, isTrue);
  });

  test("returns true when a new item is deleted", () {
    final task1 = Task(categoryID: category.id, title: "Task1", version: 1);
    final tasks = [task1];

    final task2 = Task(categoryID: category.id, title: "Task2", version: 1);
    task2.deleted();
    expect(task1.id, isNot(task2.id));
    expect(task2.isModified, isTrue);
    expect(task2.isDeleted, isTrue);

    final didChange = tasks.merge([task2]);
    expect(didChange, isTrue);
    expect(tasks.length, 2);
    expect(tasks, contains(task1));
    expect(tasks, contains(task2));
    expect(tasks.last.isDeleted, isTrue);
  });
});
