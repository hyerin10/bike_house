/// 원화 가격을 "₩12,345" 형태 문자열로 변환합니다.
String formatKrw(num price) {
  final intPrice = price.round();
  return '₩${intPrice.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      )}';
}
