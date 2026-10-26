import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/routes.dart';
import 'core/constants/route_constants.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/storage_service.dart';
import 'features/wishlist/presentation/controllers/wishlist_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive offline storage
  final storageService = StorageService();
  try {
    await storageService.init();
  } catch (e) {
    debugPrint('[Main] Storage initialization warning: $e');
  }

  // Initialize deep links service (universal and custom schemes)
  final deepLinkService = DeepLinkService();
  deepLinkService.initDeepLinks((uri) {
    debugPrint('[Main] Handling deep link URI: $uri');
    // e.g. tryon://product/prod_trench_01 or /try-on?productId=xyz
    if (uri.pathSegments.contains('product') && uri.pathSegments.length >= 2) {
      final productId = uri.pathSegments[1];
      appRouter.go('${RouteConstants.tryOnPath}?productId=$productId');
    } else if (uri.path == '/try-on' || uri.host == 'try-on') {
      appRouter.go(RouteConstants.tryOnPath);
    }
  });

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const TryOnApp(),
    ),
  );
}
