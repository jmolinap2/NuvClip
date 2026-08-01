import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvclip/app/theme/tokens.dart';

class RootShell extends StatelessWidget {
  const RootShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (icon: Icons.download_rounded, label: 'Descargar'),
    (icon: Icons.history_rounded, label: 'Historial'),
    (icon: Icons.settings_rounded, label: 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(Tokens.gutter, 0, Tokens.gutter, Tokens.space3),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Tokens.space2),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(Tokens.radiusStadium),
            border: Border.all(color: Palette.surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < _items.length; i++)
                _NavItem(
                  icon: _items[i].icon,
                  label: _items[i].label,
                  selected: navigationShell.currentIndex == i,
                  onTap: () => navigationShell.goBranch(
                    i,
                    initialLocation: i == navigationShell.currentIndex,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Tokens.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Tokens.space3, vertical: Tokens.space1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Tokens.durationFast,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: selected ? Palette.brandGradient : null,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: selected ? Colors.white : Palette.textMuted, size: 20),
            ),
            const SizedBox(height: Tokens.space1),
            Text(
              label,
              style: TextStyle(
                fontFamily: Tokens.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Palette.accentBlue : Palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
