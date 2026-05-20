import 'package:image_picker/image_picker.dart';

/// 이미지 선택 작업의 결과 상태를 나타내는 sealed class.
///
/// UI 레이어에서 `switch` 패턴 매칭으로 각 상태를 처리합니다.
sealed class ImagePickState {
  const ImagePickState();
}

/// 초기 상태 - 아직 아무 작업도 수행하지 않음
class ImagePickInitial extends ImagePickState {
  const ImagePickInitial();
}

/// 권한 확인 또는 이미지 선택 중
class ImagePickLoading extends ImagePickState {
  const ImagePickLoading();
}

/// 이미지 선택 성공
class ImagePickSuccess extends ImagePickState {
  final XFile image;
  const ImagePickSuccess(this.image);
}

/// 권한이 거부된 상태
///
/// [isPermanentlyDenied]가 true이면 시스템 설정 화면으로 유도해야 합니다.
class ImagePickPermissionDenied extends ImagePickState {
  final bool isPermanentlyDenied;
  const ImagePickPermissionDenied({required this.isPermanentlyDenied});
}

/// 사용자가 이미지 선택을 취소함
class ImagePickCancelled extends ImagePickState {
  const ImagePickCancelled();
}

/// 예기치 않은 오류 발생
class ImagePickError extends ImagePickState {
  final String message;
  const ImagePickError(this.message);
}
