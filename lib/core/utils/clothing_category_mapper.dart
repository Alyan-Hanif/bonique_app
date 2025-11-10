/// Maps AI-generated clothing types to standardized filter categories
/// This allows flexible matching of various clothing terms to our fixed filter options
class ClothingCategoryMapper {
  // Standard filter categories
  static const String all = 'All';
  static const String dresses = 'Dresses';
  static const String jeans = 'Jeans';
  static const String shirts = 'Shirts';
  static const String skirts = 'Skirts';
  static const String hoodies = 'Hoodies';

  /// Maps various clothing type terms to standardized categories
  static final Map<String, List<String>> _categoryMap = {
    // Dresses category
    dresses: [
      'dress',
      'dresses',
      'gown',
      'sundress',
      'maxi dress',
      'mini dress',
      'midi dress',
      'cocktail dress',
      'evening dress',
      'party dress',
      'casual dress',
      'formal dress',
    ],

    // Jeans/Pants category
    jeans: [
      'jeans',
      'jean',
      'denim',
      'pants',
      'pant',
      'trousers',
      'trouser',
      'slacks',
      'chinos',
      'khakis',
      'leggings',
      'joggers',
      'sweatpants',
      'cargo pants',
      'dress pants',
    ],

    // Shirts/Tops category
    shirts: [
      'shirt',
      'shirts',
      'top',
      'tops',
      't-shirt',
      'tshirt',
      'tee',
      'blouse',
      'tank top',
      'tank',
      'cami',
      'camisole',
      'polo',
      'button-up',
      'button up',
      'tunic',
      'crop top',
      'halter top',
      'tube top',
      'sweater',
      'pullover',
      'cardigan',
      'vest',
    ],

    // Skirts category
    skirts: [
      'skirt',
      'skirts',
      'mini skirt',
      'maxi skirt',
      'midi skirt',
      'pencil skirt',
      'a-line skirt',
      'pleated skirt',
    ],

    // Hoodies/Outerwear category
    hoodies: [
      'hoodie',
      'hoodies',
      'sweatshirt',
      'jacket',
      'jackets',
      'coat',
      'blazer',
      'puffer',
      'puffer jacket',
      'bomber jacket',
      'denim jacket',
      'leather jacket',
      'windbreaker',
      'raincoat',
      'overcoat',
      'peacoat',
      'trench coat',
      'cardigan jacket',
      'fleece',
      'zip-up',
    ],
  };

  /// Maps an AI-generated clothing type to a standardized category
  /// Returns the category name if matched, or null if no match found
  static String? mapToCategory(String? aiType) {
    if (aiType == null || aiType.isEmpty) {
      return null;
    }

    // Normalize the input: lowercase and trim
    final normalizedType = aiType.toLowerCase().trim();

    // Check each category's terms
    for (final entry in _categoryMap.entries) {
      final category = entry.key;
      final terms = entry.value;

      // Check if any term matches (exact match or contains)
      for (final term in terms) {
        if (normalizedType == term || normalizedType.contains(term)) {
          return category;
        }
      }
    }

    // No match found
    return null;
  }

  /// Gets all items that belong to a specific filter category
  /// Used for filtering the wardrobe items
  static bool belongsToCategory(String? aiType, String filterCategory) {
    // "All" category shows everything
    if (filterCategory == all) {
      return true;
    }

    // Map the AI type to our standard category
    final mappedCategory = mapToCategory(aiType);

    // Check if it matches the filter
    return mappedCategory == filterCategory;
  }

  /// Returns a list of all standard category names
  static List<String> getAllCategories() {
    return [all, dresses, jeans, shirts, skirts, hoodies];
  }

  /// Adds a custom term to a category (for extending the mapper dynamically)
  static void addTermToCategory(String category, String term) {
    if (_categoryMap.containsKey(category)) {
      _categoryMap[category]!.add(term.toLowerCase().trim());
    }
  }
}
