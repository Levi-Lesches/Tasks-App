import "utils.dart";

extension type TaskID(String value) { }

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
  String title;
  String body;
  TaskPriority priority;
  TaskStatus status;
  DateTime? dueDate;
  DateTime? doneDate;

  Task({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.doneDate,
  });

  Task.fromJson(Json json) :
    id = TaskID(json["id"]),
    title = json["title"],
    body = json["body"],
    priority = TaskPriority.fromJson(json["priority"]),
    status = TaskStatus.fromJson(json["status"]),
    dueDate = parseDateTime(json["dueDate"]),
    doneDate = parseDateTime(json["doneDate"]);

  @override
  Json toJson() => {
    "id": id.value,
    "title": title,
    "body": body,
    "priority": priority.toJson(),
    "status": status.toJson(),
    "dueDate": dueDate?.toIso8601String(),
    "doneDate": doneDate?.toIso8601String(),
  };

  @override
  String toString() => title;
}
