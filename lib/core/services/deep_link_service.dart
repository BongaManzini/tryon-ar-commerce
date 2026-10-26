import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

typedef DeepLinkCallback = void Function(Uri uri);

/// Service to handle universal links and custom schemes (e.g., tryon://product/123).
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<void> initDeepLinks(DeepLinkCallback onLinkReceived) async {
    try {
      // Check initial link when app is launched from terminated state
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('[DeepLinkService] Initial URI: $initialUri');
        onLinkReceived(initialUri);
      }

      // Listen for links while app is in foreground / background
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint('[DeepLinkService] Incoming URI stream: $uri');
          onLinkReceived(uri);
        },
        onError: (err) {
          debugPrint('[DeepLinkService] Error handling link stream: $err');
        },
      );
    } catch (e) {
      debugPrint('[DeepLinkService] Failed to initialize AppLinks: $e');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
