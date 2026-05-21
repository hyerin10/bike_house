/// 라우트 인자 등에서 넘어온 검색어를 [searchResultProvider]에 넣기 전에 정규화합니다.
String? normalizeSearchQuery(String? raw) {
  final trimmed = raw?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}
