import 'package:flutter/material.dart';

void showAdminRestrictedNavSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      const SnackBar(
        content: Text('관리자 모드에서는 사용할 수 없는 메뉴입니다.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
