import "category.dart";
import "utils.dart";

class Settings extends JsonSerializable {
  int themeModeIndex;
  List<CategoryID> listOrder;

  Settings() :
    themeModeIndex = 0,  // auto
    listOrder = [];

  Settings.fromJson(Json json) :
    themeModeIndex = json["theme_mode"],
    listOrder = [
      for (final listID in json["list_order"])
        CategoryID(listID),
    ];

  @override
  Json toJson() => {
    "theme_mode": themeModeIndex,
    "list_order": [
      for (final list in listOrder)
        list.value,
    ],
  };
}
