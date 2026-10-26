/// Domain-level failure representations.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class SegmentationFailure extends Failure {
  const SegmentationFailure([super.message = 'Failed to segment user silhouette']);
}

class CameraFailure extends Failure {
  const CameraFailure([super.message = 'Camera device unavailable or permission denied']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Local storage operation failed']);
}

class BarcodeScanningFailure extends Failure {
  const BarcodeScanningFailure([super.message = 'Failed to read barcode']);
}
