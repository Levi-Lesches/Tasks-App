/// Defines and manages the different services used by the app.
library;

import "dart:io";

import "package:path_provider/path_provider.dart";
import "package:url_launcher/url_launcher.dart";

import "package:tasks/data.dart";
import "src/services/service.dart";
import "src/services/database.dart";
import "src/services/client.dart";

/// A [Service] that manages all other services used by the app.
class Services extends Service {
	/// Prevents other instances of this class from being created.
	Services._();

  // Define your services here
  late final DatabaseService database;
  final client = RemoteClient();

	/// The different services to initialize, in this order.
	List<Service> get services => [database, client];

	@override
	Future<void> init() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(root / "Tasks App");
    database = DatabaseService(dir);
		for (final service in services) {
      await service.init();
    }
    client.version = await database.getVersion();
	}

  void openFolder() => launchUrl(database.dir.uri);
}

/// The global services object.
final services = Services._();
