import "dart:convert";
import "dart:io";

import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_router/shelf_router.dart";

import "package:shared/shared.dart";

class ShelfTasksServer extends Service {
  final DatabaseService database;
  final HostedTasksServer server;

  ShelfTasksServer({required this.database}) :
    server = HostedTasksServer(database: database);

  Handler _parseVersion(Future<Response> Function(Request, int) handler) => (request) {
    final versionString = request.url.queryParameters["version"];
    if (versionString == null) return Response.badRequest();
    final version = int.tryParse(versionString);
    if (version == null) return Response.badRequest();
    return handler(request, version);
  };

  @override
  Future<void> init() async {
    await server.init();
    final router = Router();
    router.get("/download", _parseVersion(download));
    router.post("/upload", upload);
    await io.serve(router.call, "0.0.0.0", 5001);
    print("Listening on port 5001");

    final serverType = Platform.isLinux ? ServerType.server : ServerType.pc;
    final broadcastServer = BroadcastServer(serverType);
    await broadcastServer.init();
    print("Listening for broadcasts on port 5002");
  }

  Future<Response> download(Request request, int version) async {
    final response = await server.download(version);
    if (response == null) return Response.internalServerError();
    final json = response.toJson();
    return Response.ok(jsonEncode(json));
  }

  Future<Response> upload(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body) as Json;
    final tasks = json.toList("tasks", Task.fromJson);
    final categories = json.toList("categories", Category.fromJson);
    final response = await server.upload(newTasks: tasks, newCategories: categories);
    return Response.ok(jsonEncode(response.toJson()));
  }
}
