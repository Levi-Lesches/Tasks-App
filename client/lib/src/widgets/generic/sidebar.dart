import "dart:io";

import "package:flutter/material.dart";
import "package:tasks/widgets.dart";

class Sidebar {
  final List<NavigationDestination> items;
  final Widget? leading;
  final Widget? trailing;
  final int selectedIndex;
  final String title;
  final ValueChanged<int> onSelected;

  const Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.title,
    this.leading,
    this.trailing,
  });

  Widget _desktop(BuildContext context, double width) => SizedBox(
    width: width,
    child: Material(
      child: NavigationDrawer(
        tilePadding: EdgeInsets.zero,
        onDestinationSelected: onSelected,
        selectedIndex: selectedIndex,
        children: [
          DrawerHeader(
            child: Center(
              child: Text(title, style: context.textTheme.headlineMedium),
            ),
          ),
          leading ?? Container(),
          const SizedBox(height: 12),
          for (final item in items)
            NavigationDrawerDestination(icon: item.icon, label: Text(item.label)),
          const SizedBox(height: 12),
          trailing ?? Container(),
        ],
      ),
    ),
  );

  Widget _mobile(BuildContext context) => Builder(
    builder: (context) => NavigationDrawer(
      tilePadding: EdgeInsets.zero,
      onDestinationSelected: (value) {
        Scaffold.of(context).closeDrawer();
        onSelected(value);
      },
      selectedIndex: selectedIndex,
      children: [
        DrawerHeader(
          child: Center(
            child: Text(title, style: context.textTheme.headlineMedium),
          ),
        ),
        leading ?? Container(),
        const SizedBox(height: 12),
        for (final item in items)
          NavigationDrawerDestination(icon: item.icon, label: Text(item.label)),
        const SizedBox(height: 12),
        trailing ?? Container(),
      ],
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
