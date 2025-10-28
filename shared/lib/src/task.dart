import "package:uuid/v4.dart";

import "category.dart";
import "utils.dart";

extension type TaskID(String value) implements String {
  factory TaskID.unique() => TaskID(const UuidV4().generate());
  static TaskID? parse(String? id) => id == null ? null : TaskID(id);
}

enum TaskPriority {
  today,
  asap,
  high,
  normal,
  low;

  factory TaskPriority.fromJson(String json) => values.byName(json);
  String toJson() => name;
}

enum TaskStatus {
  stuck,
  inProgress,
  todo,
  followUp,
  done;

  factory TaskStatus.fromJson(String json) => values.byName(json);
  String toJson() => name;
}

class Task extends Syncable {
  @override final TaskID id;
  CategoryID categoryID;
  String title;

  CategoryID? originalCategoryID;
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

  // ignore: use_super_parameters
  Task.fromJson(Json json) :
    id = TaskID(json["id"]),
    categoryID = CategoryID(json["categoryID"]),
    originalCategoryID = CategoryID.fromJson(json["originalCategoryID"]),
    title = json["title"],
    description = json["description"],
    priority = TaskPriority.fromJson(json["priority"]),
    _status = TaskStatus.fromJson(json["status"]),
    dueDate = parseDateTime(json["dueDate"]),
    startDate = parseDateTime(json["startDate"]),
    doneDate = parseDateTime(json["doneDate"]),
    super.fromJson(json);

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
    "version": version,
    "isModified": isModified,
    "categoryID": categoryID.value,
    "title": title,
    "description": description,
    "priority": priority.toJson(),
    "status": status.toJson(),
    "dueDate": dueDate?.toIso8601String(),
    "startDate": startDate?.toIso8601String(),
    "doneDate": doneDate?.toIso8601String(),
    "originalCategoryID": originalCategoryID,
  };

  @override
  String toString() => title;

  String? get bodyText {
    final buffer = StringBuffer();
    if (description != null) {
      final lines = description!.split("\n");
      final line = lines.first;
      if (line.length > 50) {
        buffer.write(line.substring(0, 50));
      } else {
        buffer.write(line);
      }
      if (lines.first.length > 50 || lines.length > 1) buffer.write("...");
    }
    if (Task.showDates) {
      if (startDate != null || doneDate != null) {
        if (description != null) buffer.writeln();
        if (startDate != null) buffer.write("Started on ${formatDate(startDate!)}");
        if (doneDate != null) {
          if (startDate != null) buffer.write(" -- ");
          buffer.write("Finished on ${formatDate(doneDate!)}");
        }
      }
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  bool get isThreeLine => showDates && (description != null && (doneDate != null || startDate != null));

  static bool showDates = false;
}
