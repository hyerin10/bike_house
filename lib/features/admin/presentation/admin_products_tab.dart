import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/admin/presentation/add_product_screen.dart';
import 'package:bike_house/features/admin/presentation/edit_product_screen.dart';
import 'package:bike_house/features/admin/presentation/providers/admin_products_providers.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_product_delete_dialog.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_product_empty_view.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_product_load_error_view.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_product_row.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_product_search_bar.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_product_table_header.dart';
import 'package:bike_house/features/product/data/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 상품 관리 탭
// ─────────────────────────────────────────────────────────────────────────────

class AdminProductsTab extends ConsumerWidget {
  const AdminProductsTab({super.key});

  void _openEdit(BuildContext context, ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProductScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFiltered = ref.watch(adminFilteredProductsProvider);

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              AdminProductSearchBar(
                onChanged: (q) =>
                    ref.read(adminProductSearchQueryProvider.notifier).state =
                        q,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddProductScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    '상품 등록',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const AdminProductTableHeader(),
        Expanded(
          child: asyncFiltered.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const AdminProductLoadErrorView(),
            data: (filtered) {
              if (filtered.isEmpty) return const AdminProductEmptyView();

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  return AdminProductRow(
                    product: product,
                    onEdit: () => _openEdit(context, product),
                    onDelete: () => showAdminDeleteProductDialog(
                      context,
                      ref,
                      product: product,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
