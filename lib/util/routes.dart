import 'package:bill_manager/views/DetalheResumo.dart';
import 'package:bill_manager/views/SearchView.dart';

import '../controllers/camera_controller.dart';
import '../controllers/despesa_controller.dart';
import '../controllers/evento_controller.dart';
import '../views/ResumoView.dart';
import '../views/EventoView.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../views/HomePage.dart';
import '../views/HomeView.dart';
import '../views/DespesaNewView.dart';

class AppPages {
  static const INITIAL = '/';

  static final routes = [
    GetPage(
      name: '/',
      page: () => HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NavigationController());
        Get.lazyPut<MyCameraController>(() => MyCameraController());
      }),
      children: [
        GetPage(name: '/home', page: () => HomeView()),
        GetPage(name: '/despesa', page: () => DespesaNewView()),
        GetPage(name: '/evento', page: () => EventoView()),
        GetPage(name: '/search', page: () => SearchView()),
        GetPage(name: '/resumo', page: () => ResumoView()),
        GetPage(name: '/detalhe', page: () => DetalheResumoView())
      ],
    ),
  ];
}