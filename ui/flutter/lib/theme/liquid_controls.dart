import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// A draggable glass toggle based on the behavior of Tianyin's LiquidToggle.
///
/// The thumb stretches while pressed, follows horizontal drag continuously and
/// settles to the nearest state. Haptic feedback is emitted only when the
/// selected state actually changes.
class LiquidGlassToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;

  const LiquidGlassToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 58,
    this.height = 32,
  });

  @override
  State<LiquidGlassToggle> createState() => _LiquidGlassToggleState();
}

class _LiquidGlassToggleState extends State<LiquidGlassToggle> {
  late double _fraction;
  bool _dragging = false;
  bool _pressed = false;

  bool get _enabled => widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _fraction = widget.value ? 1 : 0;
  }

  @override
  void didUpdateWidget(covariant LiquidGlassToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && oldWidget.value != widget.value) {
      _fraction = widget.value ? 1 : 0;
    }
  }

  void _commit(bool value) {
    setState(() {
      _fraction = value ? 1 : 0;
      _dragging = false;
      _pressed = false;
    });
    if (value != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged?.call(value);
    }
  }

  void _onTap() {
    if (!_enabled) return;
    _commit(!widget.value);
  }

  void _onDragStart(DragStartDetails details) {
    if (!_enabled) return;
    setState(() {
      _dragging = true;
      _pressed = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_enabled) return;
    final ltr = Directionality.of(context) == TextDirection.ltr;
    final delta = (details.primaryDelta ?? 0) * (ltr ? 1 : -1);
    final travel = (widget.width - widget.height).clamp(1.0, 999.0);
    setState(() {
      _fraction =
          (_fraction + delta / travel).clamp(0.0, 1.0).toDouble();
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_enabled) return;
    _commit(_fraction >= 0.5);
  }

  void _onDragCancel() {
    if (!_enabled) return;
    setState(() {
      _dragging = false;
      _pressed = false;
      _fraction = widget.value ? 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final offTrack = dark
        ? const Color(0x5C787880)
        : const Color(0x33787878);
    final track = Color.lerp(offTrack, accent, _fraction)!;
    final alignment = Alignment(-1 + (_fraction * 2), 0);

    return Semantics(
      toggled: widget.value,
      enabled: _enabled,
      button: true,
      child: AnimatedOpacity(
        opacity: _enabled ? 1 : 0.48,
        duration: const Duration(milliseconds: 160),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? _onTap : null,
          onHorizontalDragStart: _enabled ? _onDragStart : null,
          onHorizontalDragUpdate: _enabled ? _onDragUpdate : null,
          onHorizontalDragEnd: _enabled ? _onDragEnd : null,
          onHorizontalDragCancel: _enabled ? _onDragCancel : null,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: AnimatedContainer(
              duration: _dragging
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(widget.height / 2),
                border: Border.all(
                  color: Colors.white.withOpacity(dark ? 0.12 : 0.34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.20 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: AnimatedAlign(
                  alignment: alignment,
                  duration: _dragging
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    width: _pressed ? widget.height + 2 : widget.height - 6,
                    height: widget.height - 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(dark ? 0.94 : 1),
                          Colors.white.withOpacity(dark ? 0.66 : 0.82),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(dark ? 0.24 : 0.85),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(dark ? 0.26 : 0.13),
                          blurRadius: _pressed ? 10 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(-0.55, -0.75),
                              radius: 1.25,
                              colors: [
                                Colors.white.withOpacity(0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
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
