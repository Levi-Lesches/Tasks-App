import "dart:convert";

import "package:http/http.dart";
import "package:tasks/data.dart";

import "database.dart";

/* API
POST /tasks
- request: all modified tasks
- response: version

GET /tasks
- query parameters: version
- response: all modified tasks
*/

class RemoteClient implements BaseDatabase {
  final client = Client();

  // to be updated by local database on init()
  int version = 0;

  @override
  Future<void> init() async { }

  Future<String> _get(Uri uri) async {
    final response = await client.get(uri.replace(queryParameters: {"version": version}));
    if (response.statusCode != 200) throw Exception("Bad response");
    return response.body;
  }

  Future<List<T>> _getJsonList<T>(Uri uri, FromJson<T> fromJson) async {
    final body = await _get(uri);
    final result = jsonDecode(body) as Json;
    final jsonList = result["list"] as List;
    version = result["version"];
    return [
      for (final json in jsonList.cast<Json>())
        fromJson(json),
    ];
  }

  Future<void> _postJsonList<T extends Syncable>(Uri uri, List<T> elements) async {
    final jsonList = [
      for (final element in elements)
        if (element.isModified)
          element.toJson(),
    ];
    final body = jsonEncode(jsonList);
    final response = await client.post(uri, body: body);
    if (response.statusCode != 200) throw Exception("Bad response");
    version = int.parse(response.body);
  }

  final _uri = Uri.parse("http://192.168.1.210:5001");

  @override
  Future<List<Category>> readCategories() =>
    _getJsonList(_uri.resolve("/categories"), Category.fromJson);

  @override
  Future<void> writeCategories(List<Category> categories) =>
    _postJsonList(_uri.resolve("/categories"), categories);

  @override
  Future<List<Task>> readTasks() =>
    _getJsonList(_uri.resolve("/tasks"), Task.fromJson);

  @override
  Future<void> writeTasks(List<Task> tasks) =>
    _postJsonList(_uri.resolve("/tasks"), tasks);
}
