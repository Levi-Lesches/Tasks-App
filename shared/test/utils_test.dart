import "dart:io";

import "package:test/test.dart";
import "package:shared/data.dart";

void main() => group("utils", () {
  test("Path utils", () {
    expect(Directory("dir1") / "dir2" / "file.dart", "dir1/dir2/file.dart");
  });

  test("formatTimestamp", () {
    final dt = DateTime(2026, 2, 5, 22, 48, 53);
    expect(formatTimestamp(dt), "2026-2-5-22-48-53");
  });
});
