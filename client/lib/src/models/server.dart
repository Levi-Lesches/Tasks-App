import "dart:io";

import "package:flutter/material.dart";
import "package:shelf/shelf.dart";

import "package:server/server.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
import "package:tasks/services.dart";

class EmbeddedTasksServer extends ShelfTasksServer with ChangeNotifier {
  EmbeddedTasksServer({required super.database});

  @override
  Future<Response> download(Request request, int version) async {
    // Before offering a GET response, save all unsaved data
    final didChange = await models.tasks.harden();
    // Reload the server's internal state
    if (didChange) await server.init();
    // Now it's safe to process a GET request
    return super.download(request, version);
  }

  @override
  Future<Response> upload(Request request) async {
    // Same as super, but broadcast if anything changed
    final oldVersion = server.version;
    final response = await super.upload(request);
    final newVersion = server.version;
    if (newVersion != oldVersion) notifyListeners();
    return response;
  }
}

class ServerModel extends DataModel {
  final server = EmbeddedTasksServer(database: services.database);
  List<Task> get tasks => server.server.tasks;
  List<Category> get lists => server.server.categories;

  @override
  Future<void> init() async {
    if (Platform.isWindows) await server.init();
    server.addListener(notifyListeners);
  }
}
