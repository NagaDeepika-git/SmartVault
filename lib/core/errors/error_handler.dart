import 'dart:developer' as developer;
import 'app_exceptions.dart';

/// Centralized error handling and safe user messaging.
/// Strictly enforces privacy by avoiding logging sensitive record contents or private keys.
class ErrorHandler {
  ErrorHandler._();

  /// Converts any exception or error into a safe, human-understandable message for UI presentation.
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DatabaseException) {
      return 'Storage error: Unable to read or save vault data. Please try again.';
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is NotFoundException) {
      return error.message;
    } else if (error is NetworkException) {
      if (error.statusCode != null) {
        return 'Network service unavailable (Code: ${error.statusCode}). Check your connection.';
      }
      return 'Network request timed out or unavailable. Operating in local offline mode.';
    } else if (error is SecurityException) {
      return error.message;
    } else if (error is FileStorageException) {
      return 'Attachment error: Unable to access or save file.';
    } else if (error is Exception) {
      return 'An unexpected error occurred. Please try again.';
    }
    return 'Operation failed. Please try again.';
  }

  /// Safe logging that protects sensitive personal data and identifiers.
  static void logSafe(String action, {dynamic error, StackTrace? stackTrace}) {
    final sanitizedMessage = '[SmartVault] $action: ${error?.runtimeType ?? 'Info'}';
    developer.log(
      sanitizedMessage,
      time: DateTime.now(),
      error: error is AppException ? error.code : null,
      stackTrace: stackTrace,
    );
  }
}
