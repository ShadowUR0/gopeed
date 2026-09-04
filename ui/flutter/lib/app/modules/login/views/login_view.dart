import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../theme/liquid_glass.dart';
import '../../../views/responsive_builder.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNarrow = ResponsiveBuilder.isNarrow(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isNarrow ? 18 : 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: LiquidGlassSurface(
                radius: isNarrow ? 28 : 34,
                blur: 28,
                padding: EdgeInsets.all(isNarrow ? 24 : 38),
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              LiquidGlassSurface(
                                radius: 24,
                                blur: 18,
                                padding: const EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  'assets/icon/icon.svg',
                                  width: isNarrow ? 54 : 68,
                                  height: isNarrow ? 54 : 68,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Gopeed',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 36,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.70),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isNarrow ? 30 : 38),
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(1),
                          child: TextFormField(
                            controller: controller.usernameController,
                            autofillHints: const [AutofillHints.username],
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'username'.tr,
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'username_required'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(2),
                          child: Obx(
                            () => TextFormField(
                              controller: controller.passwordController,
                              autofillHints: const [AutofillHints.password],
                              obscureText: !controller.passwordVisible.value,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => controller.login(),
                              decoration: InputDecoration(
                                labelText: 'password'.tr,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  onPressed: controller.togglePasswordVisibility,
                                  icon: Icon(
                                    controller.passwordVisible.value
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'password_required'.tr;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: isNarrow ? 24 : 30),
                        Obx(
                          () => FilledButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.login,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : Text(
                                    'login'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
