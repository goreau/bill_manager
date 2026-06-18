import 'package:bill_manager/components/appScaffold.dart';
import 'package:bill_manager/views/ResumoView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'HomeView.dart';

class HomePage extends StatelessWidget {
  final NavigationController controller = Get.put(NavigationController());

  final List<Widget> _pages = [
    HomeView(),
    ResumoView()
  ];

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return AppScaffold(
      title: 'Bill Manager',
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: _pages,
      )),
        actions: [
          Obx(() => Row(children: controller.appBarActions)),
        ],
        floatingActionButton: Obx(() {
          final icon = controller.fabIcon;
          final action = controller.fabAction;

          // Se não houver ícone nem ação, não mostra o botão
          if (icon == null || action == null) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: action,
            child: icon,
          );
        }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.travel_explore), label: 'Resumo'),
        ],
      )),
    );
  }
}
