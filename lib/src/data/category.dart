import "package:uuid/v4.dart";

import "utils.dart";

extension type CategoryID(String value) {
  factory CategoryID.unique() => CategoryID(const UuidV4().generate());
}

class Category extends JsonSerializable {
  final CategoryID id;
  String title;
  String? description;

  Category({
    required this.title,
  }) : id = CategoryID.unique();

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
