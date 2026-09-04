import 'package:flutter/material.dart';

import 'liquid_glass.dart';

/// A capsule-style interactive control inspired by AndroidLiquidGlass's
/// LiquidButton: translucent backdrop, bright rim, compact blur and a small
/// press deformation supplied by [LiquidGlassSurface].
class LiquidGlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final double radius;

  const LiquidGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final dark = theme.brightness == Brightness.dark;
    final tint = enabled
        ? theme.colorScheme.primary.withOpacity(dark ? 0.16 : 0.11)
        : theme.colorScheme.onSurface.withOpacity(dark ? 0.06 : 0.04);
    final foreground = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.38);

    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.68,
      duration: const Duration(milliseconds: 160),
      child: LiquidGlassSurface(
        radius: radius,
        blur: 12,
        tint: tint,
        interactive: enabled,
        onTap: onPressed,
        padding: padding,
        child: DefaultTextStyle.merge(
          style: theme.textTheme.labelLarge?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: foreground, size: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 8),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
