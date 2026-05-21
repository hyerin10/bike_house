import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 홈·인기 부품·검색 결과·관리자 주문 등에서 쓰는 동일한 검색 필드 스타일의 반지름.
const double kAppProductSearchRadius = 12;

/// 상품/주문 검색 등에 공통으로 쓰는 [InputDecoration].
InputDecoration appProductSearchInputDecoration(
  BuildContext context, {
  required String hintText,
  Widget? suffixIcon,
}) {
  final unfocused = OutlineInputBorder(
    borderRadius: BorderRadius.circular(kAppProductSearchRadius),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    hintText: hintText,
    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textHint,
        ),
    prefixIcon: const Icon(
      Icons.search_rounded,
      color: AppColors.textHint,
      size: 22,
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.background,
    border: unfocused,
    enabledBorder: unfocused,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kAppProductSearchRadius),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12),
    isDense: true,
  );
}

/// 공통 검색 텍스트 필드 (배경 래핑·패딩만 화면별로 조절).
class AppProductSearchBar extends StatelessWidget {
  const AppProductSearchBar({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.textInputAction = TextInputAction.search,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 12),
    this.wrapWithBackground = true,
    this.backgroundColor = AppColors.surface,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final TextInputAction textInputAction;
  final EdgeInsetsGeometry padding;
  final bool wrapWithBackground;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: appProductSearchInputDecoration(
        context,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );

    if (!wrapWithBackground) {
      return Padding(padding: padding, child: field);
    }

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: padding,
      child: field,
    );
  }
}
