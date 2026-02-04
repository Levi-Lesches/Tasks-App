import "client.dart";
import "server.dart";
import "sync.dart";

class HybridServer extends SyncService with BaseTasksClient, TasksServer {
  HybridServer({required super.database});
}
