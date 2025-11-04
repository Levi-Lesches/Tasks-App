import "package:meta/meta.dart";

import "utils.dart";

abstract class Syncable extends JsonSerializable {
  Object get id;
  int version;
  bool isDeleted;
  Syncable({this.version = 0, this.isDeleted = false});

  Syncable.fromJson(Json json) :
    version = json["version"] ?? 0,
    isDeleted = json["isDeleted"] ?? false;

  @mustCallSuper
  @override
  Json toJson() => {"id": id, "version": version, "isDeleted": isDeleted};

  void modified() => version = 0;
  bool get isModified => version == 0;

  void deleted() {
    modified();
    isDeleted = true;
  }
}

extension SyncUtils<E extends Syncable> on List<E> {
  bool merge(List<E> updated) {
    var didChange = false;
    for (final newValue in updated) {
      final index = indexWhereOrNull((value) => value.id == newValue.id);
      if (index == null) {
        didChange = true;
        add(newValue);
      } else {
        final value = this[index];
        if (newValue.version > value.version) {
          didChange = true;
          this[index] = newValue;
        }
      }
    }
    return didChange;
  }
}
