import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../application/add_product_controller.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _stockCtrl = TextEditingController(text: '0');
    _descCtrl = TextEditingController();

    _nameCtrl.addListener(
      () => ref.read(addProductProvider.notifier).updateName(_nameCtrl.text),
    );
    _priceCtrl.addListener(
      () => ref
          .read(addProductProvider.notifier)
          .updatePrice(_priceCtrl.text.replaceAll(',', '')),
    );
    _stockCtrl.addListener(
      () =>
          ref.read(addProductProvider.notifier).updateStock(_stockCtrl.text),
    );
    _descCtrl.addListener(
      () => ref
          .read(addProductProvider.notifier)
          .updateDescription(_descCtrl.text),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _handleSave() =>
      ref.read(addProductProvider.notifier).save();

  void _handleCancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    ref.listen<AddProductState>(addProductProvider, (prev, next) {
      if (!mounted) return;

      if (next.isSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('상품이 등록되었습니다.'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(addProductProvider.notifier).clearError();
      }
    });

    final state = ref.watch(addProductProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AppBar(
        isLoading: state.isLoading,
        isValid: state.isValid,
        onCancel: _handleCancel,
        onSave: _handleSave,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ThumbnailSection(thumbnail: state.thumbnail),
            const SizedBox(height: 12),
            _BasicInfoSection(
              nameCtrl: _nameCtrl,
              priceCtrl: _priceCtrl,
              stockCtrl: _stockCtrl,
            ),
            const SizedBox(height: 12),
            _DetailImagesSection(
              images: state.detailImages,
            ),
            const SizedBox(height: 12),
            _DescriptionSection(descCtrl: _descCtrl),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        isLoading: state.isLoading,
        isValid: state.isValid,
        onCancel: _handleCancel,
        onSave: _handleSave,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.isLoading,
    required this.isValid,
    required this.onCancel,
    required this.onSave,
  });

  final bool isLoading;
  final bool isValid;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: isLoading ? null : onCancel,
      ),
      title: const Text('상품 등록'),
      actions: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: const Text(
            '취소',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton(
            onPressed: isValid && !isLoading ? onSave : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              disabledBackgroundColor: AppColors.textHint,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '저장하기',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 1: 대표 이미지
// ─────────────────────────────────────────────────────────────────────────────

class _ThumbnailSection extends ConsumerWidget {
  const _ThumbnailSection({required this.thumbnail});

  final XFile? thumbnail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: '대표 이미지', required: true),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () =>
                ref.read(addProductProvider.notifier).pickThumbnail(),
            child: thumbnail == null
                ? _ThumbnailPlaceholder()
                : _ThumbnailPreview(thumbnail: thumbnail!),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textHint,
          width: 1.5,
          style: BorderStyle.none,
        ),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.file_upload_outlined,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이미지 업로드',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '클릭하여 파일 선택',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailPreview extends ConsumerWidget {
  const _ThumbnailPreview({required this.thumbnail});

  final XFile thumbnail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(thumbnail.path),
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
                  onTap: () => ref
                      .read(addProductProvider.notifier)
                      .clearThumbnail(),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: () =>
                ref.read(addProductProvider.notifier).pickThumbnail(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    '변경',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 2: 기본 정보
// ─────────────────────────────────────────────────────────────────────────────

class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: '기본 정보'),
          const SizedBox(height: 16),

          // 상품명
          const _FieldLabel(label: '상품명', required: true),
          const SizedBox(height: 6),
          _InputField(
            controller: nameCtrl,
            hintText: '상품명을 입력하세요',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // 판매가격
          const _FieldLabel(label: '판매가격', required: true),
          const SizedBox(height: 6),
          _InputField(
            controller: priceCtrl,
            hintText: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [_KRWInputFormatter()],
            suffixText: '원',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // 재고 수량
          const _FieldLabel(label: '재고 수량', required: true),
          const SizedBox(height: 6),
          _InputField(
            controller: stockCtrl,
            hintText: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            suffixText: '개',
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 3: 상세 이미지
// ─────────────────────────────────────────────────────────────────────────────

class _DetailImagesSection extends ConsumerWidget {
  const _DetailImagesSection({required this.images});

  final List<XFile> images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = images.length;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionLabel(label: '상세 이미지'),
              Text(
                '$count/10',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // 이미지 추가 버튼 (10장 미만인 경우만 표시)
                if (count < 10)
                  GestureDetector(
                    onTap: () =>
                        ref.read(addProductProvider.notifier).pickDetailImages(),
                    child: Container(
                      width: 88,
                      height: 88,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _DashedBorderPainter(radius: 10),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.textSecondary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                // 선택된 이미지 목록
                ...List.generate(count, (i) {
                  return Stack(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(images[i].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(addProductProvider.notifier)
                              .removeDetailImage(i),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '상품 상세 페이지에 표시될 이미지입니다. 최대 10장까지 등록 가능합니다.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 4: 상품 설명
// ─────────────────────────────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.descCtrl});

  final TextEditingController descCtrl;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: '상품 설명'),
          const SizedBox(height: 12),
          TextField(
            controller: descCtrl,
            minLines: 6,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: '상품에 대한 상세 설명을 입력하세요...',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FB),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Action Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isLoading,
    required this.isValid,
    required this.onCancel,
    required this.onSave,
  });

  final bool isLoading;
  final bool isValid;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.divider, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isValid && !isLoading ? onSave : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                disabledBackgroundColor: AppColors.textHint,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '저장하기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text(
            '*',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 2),
          const Text(
            '*',
            style: TextStyle(color: Color(0xFFEF4444), fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffixText,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        suffixText: suffixText,
        suffixStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KRW 입력 포맷터 (숫자에 천 단위 콤마 자동 삽입)
// ─────────────────────────────────────────────────────────────────────────────

class _KRWInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final number = int.parse(digits);
    final formatted = _addCommas(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 점선 테두리 페인터
// ─────────────────────────────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({this.radius = 12});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textHint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.radius != radius;
}
