import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';

class AddProductBasicInfoSection extends StatelessWidget {
  const AddProductBasicInfoSection({
    super.key,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;

  @override
  Widget build(BuildContext context) {
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProductSectionLabel(label: '기본 정보'),
          const SizedBox(height: 16),

          const ProductFieldLabel(label: '상품명', required: true),
          const SizedBox(height: 6),
          ProductInputField(
            controller: nameCtrl,
            hintText: '상품명을 입력하세요',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          const ProductFieldLabel(label: '판매가격', required: true),
          const SizedBox(height: 6),
          ProductInputField(
            controller: priceCtrl,
            hintText: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [KRWInputFormatter()],
            suffixText: '원',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          const ProductFieldLabel(label: '재고 수량', required: true),
          const SizedBox(height: 6),
          ProductInputField(
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
