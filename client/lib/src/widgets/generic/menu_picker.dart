import "package:flutter/material.dart";

class MenuPicker<T> extends StatelessWidget {
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final Widget Function(T) builder;
  final List<T> allValues;
  final double? width;

  const MenuPicker({
    required this.selectedValue,
    required this.allValues,
    required this.builder,
    required this.onChanged,
    this.width,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: MenuAnchor(
      menuChildren: [
        for (final value in allValues)
          MenuItemButton(
            child: builder(value),
            onPressed: () => onChanged(value),
          ),
      ],
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.blueGrey.shade200),
      ),
      builder: (context, controller, child) => InkWell(
        onTap: () => controller.open(),
        child: builder(selectedValue),
      ),
    ),
  );
}
