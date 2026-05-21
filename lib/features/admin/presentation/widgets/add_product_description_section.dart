import 'package:flutter/material.dart';

import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';

class AddProductDescriptionSection extends StatelessWidget {
  const AddProductDescriptionSection({super.key, required this.descCtrl});

  final TextEditingController descCtrl;

  @override
  Widget build(BuildContext context) {
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProductSectionLabel(label: '상품 설명'),
          const SizedBox(height: 12),
          ProductInputField(
            controller: descCtrl,
            hintText: '상품에 대한 상세 설명을 입력하세요...',
            keyboardType: TextInputType.multiline,
            minLines: 6,
            maxLines: null,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }
}
