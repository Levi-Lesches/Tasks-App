import "package:collection/collection.dart";
import "package:meta/meta.dart";

import "utils.dart";

abstract class Syncable<T extends Object> extends JsonSerializable {
  T get id;
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
  bool merge(Iterable<E> updated) {
    var didChange = false;
    for (final newValue in updated) {
      final index = indexWhereOrNull((value) => value.id == newValue.id);
      if (index == null) {
        didChange |= newValue.isModified;
        add(newValue);
      } else {
        final value = this[index];
        if (newValue.isModified || newValue.version > value.version) {
          this[index] = newValue;
          didChange |= newValue.isModified;
        }
      }
    }
    return didChange;
  }
}

extension SyncUtils2<T extends Object, E extends Syncable<T>> on Iterable<E> {
  Iterable<E> get notDeleted => where((item) => !item.isDeleted);
  Iterable<E> get modified => where((item) => item.isModified);
  Iterable<E> newerThan(int version) => where((item) => item.version > version);
  Iterable<E> modifiedOrNewerThan(int version) => where(
    (item) => item.isModified || item.version > version,
  );

  E? byID(T id) => firstWhereOrNull((item) => item.id == id);
}
