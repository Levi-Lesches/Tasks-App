import "dart:convert";

import "package:http/http.dart";
import "package:tasks/data.dart";

import "database.dart";

class RemoteClient implements BaseDatabase {
  final client = Client();

  @override
  Future<void> init() async { }

  Future<List<T>> _getJsonList<T>(Uri uri, FromJson<T> fromJson) async {
    final response = await client.get(uri);
    if (response.statusCode != 200) throw Exception("Bad response");
    final jsonList = jsonDecode(response.body) as List;
    return [
      for (final json in jsonList.cast<Json>())
        fromJson(json),
    ];
  }

  Future<bool> _postJsonList<T extends JsonSerializable>(Uri uri, List<T> elements) async {
    final jsonList = [
      for (final element in elements)
        element.toJson(),
    ];
    final body = jsonEncode(jsonList);
    final response = await client.post(uri, body: body);
    return response.statusCode == 200;
  }

  final _uri = Uri.parse("http://192.168.1.210");

  @override
  Future<List<Category>> readCategories() =>
    _getJsonList(_uri.resolve("/categories"), Category.fromJson);

  @override
  Future<bool> writeCategories(List<Category> categories) =>
    _postJsonList(_uri.resolve("/categories"), categories);

  @override
  Future<List<Task>> readTasks() =>
    _getJsonList(_uri.resolve("/tasks"), Task.fromJson);

  @override
  Future<bool> writeTasks(List<Task> tasks) =>
    _postJsonList(_uri.resolve("/tasks"), tasks);
}
