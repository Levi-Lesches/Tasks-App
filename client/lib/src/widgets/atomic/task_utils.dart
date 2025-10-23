import "package:flutter/material.dart";

import "package:shared/shared.dart";

class ChipData {
  final Color? color;
  final IconData icon;
  const ChipData(this.icon, this.color);
}

extension TaskPriorityUtils on TaskPriority {
  ChipData toChip() => switch(this) {
    TaskPriority.today => const ChipData(Icons.today, Colors.purple),
    TaskPriority.asap => const ChipData(Icons.error, Colors.redAccent),
    TaskPriority.high => const ChipData(Icons.flag, Colors.orange),
    TaskPriority.normal => const ChipData(Icons.info, null),
    TaskPriority.low => const ChipData(Icons.low_priority, Colors.blueGrey),
  };
}

extension TaskStatusUtils on TaskStatus {
  ChipData toChip() => switch (this) {
    TaskStatus.stuck => const ChipData(Icons.error, Colors.red),
    TaskStatus.inProgress => const ChipData(Icons.timer, Colors.yellow),
    TaskStatus.todo => const ChipData(Icons.info, null),
    TaskStatus.followUp => const ChipData(Icons.person, Colors.blueGrey),
    TaskStatus.done => const ChipData(Icons.done, Colors.green),
  };
}
