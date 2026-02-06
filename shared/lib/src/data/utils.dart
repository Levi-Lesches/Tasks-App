import "dart:io";

/// A JSON object
typedef Json = Map<String, dynamic>;

/// Utils on [Map].
extension MapUtils<K, V> on Map<K, V> {
  /// Gets all the keys and values as 2-element records.
	Iterable<(K, V)> get records => entries.map((entry) => (entry.key, entry.value));
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

extension PathUtils on Directory {
  String operator /(String other) => "$path/$other";
}

DateTime? parseDateTime(String? json) =>
  json == null ? null : DateTime.parse(json);

abstract class JsonSerializable {
  Json toJson();
}

extension JsonSerializableListUtils<T extends JsonSerializable> on Iterable<T> {
  List<Json> toJson() => map((item) => item.toJson()).toList();
  List<T> copyAll(FromJson<T> fromJson) => map((item) => fromJson(item.toJson())).toList();
}

typedef FromJson<T> = T Function(Json);

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

extension JsonUtils on Json {
  List<E> toList<E>(String key, FromJson<E> fromJson) =>
    (this[key] as List).cast<Json>().map(fromJson).toList();
}

String formatTimestamp(DateTime dt) => "${dt.year}-${dt.month}-${dt.day}-${dt.hour}-${dt.minute}-${dt.second}";
