import 'package:flutter/material.dart';

import '../../theme/liquid_glass.dart';
import 'webview_rpc_service.dart';

class WebViewRpcOverlay extends StatefulWidget {
  const WebViewRpcOverlay({super.key});

  @override
  State<WebViewRpcOverlay> createState() => _WebViewRpcOverlayState();
}

class _WebViewRpcOverlayState extends State<WebViewRpcOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WebViewRpcService.instance.markOverlayReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<WebViewRpcPageSession>>(
      valueListenable: WebViewRpcService.instance.pages,
      builder: (context, pages, _) {
        if (pages.isEmpty) {
          return const SizedBox.shrink();
        }
        return IgnorePointer(
          ignoring: false,
          child: Stack(
            children: pages
                .map((page) => _WebViewRpcPageView(page: page))
                .toList(growable: false),
          ),
        );
      },
    );
  }
}

class _WebViewRpcPageView extends StatefulWidget {
  const _WebViewRpcPageView({required this.page});

  final WebViewRpcPageSession page;

  @override
  State<_WebViewRpcPageView> createState() => _WebViewRpcPageViewState();
}

class _WebViewRpcPageViewState extends State<_WebViewRpcPageView> {
  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final content = page.buildWebView();
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.48),
        child: Center(
          child: SizedBox(
            width: page.width > 0 ? page.width.toDouble() : 960,
            height: page.height > 0 ? page.height.toDouble() : 720,
            child: LiquidGlassSurface(
              radius: 24,
              blur: 24,
              tint:
                  dark ? const Color(0xA0141D1A) : const Color(0xB8FFFFFF),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: Column(
                  children: [
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(
                          dark ? 0.065 : 0.045,
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.08),
                          ),
                        ),
                      ),
                      child: Text(
                        page.title.isNotEmpty ? page.title : 'WebView',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: content),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
