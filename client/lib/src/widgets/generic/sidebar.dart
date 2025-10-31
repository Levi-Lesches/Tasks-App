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

  Widget _mobile(BuildContext context) => NavigationDrawer(
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
  );
}

class ResponsiveSidebar extends StatefulWidget {
  final AppBar? appBar;
  final Sidebar? sidebar;
  final Widget? body;
  final FloatingActionButton? fab;

  const ResponsiveSidebar({
    this.appBar,
    this.sidebar,
    this.body,
    this.fab,
  });

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  static double expandedWidth = 200;
  bool isOpen = true;
  double get width => isOpen ? expandedWidth : 0;

  void toggle() => setState(() => isOpen = !isOpen);

  @override
  void didChangeDependencies() {
    MediaQuery.sizeOf(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => context.isMobile
    ? _mobile() : _desktop();

  Widget _mobile() => Scaffold(
    drawer: widget.sidebar?._mobile(context),
    appBar: widget.appBar,
    body: widget.body,
    floatingActionButton: widget.fab,
  );

  Widget _desktop() => Scaffold(
    appBar: widget.appBar,
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
