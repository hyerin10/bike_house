import 'package:flutter/material.dart';

import 'package:bike_house/features/checkout/application/checkout_validators.dart';
import 'package:bike_house/features/checkout/presentation/widgets/checkout_shared_widgets.dart';

class ShippingAddressSection extends StatelessWidget {
  const ShippingAddressSection({
    super.key,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.zipCtrl,
    required this.phoneCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController zipCtrl;
  final TextEditingController phoneCtrl;

  @override
  Widget build(BuildContext context) {
    return CheckoutSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CheckoutSectionTitle(
            icon: Icons.location_on_outlined,
            label: '배송 주소',
          ),
          const SizedBox(height: 16),
          CheckoutLabeledTextField(
            controller: nameCtrl,
            label: '이름',
            hint: '홍길동',
            validator: validateCheckoutName,
          ),
          const SizedBox(height: 12),
          CheckoutLabeledTextField(
            controller: addressCtrl,
            label: '주소',
            hint: '서울시 강남구 테헤란로 123',
            validator: validateCheckoutAddress,
          ),
          const SizedBox(height: 12),
          CheckoutLabeledTextField(
            controller: zipCtrl,
            label: '우편번호',
            hint: '06234',
            keyboardType: TextInputType.number,
            validator: validateCheckoutZip,
          ),
          const SizedBox(height: 12),
          CheckoutLabeledTextField(
            controller: phoneCtrl,
            label: '전화번호',
            hint: '010-1234-5678',
            keyboardType: TextInputType.phone,
            validator: validateCheckoutPhone,
          ),
        ],
      ),
    );
  }
}
