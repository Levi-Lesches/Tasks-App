import "package:shared/data.dart";
import "package:test/test.dart";

void main() => group("[tasks]", () {
  final category = Category(title: "Category");
  test("Setting status to inProgress or done sets the startDate", () {
    final task = Task(title: "Task", categoryID: category.id);
    expect(task.status, TaskStatus.todo);
    expect(task.startDate, isNull);

    task.status = .inProgress;
    expect(task.startDate, isNotNull);

    task.status = .todo;
    expect(task.startDate, isNull);

    task.status = .done;
    expect(task.startDate, isNotNull);
  });

  test("Setting the status to todo clears the startDate", () {
    final task = Task(title: "Task", categoryID: category.id);
    task.status = .inProgress;
    expect(task.startDate, isNotNull);
    final startDate = task.startDate!;

    task.status = .followUp;
    expect(task.startDate, startDate);

    task.status = .stuck;
    expect(task.startDate, startDate);

    task.status = .inProgress;
    expect(task.startDate, startDate);

    task.status = .done;
    expect(task.startDate, startDate);

    task.status = .todo;
    expect(task.startDate, isNull);
  });

  test("Setting the status sets the doneDate", () {
    final task = Task(title: "Task", categoryID: category.id);
    expect(task.doneDate, isNull);

    task.status = .done;
    expect(task.doneDate, isNotNull);

    task.status = .todo;
    expect(task.doneDate, isNull);
  });
});
