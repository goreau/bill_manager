import 'package:bill_manager/controllers/bindings/evento_bindings.dart';
import 'package:bill_manager/views/DetalheResumo.dart';
import 'package:bill_manager/views/SearchView.dart';

import '../controllers/bindings/login_bindings.dart';
import '../controllers/camera_controller.dart';
import '../controllers/despesa_controller.dart';
import '../controllers/evento_controller.dart';
import '../controllers/login_controller.dart';
import '../views/CadastroView.dart';
import '../views/LoginView.dart';
import '../views/RegisterView.dart';
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
        GetPage(
          name: '/login',
          page: () => LoginView(),
        ),
        GetPage(
          name: '/register',
          page: () => RegisterView(),
        ),
        GetPage(name: '/home', page: () => HomeView(), binding: EventoBinding() ),
        GetPage(name: '/despesa', page: () => DespesaNewView()),
        GetPage(name: '/evento', page: () => EventoView()),
        GetPage(name: '/search', page: () => SearchView()),
        GetPage(name: '/resumo', page: () => ResumoView()),
        GetPage(name: '/detalhe', page: () => DetalheResumoView()),
        GetPage(name: '/cadastro', page: () => CadastroView()),
      ],
    ),
  ];
}

