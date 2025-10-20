import "package:flutter/material.dart";
import "package:uuid/v4.dart";

import "category.dart";
import "utils.dart";

extension type TaskID(String value) {
  factory TaskID.unique() => TaskID(const UuidV4().generate());
}

abstract class HasChip {
  Color? get color;
  IconData get icon;
}

enum TaskPriority implements HasChip {
  today("Today", Icons.today, Colors.purple),
  asap("ASAP", Icons.error, Colors.redAccent),
  high("High", Icons.flag, Colors.orange),
  normal("Normal", Icons.info, null),
  low("Low", Icons.low_priority, Colors.blueGrey);

  @override final IconData icon;
  @override final Color? color;
  final String displayName;
  const TaskPriority(this.displayName, this.icon, this.color);

  factory TaskPriority.fromJson(String json) => values.byName(json);
  String toJson() => name;

  @override
  String toString() => displayName;
}

enum TaskStatus implements HasChip {
  todo("To-Do", Icons.info, null),
  inProgress("In progress", Icons.timer, Colors.yellow),
  done("Done", Icons.done, Colors.green),
  stuck("Stuck", Icons.error, Colors.red),
  followUp("Waiting", Icons.person, Colors.blueGrey);

  @override final IconData icon;
  @override final Color? color;
  final String displayName;
  const TaskStatus(this.displayName, this.icon, this.color);

  factory TaskStatus.fromJson(String json) => values.byName(json);
  String toJson() => name;

  @override
  String toString() => displayName;
}

class Task extends JsonSerializable {
  final TaskID id;
  CategoryID categoryID;
  String title;

  String? description;
  TaskPriority priority;
  TaskStatus _status;
  DateTime? dueDate;
  DateTime? doneDate;
  DateTime? startDate;

  Task({
    required this.categoryID,
    required this.title,
  }) :
    id = TaskID.unique(),
    priority = TaskPriority.normal,
    _status = TaskStatus.todo;

  Task.fromJson(Json json) :
    id = TaskID(json["id"]),
    categoryID = CategoryID(json["categoryID"]),
    title = json["title"],
    description = json["description"],
    priority = TaskPriority.fromJson(json["priority"]),
    _status = TaskStatus.fromJson(json["status"]),
    dueDate = parseDateTime(json["dueDate"]),
    startDate = parseDateTime(json["startDate"]),
    doneDate = parseDateTime(json["doneDate"]);

  TaskStatus get status => _status;
  set status(TaskStatus value) {
    // Clear startDate if task is no longer started
    if (value == TaskStatus.todo) startDate = null;

    // If task has been started, set the startDate
    if (startDate == null && (value == TaskStatus.inProgress || value == TaskStatus.done)) startDate = DateTime.now();

    // Clear the doneDate if the task is no longer done
    if (value != TaskStatus.done) doneDate = null;

    // If task is complete, set the doneDate
    if (doneDate == null && value == TaskStatus.done) doneDate = DateTime.now();

    _status = value;
  }

  @override
  Json toJson() => {
    "id": id.value,
    "categoryID": categoryID.value,
    "title": title,
    "description": description,
    "priority": priority.toJson(),
    "status": status.toJson(),
    "dueDate": dueDate?.toIso8601String(),
    "startDate": startDate?.toIso8601String(),
    "doneDate": doneDate?.toIso8601String(),
  };

  @override
  String toString() => title;

  String? get bodyText {
    final buffer = StringBuffer();
    if (description != null) buffer.write(description);
    if (startDate != null || doneDate != null) {
      if (description != null) buffer.writeln();
      if (startDate != null) buffer.write("Started on ${formatDate(startDate!)}");
      if (doneDate != null) {
        if (startDate != null) buffer.write(" -- ");
        buffer.write("Finished on ${formatDate(doneDate!)}");
      }
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  bool get isThreeLine => description != null && (doneDate != null || startDate != null);

  void setPriority(TaskPriority priority) {

  }
}
