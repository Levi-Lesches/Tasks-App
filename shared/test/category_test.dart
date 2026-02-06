import "package:shared/data.dart";
import "package:test/test.dart";

void main() => group("[categories]", () {
  test("Category is equal to itself", () {
    final cat = Category(title: "Category");
    expect(cat, equals(cat));
  });

  test("Two random categories are not equal", () {
    final cat1 = Category(title: "Category1");
    final cat2 = Category(title: "Category2");
    expect(cat1.id, isNot(equals(cat2.id)));
    expect(cat1, isNot(equals(cat2)));
  });

  test("Two categories with different titles are equal", () {
    final id = CategoryID.unique();
    final cat1 = Category(title: "Category1", id: id);
    final cat2 = Category(title: "Category2", id: id);
    expect(cat1, cat2);
  });
});
