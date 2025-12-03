import "";

export "src/models/model.dart";
export "src/models/tasks.dart";
export "src/models/server.dart";
export "src/models/settings.dart";

/// A [DataModel] to manage all other data models.
class Models extends DataModel {
	/// Prevents other instances of this class from being created.
	Models._();

  // List your models here
  final tasks = TasksModel();
  final settings = SettingsModel();
  final server = ServerModel();

	/// A list of all models to manage.
	List<DataModel> get models => [settings, tasks, server];

	@override
	Future<void> init() async {
		for (final model in models) {
      await model.init();
    }
	}

  @override
  Future<void> initFromOthers() async {
    for (final model in models) {
      await model.initFromOthers();
    }
  }
}

/// The global data model singleton.
final models = Models._();
