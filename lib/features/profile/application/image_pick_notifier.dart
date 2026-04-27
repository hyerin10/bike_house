import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:permission_handler/permission_handler.dart';

import '../domain/image_pick_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 이미지 선택 소스 (카메라 / 갤러리)
// ─────────────────────────────────────────────────────────────────────────────

enum PickSource { camera, gallery }

// ─────────────────────────────────────────────────────────────────────────────
// ImagePickNotifier
//
// 권한 확인 → 요청 → 이미지 선택까지의 흐름을 단일 Notifier로 관리합니다.
// 상태는 ImagePickState sealed class로 표현됩니다.
// ─────────────────────────────────────────────────────────────────────────────

class ImagePickNotifier extends Notifier<ImagePickState> {
  final _picker = ip.ImagePicker();

  @override
  ImagePickState build() => const ImagePickInitial();

  // ── 공개 API ────────────────────────────────────────────────────────────────

  /// 카메라 또는 갤러리에서 이미지를 선택합니다.
  ///
  /// 내부적으로 플랫폼별 권한을 확인/요청하고,
  /// 결과를 [ImagePickState]로 state에 반영합니다.
  Future<void> pickImage(PickSource source) async {
    state = const ImagePickLoading();

    final permission = _permissionFor(source);
    final granted = await _requestPermission(permission);
    if (!granted) return;

    try {
      final ip.XFile? file = await _picker.pickImage(
        source: source == PickSource.camera
            ? ip.ImageSource.camera
            : ip.ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
      );

      state = file != null
          ? ImagePickSuccess(file)
          : const ImagePickCancelled();
    } catch (e) {
      state = ImagePickError(e.toString());
    }
  }

  /// 현재 권한 상태만 확인합니다 (시스템 팝업 없음).
  Future<PermissionStatus> checkPermission(PickSource source) {
    return _permissionFor(source).status;
  }

  /// 영구 거부(permanently denied) 상태일 때 시스템 앱 설정 화면을 엽니다.
  Future<bool> openSettings() => openAppSettings();

  /// 상태를 초기값으로 되돌립니다 (다음 선택 전 초기화에 사용).
  void reset() => state = const ImagePickInitial();

  // ── 내부 헬퍼 ───────────────────────────────────────────────────────────────

  /// [source]에 대응하는 플랫폼 Permission 객체를 반환합니다.
  Permission _permissionFor(PickSource source) =>
      source == PickSource.camera ? Permission.camera : Permission.photos;

  /// 권한을 요청하고 허용 여부를 반환합니다.
  ///
  /// - 이미 허용(또는 limited): true 즉시 반환
  /// - 영구 거부: [ImagePickPermissionDenied(isPermanentlyDenied: true)] 설정 후 false
  /// - 일반 거부 / 미결정: 시스템 팝업 요청 후 결과 판단
  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      state = const ImagePickPermissionDenied(isPermanentlyDenied: true);
      return false;
    }

    status = await permission.request();

    if (status.isGranted || status.isLimited) return true;

    state = ImagePickPermissionDenied(
      isPermanentlyDenied: status.isPermanentlyDenied,
    );
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final imagePickProvider =
    NotifierProvider<ImagePickNotifier, ImagePickState>(
  ImagePickNotifier.new,
);
