import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/person_cutout.dart';
import '../../data/segmentation_repository.dart';

class SegmentationState {
  final bool isLoading;
  final PersonCutout? cutout;
  final String? errorMessage;
  final double confidenceThreshold;

  const SegmentationState({
    this.isLoading = false,
    this.cutout,
    this.errorMessage,
    this.confidenceThreshold = 0.65,
  });

  SegmentationState copyWith({
    bool? isLoading,
    PersonCutout? cutout,
    String? errorMessage,
    double? confidenceThreshold,
  }) {
    return SegmentationState(
      isLoading: isLoading ?? this.isLoading,
      cutout: cutout ?? this.cutout,
      errorMessage: errorMessage,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
    );
  }
}

class SegmentationController extends StateNotifier<SegmentationState> {
  final SegmentationRepository _repository;

  SegmentationController(this._repository) : super(const SegmentationState());

  Future<void> loadMockCutout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cutout = await _repository.getMockCutout();
      state = state.copyWith(isLoading: false, cutout: cutout);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> captureFromCamera() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cutout = await _repository.captureAndSegmentFromCamera(
        confidenceThreshold: state.confidenceThreshold,
      );
      if (cutout != null) {
        state = state.copyWith(isLoading: false, cutout: cutout);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cutout = await _repository.pickAndSegmentFromGallery(
        confidenceThreshold: state.confidenceThreshold,
      );
      if (cutout != null) {
        state = state.copyWith(isLoading: false, cutout: cutout);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateConfidenceThreshold(double threshold) {
    state = state.copyWith(confidenceThreshold: threshold);
  }

  void clearCutout() {
    state = state.copyWith(cutout: null);
  }
}

final segmentationRepositoryProvider = Provider<SegmentationRepository>((ref) {
  final repo = SegmentationRepositoryImpl();
  ref.onDispose(() => repo.dispose());
  return repo;
});

final segmentationControllerProvider =
    StateNotifierProvider<SegmentationController, SegmentationState>((ref) {
  final repo = ref.watch(segmentationRepositoryProvider);
  return SegmentationController(repo);
});
