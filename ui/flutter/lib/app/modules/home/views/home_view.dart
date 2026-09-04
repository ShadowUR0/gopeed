import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../theme/liquid_glass.dart';
import '../../../routes/app_pages.dart';
import '../../../views/responsive_builder.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context, delegate, currentRoute) {
      switch (currentRoute?.uri.path) {
        case Routes.EXTENSION:
          controller.currentIndex.value = 1;
          break;
        case Routes.SETTING:
          controller.currentIndex.value = 2;
          break;
        default:
          controller.currentIndex.value = 0;
          break;
      }

      final items = <LiquidNavigationItem>[
        LiquidNavigationItem(icon: Icons.task_rounded, label: 'task'.tr),
        LiquidNavigationItem(
          icon: Icons.extension_rounded,
          label: 'extensions'.tr,
        ),
        LiquidNavigationItem(
          icon: Icons.settings_rounded,
          label: 'setting'.tr,
        ),
      ];

      void navigate(int index) {
        controller.currentIndex.value = index;
        switch (index) {
          case 0:
            delegate.offAndToNamed(Routes.TASK);
            break;
          case 1:
            delegate.offAndToNamed(Routes.EXTENSION);
            break;
          case 2:
            delegate.offAndToNamed(Routes.SETTING);
            break;
        }
      }

      final narrow = ResponsiveBuilder.isNarrow(context);
      final routes = GetRouterOutlet(initialRoute: Routes.TASK);
      final dark = Theme.of(context).brightness == Brightness.dark;

      Widget buildRouteSurface() {
        if (narrow) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 82),
            child: LiquidGlassSurface(
              radius: 26,
              blur: 10,
              tint: dark
                  ? const Color(0x24141E1B)
                  : const Color(0x30FFFFFF),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: routes,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
          child: LiquidGlassSurface(
            radius: 30,
            blur: 14,
            tint: dark
                ? const Color(0x30141E1B)
                : const Color(0x38FFFFFF),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: routes,
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Row(
          children: [
            if (!narrow)
              Obx(() => LiquidNavigationRail(
                    items: items,
                    selectedIndex: controller.currentIndex.value,
                    onSelected: navigate,
                  )),
            Expanded(child: buildRouteSurface()),
          ],
        ),
        bottomNavigationBar: narrow
            ? Obx(() => LiquidBottomNavigation(
                  items: items,
                  selectedIndex: controller.currentIndex.value,
                  onSelected: navigate,
                ))
            : const SizedBox.shrink(),
      );
    });
  }
}
