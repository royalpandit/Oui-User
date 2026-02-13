/// Category slugs that are considered "clothing" for virtual try-on.
/// Exact matches (e.g. backend slug is exactly "dresses").
const List<String> kClothingCategorySlugs = [
  'clothing',
  'fashion',
  'apparel',
  'clothes',
  't-shirt',
  'shirts',
  'shirt',
  'dresses',
  'dress',
  'jeans',
  'pants',
  'upper',
  'lower',
  'overall',
];

/// Keywords: if category slug contains any of these, treat as clothing.
const List<String> kClothingSlugKeywords = [
  'dress', 'shirt', 'clothing', 'clothes', 'fashion', 'apparel',
  'pant', 'jeans', 'top', 'wear', 'jacket', 'sweater', 'blouse',
];

/// CatVTON cloth_type: upper (torso), lower (pants), overall (full).
String clothTypeFromCategorySlug(String? categorySlug) {
  if (categorySlug == null || categorySlug.isEmpty) return 'upper';
  final s = categorySlug.toLowerCase();
  if (s.contains('pant') || s.contains('jeans') || s.contains('lower')) {
    return 'lower';
  }
  if (s.contains('dress') || s.contains('suit') || s.contains('overall')) {
    return 'overall';
  }
  return 'upper';
}

bool isClothingCategory(String? categorySlug) {
  if (categorySlug == null || categorySlug.isEmpty) return false;
  final s = categorySlug.toLowerCase();
  if (kClothingCategorySlugs.contains(s)) return true;
  for (final keyword in kClothingSlugKeywords) {
    if (s.contains(keyword)) return true;
  }
  return false;
}
