import "dart:async";
import "dart:convert";

import "package:http/http.dart";
import "package:shared/shared.dart";

class HttpTasksServer extends Service implements BaseTasksServer {
  final client = Client();
  ServerInfo? server;

  @override
  Future<void> init() async { }

  Uri _baseUri(ServerInfo server) => Uri.parse("http://${server.address.address}:${server.port}");

  Uri _downloadUri(ServerInfo server, int version) => _baseUri(server).replace(
    path: "/download",
    queryParameters: {"version": version.toString()},
  );

  Uri _uploadUri() => _baseUri(server!).resolve("/upload");

  Future<Json> _request(Future<Response> Function() func) async {
    try {
      final response = await func().timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) throw SyncException("Bad response: ${response.statusCode}");
      return jsonDecode(response.body) as Json;
    } on TimeoutException {
      server = null;
      throw SyncException("Sync timed out");
    }
  }

  Future<Json> _get(Uri uri) => _request(() => client.get(uri));
  Future<Json> _post(Uri uri, Json body) => _request(() => client.post(uri, body: jsonEncode(body)));

  @override
  Future<ServerResponse> download(int version) async {
    server ??= await BroadcastClient.discover();
    if (server == null) throw SyncException("No servers found");
    final uri = _downloadUri(server!, version);
    final json = await _get(uri);
    return ServerResponse.fromJson(json);
  }

  @override
  Future<ServerResponse> upload({
    required int clientVersion,
    required Iterable<Task> newTasks,
    required Iterable<Category> newCategories,
  }) async {
    final body = {
      "version": clientVersion,
      "tasks": newTasks.toJson(),
      "categories": newCategories.toJson(),
    };
    final uri = _uploadUri();
    final json = await _post(uri, body);
    return ServerResponse.fromJson(json);
  }
}
