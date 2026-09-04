import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../theme/liquid_controls.dart';
import '../../util/message.dart';
import '../../util/util.dart';

final deviceInfo = DeviceInfoPlugin();

// Placeholder information for download directory
class PathPlaceholder {
  final String placeholder;
  final String description;
  final String example;

  const PathPlaceholder({
    required this.placeholder,
    required this.description,
    required this.example,
  });
}

// Available placeholders for download directory
List<PathPlaceholder> getPathPlaceholders() {
  final now = DateTime.now();
  final year = now.year.toString();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');

  return [
    PathPlaceholder(
      placeholder: '%year%',
      description: 'placeholderYear'.tr,
      example: year,
    ),
    PathPlaceholder(
      placeholder: '%month%',
      description: 'placeholderMonth'.tr,
      example: month,
    ),
    PathPlaceholder(
      placeholder: '%day%',
      description: 'placeholderDay'.tr,
      example: day,
    ),
    PathPlaceholder(
      placeholder: '%date%',
      description: 'placeholderDate'.tr,
      example: '$year-$month-$day',
    ),
  ];
}

// Render placeholders in a path with actual values
String renderPathPlaceholders(String path) {
  if (path.isEmpty) return path;

  final now = DateTime.now();
  final year = now.year.toString();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  final date = '$year-$month-$day';

  return path
      .replaceAll('%year%', year)
      .replaceAll('%month%', month)
      .replaceAll('%day%', day)
      .replaceAll('%date%', date);
}

void updateDirectorySelection(
  TextEditingController controller,
  String value, {
  VoidCallback? onChanged,
}) {
  if (controller.text == value) {
    return;
  }
  controller.value = controller.value.copyWith(
    text: value,
    selection: TextSelection.collapsed(offset: value.length),
    composing: TextRange.empty,
  );
  onChanged?.call();
}

class DirectorySelector extends StatefulWidget {
  final TextEditingController controller;
  final bool showLabel;
  final bool showAndoirdToggle;
  final bool allowEdit;
  final bool showPlaceholderButton;
  final VoidCallback? onEditComplete;
  final bool showRenderedPlaceholders;

  const DirectorySelector({
    Key? key,
    required this.controller,
    this.showLabel = true,
    this.showAndoirdToggle = false,
    this.allowEdit = false,
    this.showPlaceholderButton = false,
    this.onEditComplete,
    this.showRenderedPlaceholders = false,
  }) : super(key: key);

  @override
  State<DirectorySelector> createState() => _DirectorySelectorState();
}

class _DirectorySelectorState extends State<DirectorySelector> {
  @override
  Widget build(BuildContext context) {
    Widget? buildSelectWidget() {
      if (Util.isDesktop()) {
        return IconButton(
          icon: const Icon(Icons.folder_open_rounded),
          onPressed: () async {
            final dir = await FilePicker.platform.getDirectoryPath();
            if (dir != null) {
              updateDirectorySelection(
                widget.controller,
                dir,
                onChanged: widget.onEditComplete,
              );
            }
          },
        );
      }

      // Android 11+ increasingly restricts arbitrary external-storage access.
      // Keep Gopeed's existing two safe choices: app storage and Downloads.
      if (Util.isAndroid() && widget.showAndoirdToggle) {
        final isSwitchToDownloadDir =
            widget.controller.text.endsWith('/Gopeed');

        Future<bool> canSelect(int index) async {
          if (index == 0) {
            return true;
          }

          final downloadDir =
              (await DownloadsPath.downloadsDirectory())?.path;
          if (downloadDir == null) {
            return false;
          }

          // Check and request external storage permission when SDK < 30.
          if ((await deviceInfo.androidInfo).version.sdkInt < 30) {
            var status = await Permission.storage.status;
            if (!status.isGranted) {
              status = await Permission.storage.request();
              if (!status.isGranted) {
                showErrorMessage('noStoragePermission'.tr);
                return false;
              }
            }
          }

          // Preserve the original write-permission test before accepting the
          // Downloads destination.
          final fileRandomName =
              'test_${DateTime.now().millisecondsSinceEpoch}.tmp';
          final testFile = File('$downloadDir/Gopeed/$fileRandomName');
          try {
            await testFile.create(recursive: true);
            await testFile.writeAsString('test');
            await testFile.delete();
            return true;
          } catch (e) {
            showErrorMessage(e);
            return false;
          }
        }

        return LiquidGlassSegmentedControl(
          selectedIndex: isSwitchToDownloadDir ? 1 : 0,
          items: const [
            LiquidSegmentItem(icon: Icons.home_rounded),
            LiquidSegmentItem(icon: Icons.download_rounded),
          ],
          height: 40,
          itemWidth: 46,
          canSelect: canSelect,
          onChanged: (index) async {
            if (index == 0) {
              updateDirectorySelection(
                widget.controller,
                (await getExternalStorageDirectory())?.path ??
                    (await getApplicationDocumentsDirectory()).path,
                onChanged: widget.onEditComplete,
              );
            } else if (index == 1) {
              final downloads = await DownloadsPath.downloadsDirectory();
              if (downloads == null) return;
              updateDirectorySelection(
                widget.controller,
                '${downloads.path}/Gopeed',
                onChanged: widget.onEditComplete,
              );
            }
          },
        ).marginOnly(left: 10);
      }
      return null;
    }

    Widget? buildPlaceholderButton() {
      if (!widget.showPlaceholderButton) return null;

      return PopupMenuButton<String>(
        icon: const Icon(Icons.data_object_rounded),
        tooltip: 'insertPlaceholder'.tr,
        onSelected: (String placeholder) {
          final currentText = widget.controller.text;
          final selection = widget.controller.selection;
          final cursorPosition = selection.baseOffset >= 0
              ? selection.baseOffset
              : currentText.length;

          final newText = currentText.substring(0, cursorPosition) +
              placeholder +
              currentText.substring(cursorPosition);
          widget.controller.value = widget.controller.value.copyWith(
            text: newText,
            selection: TextSelection.fromPosition(
              TextPosition(offset: cursorPosition + placeholder.length),
            ),
            composing: TextRange.empty,
          );
          widget.onEditComplete?.call();
        },
        itemBuilder: (BuildContext context) {
          final placeholders = getPathPlaceholders();
          return placeholders.map((p) {
            return PopupMenuItem<String>(
              value: p.placeholder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.placeholder} - ${p.description}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'example'.trParams({'value': p.example}),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
      );
    }

    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              Widget? suffix;
              if (widget.showRenderedPlaceholders && value.text.contains('%')) {
                final renderedPath = renderPathPlaceholders(value.text);
                final theme = Theme.of(context);
                suffix = Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.24),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          renderedPath,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return TextFormField(
                readOnly:
                    widget.allowEdit ? false : (Util.isWeb() ? false : true),
                controller: widget.controller,
                decoration: widget.showLabel
                    ? InputDecoration(
                        labelText: 'downloadDir'.tr,
                        suffix: suffix,
                      )
                    : InputDecoration(suffix: suffix),
                validator: (v) {
                  return v!.trim().isNotEmpty ? null : 'downloadDirValid'.tr;
                },
                onEditingComplete: widget.onEditComplete,
                onTapOutside: (event) {
                  widget.onEditComplete?.call();
                },
              );
            },
          ),
        ),
        buildSelectWidget(),
        buildPlaceholderButton(),
      ].where((e) => e != null).map((e) => e!).toList(),
    );
  }
}
