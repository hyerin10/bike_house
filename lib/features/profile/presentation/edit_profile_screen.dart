import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

/// 프로필 수정 화면
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    final meta = user?.userMetadata ?? {};

    _nameController = TextEditingController(text: meta['name'] as String? ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');

    // DB에는 하이픈 없이 저장되어 있으므로 표시할 때 포맷 복원
    final rawPhone = meta['phone'] as String? ?? '';
    _phoneController = TextEditingController(text: _formatPhone(rawPhone));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// 숫자만 있는 전화번호를 010-XXXX-XXXX 형태로 변환
  String _formatPhone(String digits) {
    final d = digits.replaceAll(RegExp(r'\D'), '');
    if (d.length == 11) return '${d.substring(0, 3)}-${d.substring(3, 7)}-${d.substring(7)}';
    if (d.length == 10) return '${d.substring(0, 3)}-${d.substring(3, 6)}-${d.substring(6)}';
    return digits;
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 저장되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 실패: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: const Text('프로필 수정'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 이름 입력 ────────────────────────────────────────────
                  _FormLabel(label: '이름'),
                  const SizedBox(height: 8),
                  _ProfileTextField(controller: _nameController),
                  const SizedBox(height: 20),

                  // ─── 이메일 입력 (비활성화) ───────────────────────────────
                  _FormLabel(label: '이메일'),
                  const SizedBox(height: 8),
                  _ProfileTextField(
                    controller: _emailController,
                    enabled: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      '이메일은 변경할 수 없습니다.',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── 전화번호 입력 ────────────────────────────────────────
                  _FormLabel(label: '전화번호'),
                  const SizedBox(height: 8),
                  _ProfileTextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),

          // ─── 하단 저장 버튼 (화면에 고정) ─────────────────────────────────
          _SaveButton(onPressed: _isLoading ? null : _saveChanges, isLoading: _isLoading),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 폼 라벨
// ─────────────────────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 프로필 텍스트 필드
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 15,
          ),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? AppColors.surface : const Color(0xFFF0F1F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 하단 저장 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.surface,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  '변경사항 저장',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surface,
                  ),
                ),
        ),
      ),
    );
  }
}
