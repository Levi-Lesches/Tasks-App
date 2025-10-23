import "dart:io";

/// A JSON object
typedef Json = Map<String, dynamic>;

/// Utils on [Map].
extension MapUtils<K, V> on Map<K, V> {
  /// Gets all the keys and values as 2-element records.
	Iterable<(K, V)> get records => entries.map((entry) => (entry.key, entry.value));
}

/// Zips two lists, like Python
Iterable<(E1, E2)> zip<E1, E2>(List<E1> list1, List<E2> list2) sync* {
  if (list1.length != list2.length) throw ArgumentError("Trying to zip lists of different lengths");
  for (var index = 0; index < list1.length; index++) {
    yield (list1[index], list2[index]);
  }
}

/// Extensions on lists
extension ListUtils<E> on List<E> {
  /// Iterates over a pair of indexes and elements, like Python
  Iterable<(int, E)> get enumerate sync* {
    for (var i = 0; i < length; i++) {
      yield (i, this[i]);
    }
  }

  int? indexWhereOrNull(bool Function(E) predicate) {
    final index = indexWhere(predicate);
    if (index == -1) {
      return null;
    } else {
      return index;
    }
  }
}

extension PathUtils on FileSystemEntity {
  String operator /(String other) => "$path/$other";
}

DateTime? parseDateTime(String? json) =>
  json == null ? null : DateTime.parse(json);

abstract class JsonSerializable {
  Json toJson();
}

abstract class Syncable extends JsonSerializable {
  Object get id;
  bool isModified;
  int version;
  Syncable({
    this.isModified = false,
    this.version = 0,
  });

  Syncable.fromJson(Json json) :
    isModified = json["isModified"],
    version = json["version"];
}

extension NullableUtils<T> on T? {
  R? ifNotNull<R>(R Function(T) func) {
    final self = this;
    return self == null ? null : func(self);
  }
}

extension StringUtils on String {
  String? get nullIfEmpty => isEmpty ? null : this;
  String operator /(String other) => "$this/$other";
}

String formatDate(DateTime date) => "${date.month}/${date.day}/${date.year}";
String formatTimestamp(DateTime dt) => "${dt.year}-${dt.month}-${dt.day}-${dt.hour}-${dt.minute}-${dt.second}";

extension SyncUtils<E extends Syncable> on List<E> {
  bool merge(List<E> updated) {
    var didChange = false;
    for (final newValue in updated) {
      newValue.isModified = false;
      final index = indexWhereOrNull((value) => value.id == newValue.id);
      if (index == null) {
        didChange = true;
        add(newValue);
      } else {
        final value = this[index];
        if (value.isModified || value.version >= newValue.version) continue;  // do not override local changes
        didChange = true;
        this[index] = newValue;
      }
    }
    return didChange;
  }
}
