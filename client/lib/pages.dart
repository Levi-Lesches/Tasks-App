import "package:go_router/go_router.dart";
import "package:tasks/data.dart";
import "package:tasks/models.dart";
export "package:go_router/go_router.dart";

import "src/pages/home/desktop.dart";
import "src/pages/task.dart";

/// Contains all the routes for this app.
class Routes {
  /// The route for the home page.
  static const home = "/";

  static const task = "/tasks";
}

Task? getTask(GoRouterState state) {
  final extra = state.extra;
  if (extra is Task) return extra;
  final taskID = state.pathParameters["id"];
  if (taskID == null) return null;
  return models.tasks.byID(TaskID(taskID));
}

extension GoRouterUtils on GoRouter {
  void openTaskPage(Task task) => pushNamed(
    Routes.task,
    extra: task,
    pathParameters: {"id": task.id.value},
  );
}

/// The router for the app.
final router = GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      name: Routes.home,
      builder: (_, __) => HomePageDesktop(),
    ),
    GoRoute(
      path: "/tasks/:id",
      name: Routes.task,
      redirect: (context, state) {
        final task = getTask(state);
        if (task == null) return Routes.home;
        return null;
      },
      builder: (context, state) {
        final task = getTask(state)!;  // [!] see redirect
        return TaskPage(task);
      },
    ),
  ],
);
