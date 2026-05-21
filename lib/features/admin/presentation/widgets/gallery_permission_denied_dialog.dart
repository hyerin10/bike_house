import 'package:flutter/material.dart';

/// 갤러리 권한이 영구 거부된 경우, 설정으로 이동할지 묻는 다이얼로그.
///
/// 반환값: `true` = 설정으로 이동 선택, `false` = 취소, `null` = 바깥 탭 등으로 닫힘
Future<bool?> showGalleryPermissionPermanentlyDeniedDialog(
  BuildContext context,
) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        '사진 접근 권한 필요',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: const Text(
        '사진 라이브러리 접근 권한이 영구적으로 거부되어 있습니다.\n'
        '이미지를 업로드하려면 설정에서 직접 권한을 허용해 주세요.',
        style: TextStyle(fontSize: 14, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('설정으로 이동'),
        ),
      ],
    ),
  );
}
