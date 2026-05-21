/// 이름/성: 한글·영문 1~10자
String? validateCheckoutName(String? v) {
  if (v == null || v.trim().isEmpty) return '필수 항목입니다.';
  final trimmed = v.trim();
  if (trimmed.length > 10) return '10자 이내로 입력해주세요.';
  if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(trimmed)) {
    return '한글 또는 영문만 입력 가능합니다.';
  }
  return null;
}

/// 주소: 5자 이상
String? validateCheckoutAddress(String? v) {
  if (v == null || v.trim().isEmpty) return '주소를 입력해주세요.';
  if (v.trim().length < 5) return '정확한 주소를 입력해주세요. (5자 이상)';
  return null;
}

/// 도시: 한글·영문
String? validateCheckoutCity(String? v) {
  if (v == null || v.trim().isEmpty) return '도시를 입력해주세요.';
  if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(v.trim())) {
    return '한글 또는 영문만 입력 가능합니다.';
  }
  return null;
}

/// 우편번호: 숫자 5자리
String? validateCheckoutZip(String? v) {
  if (v == null || v.trim().isEmpty) return '우편번호를 입력해주세요.';
  final digits = v.trim().replaceAll(RegExp(r'\D'), '');
  if (digits.length != 5) return '5자리 숫자로 입력해주세요.';
  return null;
}

/// 전화번호: 010으로 시작하는 11자리
String? validateCheckoutPhone(String? v) {
  if (v == null || v.trim().isEmpty) return '전화번호를 입력해주세요.';
  final digits = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
  if (!RegExp(r'^010\d{8}$').hasMatch(digits)) {
    return '010으로 시작하는 11자리 번호를 입력해주세요. (예: 010-1234-5678)';
  }
  return null;
}
