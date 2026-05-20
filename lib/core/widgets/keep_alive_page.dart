// 탭 전환 시 각 화면의 상태를 유지하는 래퍼 위젯
import 'package:flutter/material.dart';

/// 하단 네비게이션 탭 전환 시 각 탭의 스크롤 위치와 상태를 보존
class KeepAlivePage extends StatefulWidget {
  const KeepAlivePage({super.key, required this.child});

  final Widget child;

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
