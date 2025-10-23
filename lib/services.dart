/// Defines and manages the different services used by the app.
library;

import "src/services/service.dart";
import "src/services/database.dart";
import "src/services/client.dart";

/// A [Service] that manages all other services used by the app.
class Services extends Service {
	/// Prevents other instances of this class from being created.
	Services._();

  // Define your services here
  final database = DatabaseService();
  final client = RemoteClient();

	/// The different services to initialize, in this order.
	List<Service> get services => [database, client];

	@override
	Future<void> init() async {
		for (final service in services) {
      await service.init();
    }
	}
}

/// The global services object.
final services = Services._();
