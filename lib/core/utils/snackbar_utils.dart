import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

/// Utility class for showing beautiful snackbars throughout the app
class SnackbarUtils {
  /// Show a success message
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _showAwesomeSnackbar(
      context,
      title: title,
      message: message,
      contentType: ContentType.success,
    );
  }

  /// Show an error message
  static void showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _showAwesomeSnackbar(
      context,
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  /// Show a warning message
  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _showAwesomeSnackbar(
      context,
      title: title,
      message: message,
      contentType: ContentType.warning,
    );
  }

  /// Show an info message
  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _showAwesomeSnackbar(
      context,
      title: title,
      message: message,
      contentType: ContentType.help,
    );
  }

  /// Internal method to show the snackbar
  static void _showAwesomeSnackbar(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final snackBar = SnackBar(
      /// Need to set the background color to transparent to show the awesome design
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Show a material banner (stays at top until dismissed)
  static void showBanner(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final materialBanner = MaterialBanner(
      /// Need to set the background color to transparent to show the awesome design
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,

        /// We can add more configuration here
        inMaterialBanner: true,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);
  }

  /// Hide current banner
  static void hideBanner(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }
}
