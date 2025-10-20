import "package:flutter/material.dart";
import "package:tasks/data.dart";

class CategoryTile extends StatelessWidget {
  final Category category;
  CategoryTile(this.category) : super(key: ValueKey(category));

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(category.title),
    subtitle: category.description == null ? null : Text(category.description!),
    leading: IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () { }
    ),
  );
}
