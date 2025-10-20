import "package:flutter/material.dart";

class MenuPicker<T> extends StatelessWidget {
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final Widget Function(T) builder;
  final List<T> allValues;

  const MenuPicker({
    required this.selectedValue,
    required this.allValues,
    required this.builder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => MenuAnchor(
    menuChildren: [
      for (final value in allValues)
        MenuItemButton(
          child: builder(value),
          onPressed: () => onChanged(value),
        ),
    ],
    builder: (context, controller, child) => InkWell(
      onTap: () => controller.open(),
      child: builder(selectedValue),
    ),
  );
}
