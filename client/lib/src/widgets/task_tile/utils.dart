import "package:flutter/material.dart";

import "package:shared/shared.dart";

class ChipData {
  final String name;
  final Color? color;
  final IconData icon;
  const ChipData(this.name, this.icon, this.color);

  @override
  String toString() => name;
}

extension TaskPriorityUtils on TaskPriority {
  ChipData toChip() => switch(this) {
    TaskPriority.today => const ChipData("Today", Icons.today, Colors.purple),
    TaskPriority.asap => const ChipData("ASAP", Icons.error, Colors.redAccent),
    TaskPriority.high => const ChipData("High", Icons.flag, Colors.orange),
    TaskPriority.normal => const ChipData("Normal", Icons.info, null),
    TaskPriority.low => const ChipData("Low", Icons.low_priority, Colors.blueGrey),
  };
}

extension TaskStatusUtils on TaskStatus {
  ChipData toChip() => switch (this) {
    TaskStatus.stuck => const ChipData("Stuck", Icons.error, Colors.red),
    TaskStatus.inProgress => const ChipData("In Progress", Icons.timer, Colors.yellow),
    TaskStatus.todo => const ChipData("To-Do", Icons.info, null),
    TaskStatus.followUp => const ChipData("Waiting", Icons.person, Colors.blueGrey),
    TaskStatus.done => const ChipData("Done", Icons.done, Colors.green),
  };
}

Color? _getTextColor(Color? backgroundColor) {
  if (backgroundColor == null) return null;
  final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
  return switch (brightness) {
    Brightness.dark => Colors.white,
    Brightness.light => Colors.black,
  };
}

Widget desktopChip(ChipData property) => Chip(
  label: Text(
    property.toString(),
    style: TextStyle(color: _getTextColor(property.color)),
  ),
  avatar: Icon(
    property.icon,
    color: _getTextColor(property.color),
  ),
  backgroundColor: property.color,
);

Widget mobileChip(ChipData data) => Chip(
  backgroundColor: data.color,
  label: Text(data.name, style: TextStyle(color: _getTextColor(data.color))),
  avatar: Icon(data.icon, color: _getTextColor(data.color)),
);

Widget iconChip(ChipData data) => Chip(
  backgroundColor: data.color,
  label: const Text(""),
  labelPadding: EdgeInsets.zero,
  avatar: Icon(data.icon, color: _getTextColor(data.color)),
);
