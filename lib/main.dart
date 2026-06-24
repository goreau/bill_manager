import 'package:bill_manager/controllers/bindings/login_bindings.dart';
import 'package:bill_manager/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:bill_manager/util/routes.dart';
import 'api_config.dart';

void main() async {
  // 1. Garante que os bindings estejam prontos
  WidgetsFlutterBinding.ensureInitialized();

  String? token = await Storage.recupera('jwt_token');

  String initialRoute = (token != null) ? AppPages.INITIAL : '/login';

  // 2. Configura e injeta o Dio no GetX
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Adiciona o interceptor (assumindo que sua classe AuthInterceptor esteja importada)
  dio.interceptors.add(AuthInterceptor());

  // Injeta o dio globalmente para ser acessado por Get.find<Dio>()
  Get.put<Dio>(dio);

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bill Manager',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      theme: buildThemeData(),
      initialBinding: LoginBinding(),
    );
  }
}


// Sua função de tema permanece igual
ThemeData buildThemeData() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0XFF001440),
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'RobotoCondensed',
  );
}