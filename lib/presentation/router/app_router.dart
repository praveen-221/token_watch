import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:token_watch/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:token_watch/presentation/screens/analytics/analytics_screen.dart';
import 'package:token_watch/presentation/screens/settings/settings_screen.dart';
import 'package:token_watch/presentation/screens/settings/api_key_management_screen.dart';
import 'package:token_watch/presentation/screens/provider_detail/provider_detail_screen.dart';

// Shell widget that provides bottom navigation for the first three routes
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (location.startsWith('/analytics')) currentIndex = 1;
    if (location.startsWith('/settings')) currentIndex = 2;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: cs.surface.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    isActive: currentIndex == 0,
                    onTap: () => context.go('/dashboard'),
                  ),
                  _NavBarItem(
                    icon: Icons.analytics,
                    label: 'Analytics',
                    isActive: currentIndex == 1,
                    onTap: () => context.go('/analytics'),
                  ),
                  _NavBarItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    isActive: currentIndex == 2,
                    onTap: () => context.go('/settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isActive ? cs.primary : cs.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppRouter {
  AppRouter._();

  // Singleton GoRouter — MUST NOT be recreated on rebuilds,
  // otherwise navigation state is lost and user is sent back to initialLocation.
  static final GoRouter _router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
              path: '/dashboard', builder: (c, s) => const DashboardScreen()),
          GoRoute(
              path: '/analytics', builder: (c, s) => const AnalyticsScreen()),
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
          GoRoute(
            path: '/settings/api-keys',
            builder: (c, s) => const ApiKeyManagementScreen(),
          ),
          GoRoute(
            path: '/provider/:id',
            builder: (c, s) {
              final id = s.pathParameters['id'] ?? '';
              return ProviderDetailScreen(providerIdString: id);
            },
          ),
        ],
      ),
    ],
  );

  static GoRouter get router => _router;
}
