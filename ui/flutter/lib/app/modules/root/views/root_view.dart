import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../theme/liquid_glass.dart';
import '../../../routes/app_pages.dart';
import '../controllers/root_controller.dart';

class RootView extends GetView<RootController> {
  const RootView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(
      builder: (context, delegate, current) {
        final outlet = GetRouterOutlet(initialRoute: Routes.HOME);
        final path = current?.uri.path;

        if (path == Routes.CREATE) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LiquidGlassSurface(
                radius: 30,
                blur: 18,
                tint: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x34151F1C)
                    : const Color(0x42FFFFFF),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: outlet,
                ),
              ),
            ),
          );
        }

        return outlet;
      },
    );
  }
}
