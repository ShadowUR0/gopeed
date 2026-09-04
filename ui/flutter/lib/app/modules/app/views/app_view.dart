import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../i18n/message.dart';
import '../../../../theme/liquid_glass.dart';
import '../../../../theme/theme.dart';
import '../../../../util/locale_manager.dart';
import '../../../../util/util.dart';
import '../../../rpc/webview_rpc_overlay.dart';
import '../../../rpc/webview_rpc_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/app_controller.dart';

class AppView extends GetView<AppController> {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = controller.downloaderConfig.value;
    return WithForegroundTask(
      child: GetMaterialApp.router(
        useInheritedMediaQuery: true,
        debugShowCheckedModeBanner: false,
        theme: GopeedTheme.light,
        darkTheme: GopeedTheme.dark,
        themeMode: ThemeMode.values.byName(config.extra.themeMode),
        translations: messages,
        locale: toLocale(config.extra.locale),
        fallbackLocale: fallbackLocale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: messages.keys.keys.map((e) => toLocale(e)).toList(),
        getPages: AppPages.routes,
        builder: (context, child) {
          if (Util.isDesktop()) {
            final brightness = Theme.of(context).brightness;
            windowManager.setBrightness(brightness);
          }

          final app = LiquidGlassBackground(
            child: child ?? const SizedBox.shrink(),
          );

          // Keep the GetX overlay compatibility fix while placing the entire
          // route tree above the liquid backdrop. RPC overlays stay on top.
          final entries = <OverlayEntry>[
            OverlayEntry(builder: (_) => app),
          ];
          if (WebViewRpcService.instance.supported) {
            entries.add(OverlayEntry(builder: (_) => const WebViewRpcOverlay()));
          }
          return Overlay(initialEntries: entries);
        },
      ),
    );
  }
}
