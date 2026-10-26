/// Custom exception classes for TryOn.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic cause;

  AppException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode, cause: $cause)';
}

class SegmentationException extends AppException {
  SegmentationException(super.message, {super.cause});
}

class CameraServiceException extends AppException {
  CameraServiceException(super.message, {super.cause});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.statusCode, super.cause});
}

class StorageException extends AppException {
  StorageException(super.message, {super.cause});
}

class BarcodeNotFoundException extends AppException {
  final String barcode;
  BarcodeNotFoundException(this.barcode)
      : super('No product found matching barcode $barcode');
}
