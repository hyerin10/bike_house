import 'package:permission_handler/permission_handler.dart';

/// 갤러리(사진 라이브러리) 권한 요청 결과
enum GalleryPermissionResult {
  /// 허용됨 (granted / limited 포함)
  granted,

  /// 거부됨 (재요청 가능)
  denied,

  /// 영구 거부 — 시스템 설정 화면으로 직접 이동해야 함
  permanentlyDenied,
}

/// 갤러리 권한을 확인하고 필요하면 시스템 팝업을 띄웁니다.
///
/// - 이미 허용된 상태라면 팝업 없이 [GalleryPermissionResult.granted] 반환
/// - 영구 거부 상태라면 팝업 없이 [GalleryPermissionResult.permanentlyDenied] 반환
/// - 그 외(미결정 / 일반 거부)라면 시스템 팝업을 띄워 결과를 반환
Future<GalleryPermissionResult> requestGalleryPermission() async {
  var status = await Permission.photos.status;

  if (status.isGranted || status.isLimited) {
    return GalleryPermissionResult.granted;
  }

  if (status.isPermanentlyDenied) {
    return GalleryPermissionResult.permanentlyDenied;
  }

  status = await Permission.photos.request();

  if (status.isGranted || status.isLimited) {
    return GalleryPermissionResult.granted;
  }

  if (status.isPermanentlyDenied) {
    return GalleryPermissionResult.permanentlyDenied;
  }

  return GalleryPermissionResult.denied;
}
