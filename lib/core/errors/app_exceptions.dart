/// Base exception class for all SmartVault custom application exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// Thrown during database or local persistence failures.
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.details});
}

/// Thrown when entity or form validation rules fail.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

/// Thrown when a requested record is not found in local storage.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.details});
}

/// Thrown during external network, timeout, or REST API calls.
class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {super.code, super.details, this.statusCode});
}

/// Thrown when PIN authentication or security checks fail.
class SecurityException extends AppException {
  const SecurityException(super.message, {super.code, super.details});
}

/// Thrown during file attachment reading or writing failures.
class FileStorageException extends AppException {
  const FileStorageException(super.message, {super.code, super.details});
}
