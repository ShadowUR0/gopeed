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
    if (!_dragging && !_pressed) {
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

class LiquidSegmentItem {
  final IconData icon;
  final String? tooltip;

  const LiquidSegmentItem({
    required this.icon,
    this.tooltip,
  });
}

/// Compact segmented glass control inspired by the moving selection surface in
/// AndroidLiquidGlass's LiquidBottomTabs. It supports async selection guards so
/// callers such as Android storage selection can validate permissions before
/// changing the visible state.
class LiquidGlassSegmentedControl extends StatefulWidget {
  final List<LiquidSegmentItem> items;
  final int? selectedIndex;
  final ValueChanged<int?>? onChanged;
  final Future<bool> Function(int index)? canSelect;
  final bool allowEmptySelection;
  final double height;
  final double itemWidth;

  const LiquidGlassSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.canSelect,
    this.allowEmptySelection = false,
    this.height = 40,
    this.itemWidth = 46,
  }) : assert(items.length > 0);

  @override
  State<LiquidGlassSegmentedControl> createState() =>
      _LiquidGlassSegmentedControlState();
}

class _LiquidGlassSegmentedControlState
    extends State<LiquidGlassSegmentedControl> {
  int? _selectedIndex;
  bool _busy = false;

  bool get _enabled => widget.onChanged != null && !_busy;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant LiquidGlassSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_busy && oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  Future<void> _select(int index) async {
    if (!_enabled || index < 0 || index >= widget.items.length) return;

    final target = widget.allowEmptySelection && _selectedIndex == index
        ? null
        : index;
    if (target == _selectedIndex && !widget.allowEmptySelection) return;

    if (target != null && widget.canSelect != null) {
      setState(() => _busy = true);
      bool allowed = false;
      try {
        allowed = await widget.canSelect!(target);
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      if (!mounted || !allowed) return;
    }

    setState(() => _selectedIndex = target);
    HapticFeedback.selectionClick();
    widget.onChanged?.call(target);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: widget.onChanged == null ? 0.48 : 1,
      duration: const Duration(milliseconds: 160),
      child: LiquidGlassSurface(
        radius: widget.height / 2,
        blur: 10,
        tint: dark ? const Color(0x2C17201D) : const Color(0x3DFFFFFF),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            final selected = _selectedIndex == index;
            final color = selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.58);

            Widget segment = Semantics(
              selected: selected,
              button: true,
              enabled: _enabled,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _enabled ? () => _select(index) : null,
                  borderRadius: BorderRadius.circular((widget.height - 8) / 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: widget.itemWidth,
                    height: widget.height - 8,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular((widget.height - 8) / 2),
                      color: selected
                          ? theme.colorScheme.primary
                              .withOpacity(dark ? 0.18 : 0.13)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? Colors.white.withOpacity(dark ? 0.14 : 0.56)
                            : Colors.transparent,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(dark ? 0.14 : 0.055),
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: AnimatedScale(
                        scale: selected ? 1.06 : 1,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: Icon(item.icon, size: 20, color: color),
                      ),
                    ),
                  ),
                ),
              ),
            );

            if (item.tooltip != null && item.tooltip!.isNotEmpty) {
              segment = Tooltip(message: item.tooltip!, child: segment);
            }
            return segment;
          }),
        ),
      ),
    );
  }
}
