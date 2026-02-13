/// Category slugs that are considered "clothing" for virtual try-on.
/// Add your backend category slugs here so "Try on" shows only for these.
const List<String> kClothingCategorySlugs = [
  'clothing',
  'fashion',
  'apparel',
  'clothes',
  't-shirt',
  'shirt',
  'dress',
  'jeans',
  'pants',
  'upper',
  'lower',
  'overall',
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
  return kClothingCategorySlugs.contains(categorySlug.toLowerCase());
}
