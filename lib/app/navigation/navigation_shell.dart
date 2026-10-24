import 'package:flutter/material.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../../core/widgets/responsive_layout.dart';

/// Navigation shell supporting adaptive bottom bar (mobile) and NavigationRail (desktop/tablet).
class NavigationShell extends StatefulWidget {
  final int initialIndex;
  final List<Widget> pages;

  const NavigationShell({
    super.key,
    this.initialIndex = 0,
    required this.pages,
  });

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  late int _currentIndex;

  final List<_DestinationItem> _destinations = const [
    _DestinationItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    _DestinationItem(
      label: 'Vault',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder_rounded,
    ),
    _DestinationItem(
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    _DestinationItem(
      label: 'Insights',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onDestinationSelected(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveHelper.isWide(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              indicatorColor: AppColors.champagne.withValues(alpha: 0.25),
              selectedIconTheme: const IconThemeData(color: AppColors.champagne),
              unselectedIconTheme: IconThemeData(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.champagne,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontSize: 12,
              ),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.champagne.withValues(alpha: 0.4)),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/vault_logo.png',
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.shield_rounded,
                        color: AppColors.champagne,
                      ),
                    ),
                  ),
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Vault Settings',
                      onPressed: () => Navigator.of(context).pushNamed(RouteNames.settings),
                    ),
                  ),
                ),
              ),
              destinations: _destinations.map((d) {
                return NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                );
              }).toList(),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: widget.pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: widget.pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onDestinationSelected,
          items: _destinations.map((d) {
            return BottomNavigationBarItem(
              icon: Icon(d.icon),
              activeIcon: Icon(d.selectedIcon),
              label: d.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DestinationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _DestinationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
