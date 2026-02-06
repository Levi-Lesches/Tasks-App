import "package:shared/data.dart";
import "package:test/test.dart";

extension on Settings {
  void checkParsing() {
    final other = Settings.fromJson(toJson());
    expect(themeModeIndex, other.themeModeIndex);
    expect(listOrder, orderedEquals(other.listOrder));
  }
}

void main() => group("[settings]", () {
  test("Settings can parse itself", () {
    final settings = Settings();
    settings.checkParsing();
    settings.listOrder = [CategoryID.unique(), CategoryID.unique()];
    settings.themeModeIndex = 1;
    settings.checkParsing();
  });
});
