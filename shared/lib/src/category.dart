import "package:uuid/v4.dart";

import "utils.dart";
import "syncable.dart";

extension type CategoryID(String value) implements String {
  factory CategoryID.unique() => CategoryID(const UuidV4().generate());

  static CategoryID? fromJson(String? json) => json == null ? null : CategoryID(json);
}

class Category extends Syncable {
  @override final CategoryID id;
  String title;
  String? description;

  Category({
    required this.title,
    CategoryID? id,
  }) : id = id ?? CategoryID.unique();

  // ignore: use_super_parameters
  Category.fromJson(Json json) :
    id = CategoryID(json["id"]),
    title = json["title"],
    description = json["description"],
    super.fromJson(json);

  @override
  Json toJson() => {
    ...super.toJson(),
    "title": title,
    "description": description,
  };

  @override
  String toString() => title;

  @override
  // OK since all comparisons are based on ID
  // ignore: hash_and_equals, avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => other is Category && other.id == id;
}

final doneCategory = Category(title: "Finished tasks", id: CategoryID("done"));
