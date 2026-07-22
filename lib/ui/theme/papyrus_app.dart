import 'package:flutter/cupertino.dart' show DefaultCupertinoLocalizations;
import 'package:flutter/widgets.dart';

import 'papyrus_page_route.dart';
import 'papyrus_theme.dart';

/// App root that replaces MaterialApp/CupertinoApp. Built directly on
/// WidgetsApp so navigation/localization plumbing works without pulling in
/// either design language's widgets.
class PapyrusApp extends StatelessWidget {
  const PapyrusApp({
    super.key,
    required this.title,
    required this.home,
    this.routes = const {},
    this.theme,
  });

  final String title;
  final Widget home;
  final Map<String, WidgetBuilder> routes;
  final PapyrusThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final themeData = theme ?? PapyrusThemeData.light;
    return PapyrusTheme(
      data: themeData,
      child: WidgetsApp(
        title: title,
        color: themeData.primary,
        debugShowCheckedModeBanner: false,
        home: home,
        routes: routes,
        pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
          return PapyrusPageRoute<T>(settings: settings, builder: builder);
        },
        localizationsDelegates: const [
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        textStyle: TextStyle(
          fontFamily: themeData.fontFamily,
          color: themeData.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }
}
