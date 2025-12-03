import "dart:io";

import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:tasks/models.dart";
import "package:tasks/widgets.dart";

class Sidebar {
  final List<NavigationDestination> items;
  final Widget? leading;
  final Widget? trailing;
  final int selectedIndex;
  final String title;
  final ValueChanged<int> onSelected;
  final void Function(int, int) onReorder;

  const Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.title,
    required this.onReorder,
    this.leading,
    this.trailing,
  });

  ListTile buildTile(
    BuildContext context,
    int index,
    NavigationDestination item, {
    VoidCallback? onTap,
  }) => ListTile(
    title: Text(item.label),
    key: ValueKey(item),
    selected: index == selectedIndex,
    selectedTileColor: Colors.blueGrey.withAlpha(75),
    leading: item.icon,
    titleTextStyle: context.textTheme.bodyMedium,
    subtitle: Text(models.tasks.allCategories
      .firstWhereOrNull((list) => list.title == item.label)
      ?.isDeleted.toString() ?? "N/A",
    ),
    onTap: () {onSelected(index); onTap?.call(); },
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
  );

  Widget _desktop(BuildContext context, double width) => SizedBox(
    width: width,
    child: Material(
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Text(title, style: context.textTheme.headlineMedium),
            ),
          ),
          leading ?? Container(),
          const SizedBox(height: 12),
          Expanded(
            child: ReorderableListView(
              onReorder: onReorder,
              children: [
                for (final (index, item) in items.indexed)
                  buildTile(context, index, item),
              ],
            ),
          ),
          const SizedBox(height: 12),
          trailing ?? Container(),
        ],
      ),
    ),
  );

  Widget _mobile(BuildContext context) => Builder(
    builder: (context) => SizedBox(
      width: 250,
      child: Material(
        child: Column(
          children: [
            DrawerHeader(
              child: Center(
                child: Text(title, style: context.textTheme.headlineMedium),
              ),
            ),
            leading ?? Container(),
            const SizedBox(height: 12),
            Expanded(
              child: ReorderableListView(
                onReorder: onReorder,
                children: [
                  for (final (index, item) in items.indexed)
                    buildTile(
                      context, index, item,
                      onTap: () => Scaffold.of(context).closeDrawer(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            trailing ?? Container(),
          ],
        ),
      ),
    ),
  );
}

class ResponsiveSidebar extends StatefulWidget {
  final AppBar Function(Widget? leading)? appBar;
  final Sidebar? sidebar;
  final Widget? body;
  final FloatingActionButton? fab;

  const ResponsiveSidebar({
    this.appBar,
    this.sidebar,
    this.body,
    this.fab,
    super.key,
  });

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  static double expandedWidth = Platform.isAndroid ? 250 : 200;
  bool isOpen = true;
  final key = UniqueKey();
  double get width => isOpen ? expandedWidth : 0;

  void toggle() => setState(() => isOpen = !isOpen);

  @override
  Widget build(BuildContext context) => context.isMobile
    ? _mobile() : _desktop();

  Widget _mobile() => Scaffold(
    key: key,
    drawer: widget.sidebar?._mobile(context),
    appBar: widget.appBar?.call(
      widget.sidebar == null ? null : Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          tooltip: "Open menu",
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    ),
    body: widget.body,
    floatingActionButton: widget.fab,
  );

  Widget _desktop() => Scaffold(
    key: key,
    appBar: widget.appBar?.call(null),
    floatingActionButton: widget.fab,
    body: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.sidebar?._desktop(context, width) ?? Container(),
        if (widget.sidebar != null) const VerticalDivider(),
        if (widget.body != null)
          Expanded(child: widget.body!),
      ],
    ),
  );
}
