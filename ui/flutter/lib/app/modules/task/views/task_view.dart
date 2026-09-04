import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;

import '../../../../api/model/task.dart';
import '../../../../theme/liquid_glass.dart';
import '../../../../util/file_explorer.dart';
import '../../../../util/util.dart';
import '../../../routes/app_pages.dart';
import '../../../views/copy_button.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_downloaded_controller.dart';
import '../controllers/task_downloading_controller.dart';
import 'task_downloaded_view.dart';
import 'task_downloading_view.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({Key? key}) : super(key: key);

  String? _displayTaskUrl(Task? task) {
    final rawUrl = task?.meta.req.rawUrl;
    if (rawUrl != null && rawUrl.isNotEmpty) {
      return rawUrl;
    }
    return task?.meta.req.url;
  }

  @override
  Widget build(BuildContext context) {
    final selectTask = controller.selectTask;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: controller.scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(66),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: LiquidGlassSurface(
                radius: 26,
                blur: 22,
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  height: 48,
                  child: TabBar(
                    tabs: const [
                      Tab(icon: Icon(Icons.file_download_rounded)),
                      Tab(icon: Icon(Icons.done_rounded)),
                    ],
                    onTap: (index) {
                      if (controller.tabIndex.value != index) {
                        controller.tabIndex.value = index;
                        final downloadingController =
                            Get.find<TaskDownloadingController>();
                        final downloadedController =
                            Get.find<TaskDownloadedController>();
                        switch (index) {
                          case 0:
                            downloadingController.start();
                            downloadedController.stop();
                            break;
                          case 1:
                            downloadingController.stop();
                            downloadedController.start();
                            break;
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            TaskDownloadingView(),
            TaskDownloadedView(),
          ],
        ),
        endDrawer: Drawer(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
          ),
          child: LiquidGlassSurface(
            radius: 28,
            blur: 24,
            tint: LiquidGlassPalette.strongGlassTint(theme.brightness),
            child: Obx(
              () => ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 65,
                    child: DrawerHeader(
                      child: Text(
                        'taskDetail'.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('taskName'.tr),
                    subtitle: buildTooltipSubtitle(selectTask.value?.name),
                  ),
                  ListTile(
                    title: Text('taskUrl'.tr),
                    subtitle:
                        buildTooltipSubtitle(_displayTaskUrl(selectTask.value)),
                    trailing: CopyButton(_displayTaskUrl(selectTask.value)),
                  ),
                  ListTile(
                    title: Text('downloadPath'.tr),
                    subtitle:
                        buildTooltipSubtitle(selectTask.value?.explorerUrl),
                    trailing: IconButton(
                      icon: const Icon(Icons.folder_open_rounded),
                      onPressed: () {
                        selectTask.value?.explorer();
                      },
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

  Widget buildTooltipSubtitle(String? text) {
    final showText = text ?? "";
    return Tooltip(
      message: showText,
      child: Text(
        showText,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

extension TaskEnhance on Task {
  bool get isFolder {
    return meta.res?.name.isNotEmpty ?? false;
  }

  String get explorerUrl {
    return path.join(Util.safeDir(meta.opts.path), Util.safeDir(name));
  }

  Future<void> explorer() async {
    if (Util.isDesktop()) {
      await FileExplorer.openAndSelectFile(explorerUrl);
    } else {
      Get.rootDelegate.toNamed(Routes.TASK_FILES, parameters: {'id': id});
    }
  }

  Future<void> open() async {
    if (status != Status.done) {
      return;
    }

    if (isFolder) {
      await explorer();
    } else {
      await OpenFilex.open(explorerUrl);
    }
  }
}
