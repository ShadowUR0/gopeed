import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../../../../api/api.dart';
import '../../../../api/model/create_task.dart';
import '../../../../api/model/create_task_batch.dart';
import '../../../../api/model/options.dart';
import '../../../../api/model/resolve_result.dart';
import '../../../../api/model/resolve_task.dart';
import '../../../../theme/liquid_controls.dart';
import '../../../../theme/liquid_glass.dart';
import '../../../../util/message.dart';
import '../../../views/directory_selector.dart';
import '../../app/controllers/app_controller.dart';

class CreateDialogView extends StatefulWidget {
  const CreateDialogView({Key? key}) : super(key: key);

  @override
  State<CreateDialogView> createState() => _CreateDialogViewState();
}

class _CreateDialogViewState extends State<CreateDialogView> {
  final _pathController = TextEditingController();
  final _nameController = TextEditingController();

  CreateTask? _createTask;
  ResolveResult? _resolveResult;
  Object? _error;
  bool _resolving = true;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    final appController = Get.find<AppController>();
    _pathController.text = renderPathPlaceholders(
      appController.downloaderConfig.value.downloadDir,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadArguments());
  }

  @override
  void dispose() {
    _pathController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadArguments() async {
    final args = Get.rootDelegate.arguments();
    if (args is! CreateTask || args.req?.url.isNotEmpty != true) {
      if (mounted) {
        setState(() {
          _resolving = false;
        });
      }
      return;
    }

    _createTask = args;
    if (args.opts?.path.isNotEmpty == true) {
      _pathController.text = args.opts!.path;
    }
    if (args.opts?.name.isNotEmpty == true) {
      _nameController.text = args.opts!.name;
    } else {
      _nameController.text = _fallbackName(args.req!.url);
    }

    await _resolve(args);
  }

  Future<void> _resolve(CreateTask createTask) async {
    setState(() {
      _resolving = true;
      _error = null;
    });

    try {
      final opt = Options(
        name: createTask.opts?.name ?? '',
        path: _pathController.text,
        selectFiles: const [],
        extra: _optsExtra(),
      );
      final result = await resolve(
        ResolveTask(req: createTask.req!, opts: opt),
      );
      if (!mounted) return;
      setState(() {
        _resolveResult = result;
        if (_nameController.text.trim().isEmpty ||
            _nameController.text == _fallbackName(createTask.req!.url)) {
          _nameController.text = _resolvedName(result, createTask.req!.url);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
    } finally {
      if (mounted) {
        setState(() {
          _resolving = false;
        });
      }
    }
  }

  Future<void> _confirm() async {
    final createTaskParams = _createTask;
    if (createTaskParams?.req == null) {
      return;
    }

    setState(() {
      _creating = true;
    });

    try {
      final rr = _resolveResult;
      final optExtra = _optsExtra();
      if (rr == null) {
        await createTask(
          CreateTask(
            req: createTaskParams!.req,
            opts: Options(
              name: _nameController.text.trim(),
              path: _pathController.text,
              selectFiles: const [],
              extra: optExtra,
            ),
          ),
        );
      } else if (rr.id.isEmpty) {
        final reqs = rr.res.files.map((file) {
          return CreateTaskBatchItem(
            req: file.req ?? createTaskParams!.req,
            opts: Options(
              name: file.name,
              path: path.join(_pathController.text, rr.res.name, file.path),
              selectFiles: const [],
              extra: optExtra,
            ),
          );
        }).toList();
        await createTaskBatch(CreateTaskBatch(reqs: reqs));
      } else {
        await createTask(
          CreateTask(
            rid: rr.id,
            opts: Options(
              name: _nameController.text.trim(),
              path: _pathController.text,
              selectFiles: rr.res.files.asMap().keys.toList(),
              extra: optExtra,
            ),
          ),
        );
      }
      await SystemNavigator.pop();
    } catch (e) {
      showErrorMessage(e);
      if (mounted) {
        setState(() {
          _creating = false;
        });
      }
    }
  }

  Object _optsExtra() {
    final httpConfig =
        Get.find<AppController>().downloaderConfig.value.protocolConfig.http;
    return OptsExtraHttp(connections: httpConfig.connections);
  }

  String _resolvedName(ResolveResult result, String url) {
    if (result.res.name.trim().isNotEmpty) {
      return result.res.name;
    }
    if (result.res.files.length == 1) {
      return result.res.files.first.name;
    }
    return _fallbackName(url);
  }

  String _fallbackName(String url) {
    final uri = Uri.tryParse(url);
    final uriName = uri == null ? '' : path.basename(uri.path);
    if (uriName.isNotEmpty && uriName != '.') {
      return uriName;
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: LiquidGlassSurface(
                radius: 30,
                blur: 28,
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'create'.tr,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _creating ? null : SystemNavigator.pop,
                          tooltip: 'cancel'.tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _resolving
                          ? const LinearProgressIndicator(
                              key: ValueKey('loading'),
                            )
                          : const SizedBox(
                              key: ValueKey('idle'),
                              height: 3,
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      enabled: !_creating,
                      decoration: InputDecoration(
                        labelText: 'rename'.tr,
                        prefixIcon:
                            const Icon(Icons.insert_drive_file_rounded),
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 14),
                    DirectorySelector(
                      controller: _pathController,
                      showAndoirdToggle: true,
                      allowEdit: true,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer
                              .withOpacity(0.55),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.error.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          _error.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _creating ? null : SystemNavigator.pop,
                          child: Text('cancel'.tr),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: LiquidGlassButton(
                            onPressed:
                                (_resolving || _creating) ? null : _confirm,
                            icon: _creating ? null : Icons.download_rounded,
                            child: _creating
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('download'.tr),
                          ),
                        ),
                      ],
                    ),
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
