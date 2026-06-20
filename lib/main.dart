import 'package:bill_manager/util/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bill Manager',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: buildThemeData(),
    );
  }
}

ThemeData buildThemeData() {
  // O Flutter gera automaticamente tons de primary, secondary, tertiary,
  // error, surface, e suas variantes de contraste (onPrimary, onSecondary, etc.)
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0XFF001440),
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,

    // Opcional: Se você quiser garantir uma fonte específica em todo o app
    fontFamily: 'RobotoCondensed',

    textTheme: TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ColorScheme.fromSeed(seedColor: const Color(0XFF001440)).onPrimaryContainer),
    ),
  );
}
