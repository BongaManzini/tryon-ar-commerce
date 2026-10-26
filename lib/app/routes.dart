import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/ar_overlay/presentation/screens/ar_live_view_screen.dart';
import '../features/catalog/presentation/screens/barcode_scanner_screen.dart';
import '../features/catalog/presentation/screens/catalog_screen.dart';
import '../features/catalog/presentation/screens/product_detail_screen.dart';
import '../features/snap_3d/presentation/screens/snap_3d_studio_screen.dart';
import '../features/try_on/presentation/screens/try_on_workspace_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration with bottom navigation shell and nested stacks.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteConstants.catalogPath,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: RouteConstants.catalogPath,
          name: RouteConstants.catalogName,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CatalogScreen(),
          ),
        ),
        GoRoute(
          path: RouteConstants.snap3DPath,
          name: RouteConstants.snap3DName,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: Snap3DStudioScreen(),
          ),
        ),
        GoRoute(
          path: RouteConstants.tryOnPath,
          name: RouteConstants.tryOnName,
          pageBuilder: (context, state) {
            final productId = state.uri.queryParameters['productId'];
            return NoTransitionPage(
              child: TryOnWorkspaceScreen(initialProductId: productId),
            );
          },
        ),
        GoRoute(
          path: RouteConstants.barcodeScannerPath,
          name: RouteConstants.barcodeScannerName,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BarcodeScannerScreen(),
          ),
        ),
        GoRoute(
          path: RouteConstants.arLiveViewPath,
          name: RouteConstants.arLiveViewName,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ARLiveViewScreen(),
          ),
        ),
        GoRoute(
          path: RouteConstants.wishlistPath,
          name: RouteConstants.wishlistName,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WishlistScreen(),
          ),
        ),
      ],
    ),
    // Fullscreen Product Detail route outside the shell
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.productDetailPath,
      name: RouteConstants.productDetailName,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProductDetailScreen(productId: id);
      },
    ),
  ],
);

/// Persistent Bottom Navigation Shell Widget
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(RouteConstants.snap3DPath)) return 1;
    if (location.startsWith(RouteConstants.tryOnPath)) return 2;
    if (location.startsWith(RouteConstants.barcodeScannerPath)) return 3;
    if (location.startsWith(RouteConstants.arLiveViewPath)) return 4;
    if (location.startsWith(RouteConstants.wishlistPath)) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteConstants.catalogPath);
        break;
      case 1:
        context.go(RouteConstants.snap3DPath);
        break;
      case 2:
        context.go(RouteConstants.tryOnPath);
        break;
      case 3:
        context.go(RouteConstants.barcodeScannerPath);
        break;
      case 4:
        context.go(RouteConstants.arLiveViewPath);
        break;
      case 5:
        context.go(RouteConstants.wishlistPath);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        backgroundColor: const Color(0xFF18181B),
        indicatorColor: const Color(0xFF6C63FF).withOpacity(0.25),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: Color(0xFF6C63FF)),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.threed_rotation_outlined),
            selectedIcon: Icon(Icons.threed_rotation, color: Color(0xFF00E676)),
            label: '3D 360°',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_fix_high_outlined),
            selectedIcon: Icon(Icons.auto_fix_high, color: Color(0xFF6C63FF)),
            label: '2D Studio',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner, color: Color(0xFF00E676)),
            label: 'Scan Tag',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_in_ar_outlined),
            selectedIcon: Icon(Icons.view_in_ar, color: Color(0xFF6C63FF)),
            label: 'AR Live',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded, color: Color(0xFF6C63FF)),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
