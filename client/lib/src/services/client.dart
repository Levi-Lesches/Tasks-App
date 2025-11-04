import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/foundation.dart" show ValueNotifier;
import "package:http/http.dart";
import "package:tasks/data.dart";

import "package:shared/shared.dart";

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
  final versionNotifier = ValueNotifier(0);
  int get version => versionNotifier.value;
  set version(int value) => versionNotifier.value = value;

  (InternetAddress, ServerType)? server;
  InternetAddress? get serverAddress => server?.$1;
  ServerType? get serverType => server?.$2;
  bool get isReady => server != null;
  void onLostConnection() => server = null;

  @override
  Future<void> init() async {
    final broadcaster = BroadcastClient();
    await broadcaster.init();
    server = await broadcaster.broadcast();
    broadcaster.dispose();
  }

  Future<String> _get(Uri uri) async {
    final queryParameters = <String, String>{"version": version.toString()};
    final withVersion = uri.replace(queryParameters: queryParameters);
    try {
      final response = await client.get(withVersion).timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) throw Exception("Bad response: ${response.statusCode}");
      return response.body;
    } on TimeoutException {
      throw ClientException("Sync timed out");
    }
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
    for (final element in elements) {
      element.version = version;
    }
  }

  Uri get _uri => Uri.parse("http://${serverAddress?.address}:5001");

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

  Future<int> getServerVersion() async {
    final response = await _get(_uri.resolve("/version"));
    return int.tryParse(response) ?? 0;
  }
}
