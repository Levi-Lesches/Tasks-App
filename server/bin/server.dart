// ignore_for_file: avoid_print

import "dart:convert";
import "dart:io";

import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_router/shelf_router.dart";

import "package:shared/shared.dart";

final database = DatabaseService(Directory("./data"));
List<Task> tasks = [];
List<Category> categories = [];
int serverVersion = 0;

void main() async {
  await database.init();
  categories = await database.readCategories();
  tasks = await database.readTasks();
  serverVersion = await database.getVersion();

  final router = Router();
  router.get("/categories", parseVersion(getCategories));
  router.post("/categories", postCategories);
  router.get("/tasks", parseVersion(getTasks));
  router.post("/tasks", postTasks);
  await io.serve(router.call, "0.0.0.0", 5001);
  print("Listening on port 5001");
}

Handler parseVersion(Response Function(Request, int) handler) => (request) {
  final versionString = request.url.queryParameters["version"];
  if (versionString == null) return Response.badRequest();
  final version = int.tryParse(versionString);
  if (version == null) return Response.badRequest();
  return handler(request, version);
};

String listToJson(Iterable<JsonSerializable> jsonList) => jsonEncode({
  "list": [
    for (final json in jsonList)
      json.toJson(),
  ],
  "version": serverVersion,
});

List<T> jsonToList<T>(String json, FromJson<T> fromJson) {
  final jsonList = jsonDecode(json) as List;
  return [
    for (final element in jsonList.cast<Json>())
      fromJson(element),
  ];
}

Response getCategories(Request request, int version) {
  final result = categories.where((value) => value.version > version);
  final body = listToJson(result);
  return Response.ok(body);
}

Response getTasks(Request request, int version) {
  final result = tasks.where((value) => value.version > version);
  final body = listToJson(result);
  print(body);
  return Response.ok(body);
}

Future<Response> post<T extends Syncable>(
  Request request,
  FromJson<T> fromJson,
  List<T> values,
  Future<void> Function(List<T>) write,
) async {
  final body = await request.readAsString();
  final result = jsonToList(body, fromJson);
  final didChange = values.merge(result);
  if (didChange) serverVersion++;
  await write(values);
  await database.saveVersion(serverVersion);
  return Response.ok(serverVersion.toString());
}

Future<Response> postCategories(Request request) =>
  post(request, Category.fromJson, categories, database.writeCategories);

Future<Response> postTasks(Request request) =>
  post(request, Task.fromJson, tasks, database.writeTasks);
