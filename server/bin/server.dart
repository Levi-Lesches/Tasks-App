import "dart:io";

import "package:server/server.dart";
import "package:shared/shared.dart";

void main() async {
  final dir = Platform.isLinux ? "./data" : r"C:\Users\Levi\Documents\Tasks App";
  final database = DatabaseService(Directory(dir));
  final hostName = Platform.isLinux ? "home-pi" : null;
  final shelfServer = ShelfTasksServer(database: database, hostName: hostName);

  await database.init();
  await shelfServer.init();
}
