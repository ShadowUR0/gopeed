import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gopeed/database/database.dart';

import '../../../../theme/liquid_glass.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({
    super.key,
    required this.isHistoryListEmpty,
    required this.historyList,
  });

  final bool isHistoryListEmpty;
  final Widget historyList;

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: size.width * 0.8,
          height: size.height * 0.8,
          child: LiquidGlassSurface(
            radius: 30,
            blur: 24,
            tint: dark ? const Color(0x8A121B18) : const Color(0xA8FFFFFF),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.history_rounded,
                              size: theme.textTheme.headlineSmall?.fontSize,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 9),
                            Text(
                              'history'.tr,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                Database.instance.clearCreateHistory();
                                Navigator.pop(context);
                              },
                              tooltip: 'clearHistory'.tr,
                              icon: const Icon(
                                Icons.history_toggle_off_rounded,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.onSurface.withOpacity(0.08),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.isHistoryListEmpty
                            ? <Widget>[
                                Icon(
                                  Icons.manage_history_rounded,
                                  size: 34,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.46),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'noHistoryFound'.tr,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.62),
                                  ),
                                ),
                              ]
                            : <Widget>[
                                Expanded(child: widget.historyList),
                              ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
