import 'dart:io';

import 'package:flutter/foundation.dart';

/// Debug-only: allows expired/invalid SSL cert for [allowedHost].
/// Only used on mobile/desktop; never enable in release.
void setupStagingHttpOverrides(String allowedHost) {
  HttpOverrides.global = _StagingHttpOverrides(allowedHost);
}

class _StagingHttpOverrides extends HttpOverrides {
  _StagingHttpOverrides(this.allowedHost);
  final String allowedHost;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return kDebugMode && host == allowedHost;
      };
  }
}
