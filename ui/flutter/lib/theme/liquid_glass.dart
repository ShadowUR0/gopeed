import 'dart:ui';

import 'package:flutter/material.dart';

/// Liquid-glass primitives for Gopeed.
///
/// The visual model follows the same ideas used by Kyant0/AndroidLiquidGlass:
/// translucent backdrop sampling, blur/vibrancy-like tint, a lens-like edge
/// highlight and a small interactive deformation on press. Flutter does not
/// expose Compose's Backdrop/Lens pipeline directly, so the implementation
/// maps those concepts to BackdropFilter, layered gradients and animated
/// surface deformation without changing Gopeed's downloader engine.
class LiquidGlassPalette {
  static const Color accent = Color(0xFF63D692);
  static const Color accentBlue = Color(0xFF65AFFF);
  static const Color accentViolet = Color(0xFF9A7BFF);

  static Color glassTint(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0x52131D1A)
      : const Color(0x66FFFFFF);

  static Color strongGlassTint(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xB31A2421)
          : const Color(0xCCF7FBF9);

  static Color border(Brightness brightness) => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.18)
      : Colors.white.withOpacity(0.72);
}

class LiquidGlassBackground extends StatelessWidget {
  final Widget child;

  const LiquidGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final baseTop = dark ? const Color(0xFF07100D) : const Color(0xFFF7FAF8);
    final baseBottom = dark ? const Color(0xFF0B1117) : const Color(0xFFF1F6FA);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseTop, baseBottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _AmbientOrb(
            alignment: Alignment(-1.05, -0.92),
            sizeFactor: 0.72,
            colors: [Color(0x5563D692), Color(0x0063D692)],
          ),
          const _AmbientOrb(
            alignment: Alignment(1.06, -0.10),
            sizeFactor: 0.66,
            colors: [Color(0x4465AFFF), Color(0x0065AFFF)],
          ),
          const _AmbientOrb(
            alignment: Alignment(0.18, 1.08),
            sizeFactor: 0.72,
            colors: [Color(0x389A7BFF), Color(0x009A7BFF)],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(dark ? 0.015 : 0.18),
                      Colors.transparent,
                      Colors.black.withOpacity(dark ? 0.12 : 0.025),
                    ],
                    stops: const [0, 0.42, 1],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  final Alignment alignment;
  final double sizeFactor;
  final List<Color> colors;

  const _AmbientOrb({
    required this.alignment,
    required this.sizeFactor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: sizeFactor,
        heightFactor: sizeFactor,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: colors),
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidGlassSurface extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color? tint;
  final VoidCallback? onTap;
  final bool interactive;

  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 24,
    this.blur = 18,
    this.tint,
    this.onTap,
    this.interactive = false,
  });

  @override
  State<LiquidGlassSurface> createState() => _LiquidGlassSurfaceState();
}

class _LiquidGlassSurfaceState extends State<LiquidGlassSurface> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.interactive && widget.onTap == null) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final dark = brightness == Brightness.dark;
    final radius = BorderRadius.circular(widget.radius);
    final innerRadius = BorderRadius.circular((widget.radius - 1).clamp(0, 999));
    final tint = widget.tint ?? LiquidGlassPalette.glassTint(brightness);
    final accent = theme.colorScheme.primary;

    return AnimatedScale(
      scale: _pressed ? 1.016 : 1,
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(dark ? 0.26 : 0.90),
                accent.withOpacity(dark ? 0.20 : 0.24),
                Colors.white.withOpacity(dark ? 0.08 : 0.32),
                Colors.black.withOpacity(dark ? 0.24 : 0.07),
              ],
              stops: const [0, 0.28, 0.62, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.26 : 0.10),
                blurRadius: _pressed ? 22 : 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(dark ? 0.03 : 0.30),
                blurRadius: 8,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: ClipRRect(
              borderRadius: innerRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: tint,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(dark ? 0.07 : 0.32),
                              tint,
                              accent.withOpacity(dark ? 0.055 : 0.045),
                              Colors.black.withOpacity(dark ? 0.08 : 0.015),
                            ],
                            stops: const [0, 0.30, 0.72, 1],
                          ),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _pressed ? 1 : 0.62,
                      duration: const Duration(milliseconds: 160),
                      child: Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(-0.65, -0.9),
                                radius: 1.25,
                                colors: [
                                  Colors.white.withOpacity(dark ? 0.20 : 0.54),
                                  Colors.transparent,
                                ],
                                stops: const [0, 0.62],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: widget.padding, child: widget.child),
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

class LiquidNavigationItem {
  final IconData icon;
  final String label;

  const LiquidNavigationItem({required this.icon, required this.label});
}

class LiquidBottomNavigation extends StatelessWidget {
  final List<LiquidNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const LiquidBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: LiquidGlassSurface(
        radius: 30,
        blur: 22,
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == selectedIndex;
              return Expanded(
                child: _LiquidNavButton(
                  item: item,
                  selected: selected,
                  onTap: () => onSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class LiquidNavigationRail extends StatelessWidget {
  final List<LiquidNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const LiquidNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
        child: LiquidGlassSurface(
          radius: 30,
          blur: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: SizedBox(
            width: 156,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Icon(Icons.downloading_rounded,
                    size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 18),
                ...List.generate(items.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _LiquidNavButton(
                      item: items[index],
                      selected: index == selectedIndex,
                      onTap: () => onSelected(index),
                      horizontal: true,
                    ),
                  );
                }),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Gopeed',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.48),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidNavButton extends StatelessWidget {
  final LiquidNavigationItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool horizontal;

  const _LiquidNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.68);

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            height: horizontal ? 48 : 52,
            padding: EdgeInsets.symmetric(horizontal: horizontal ? 12 : 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: selected
                  ? theme.colorScheme.primary.withOpacity(
                      theme.brightness == Brightness.dark ? 0.18 : 0.13)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? Colors.white.withOpacity(
                        theme.brightness == Brightness.dark ? 0.14 : 0.50)
                    : Colors.transparent,
              ),
            ),
            child: horizontal
                ? Row(
                    children: [
                      Icon(item.icon, size: 22, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: color,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 22, color: color),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
