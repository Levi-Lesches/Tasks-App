import "utils.dart";

extension type CategoryID(String value) { }

class Category extends JsonSerializable {
  final CategoryID id;
  String title;
  String description;

  Category({
    required this.title,
    required this.description,
    required this.id,
  });

  Category.fromJson(Json json) :
    id = CategoryID(json["id"]),
    title = json["title"],
    description = json["description"];

  @override
  Json toJson() => {
    "id": id,
    "title": title,
    "description": description,
  };

  @override
  String toString() => title;
}
