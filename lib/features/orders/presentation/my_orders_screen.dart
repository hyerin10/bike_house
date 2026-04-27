import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/order_lookup_notifier.dart';
import 'widgets/order_card.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  final _orderNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _orderNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref.read(orderLookupProvider.notifier).fetchMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    final lookupState = ref.watch(orderLookupProvider);
    final asyncOrders = lookupState.orders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── 입력 폼 ─────────────────────────────────────────────
          _SearchForm(
            formKey: _formKey,
            orderNumberController: _orderNumberController,
            phoneController: _phoneController,
            isLoading: asyncOrders is AsyncLoading,
            onSearch: _onSearch,
            onOrderNumberChanged: (v) =>
                ref.read(orderLookupProvider.notifier).setOrderNumber(v),
            onPhoneChanged: (v) =>
                ref.read(orderLookupProvider.notifier).setPhoneNumber(v),
          ),

          // ─── 결과 영역 ───────────────────────────────────────────
          Expanded(
            child: asyncOrders.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorView(
                message: orderParseErrorMessage(error.toString()),
              ),
              data: (orders) {
                // 초기 상태(아직 조회 전): 안내 메시지 표시
                if (orders.isEmpty &&
                    lookupState.orderNumber.isEmpty &&
                    lookupState.phoneNumber.isEmpty) {
                  return const _GuideView();
                }

                if (orders.isEmpty) {
                  return const _EmptyResultView();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => OrderCard(
                    order: orders[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 검색 폼
// ─────────────────────────────────────────────────────────────────────────────

class _SearchForm extends StatelessWidget {
  const _SearchForm({
    required this.formKey,
    required this.orderNumberController,
    required this.phoneController,
    required this.isLoading,
    required this.onSearch,
    required this.onOrderNumberChanged,
    required this.onPhoneChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController orderNumberController;
  final TextEditingController phoneController;
  final bool isLoading;
  final VoidCallback onSearch;
  final ValueChanged<String> onOrderNumberChanged;
  final ValueChanged<String> onPhoneChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 주문번호 입력
            _InputField(
              controller: orderNumberController,
              label: '주문번호',
              hint: 'ORD-2024-001',
              icon: Icons.receipt_long_outlined,
              onChanged: onOrderNumberChanged,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '주문번호를 입력해주세요.' : null,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 12),

            // 전화번호 입력
            _InputField(
              controller: phoneController,
              label: '전화번호',
              hint: '010-0000-0000',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: onPhoneChanged,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '전화번호를 입력해주세요.' : null,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSearch(),
            ),

            const SizedBox(height: 16),

            // 조회 버튼
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textHint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 20),
                          SizedBox(width: 6),
                          Text('주문 조회'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 공통 입력 필드
// ─────────────────────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textHint),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textHint,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 초기 안내 화면
// ─────────────────────────────────────────────────────────────────────────────

class _GuideView extends StatelessWidget {
  const _GuideView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.manage_search_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '주문 내역 조회',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '주문 시 입력하신 주문번호와\n전화번호를 입력하시면\n주문 내역을 확인하실 수 있습니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 결과 없음 뷰
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyResultView extends StatelessWidget {
  const _EmptyResultView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              '일치하는 주문 내역이 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '주문번호와 전화번호를 다시 확인해주세요.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 에러 뷰
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              '조회 중 오류가 발생했습니다.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
