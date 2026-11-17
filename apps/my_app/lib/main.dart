import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:te_editor/te_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/router.dart';
import 'package:te_widgets/te_widgets.dart';

void main() async {
  await initializeApp(
    glass: true,
    glassLook: TGlassLook.liquid,
    glassStatic: true,
    glassImageThumbnail:
        'UklGRmYBAABXRUJQVlA4IFoBAADwDgCdASqAAFYAPtFYoUuoLachr1m70bAaCWcAy50Jj/QUFrin/8j7iFfjhFGQ5J7yVoDMS15ujjcBpZcw/P3unZkQcFOeMNN8ja28S1vCoccwNBdgLWzn04f6/Z/42M+oFpdTrbqRYNtkZLmwrJUsNPuWcN2mBIEA4+rGbXlIgAD+8G7MAwsWjiAxw/SSY1r4H2HmctMPlXs4HYcv95eyPICOidS9smcz9of5r/saiMpd/7H+4rYLcbO6WUlwgwN2+U1KW7QSFceYZ+raUGUbbZfDJqkjOsVxZ2xz0ASx7N3hULZPpbEXq8BtzlzXFWYmqLDh+ws+CGvUqj/WxVAcVf7ER0+fLLGbNGQfp5eUWH+RhGcQP/cCt4IzEy0aTrBOCi+NVPAFArAqfHdLDIgIjrSzQduPl4fYUdmIUICz7KbuutBmXCYtv1k/oKDs8oBBL0+VFxw7QAAA',
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  final GoRouter _router = router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final theme = themeState.theme;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: themeState.effectiveThemeMode,
      routerConfig: _router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
    );
  }
}
