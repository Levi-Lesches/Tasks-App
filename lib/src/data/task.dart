import "package:uuid/v4.dart";

import "category.dart";
import "utils.dart";

extension type TaskID(String value) {
  factory TaskID.unique() => TaskID(const UuidV4().generate());
}

enum TaskPriority {
  today,
  critical,
  high,
  low;

  factory TaskPriority.fromJson(String json) => values.byName(json);
  String toJson() => name;
}

enum TaskStatus {
  backlog,
  todo,
  inProgress,
  done,
  followUp;

  factory TaskStatus.fromJson(String json) => values.byName(json);
  String toJson() => name;
}

class Task extends JsonSerializable {
  final TaskID id;
  CategoryID categoryID;
  String title;
  String? description;
  TaskPriority priority;
  TaskStatus status;
  DateTime? dueDate;
  DateTime? doneDate;

  Task({
    required this.id,
    required this.categoryID,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.doneDate,
  });

  Task.fromJson(Json json) :
    id = TaskID(json["id"]),
    categoryID = CategoryID(json["categoryID"]),
    title = json["title"],
    description = json["description"],
    priority = TaskPriority.fromJson(json["priority"]),
    status = TaskStatus.fromJson(json["status"]),
    dueDate = parseDateTime(json["dueDate"]),
    doneDate = parseDateTime(json["doneDate"]);

  @override
  Json toJson() => {
    "id": id.value,
    "categoryID": categoryID.value,
    "title": title,
    "description": description,
    "priority": priority.toJson(),
    "status": status.toJson(),
    "dueDate": dueDate?.toIso8601String(),
    "doneDate": doneDate?.toIso8601String(),
  };

  @override
  String toString() => title;
}
