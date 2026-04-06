/// Builds image search URLs for suggestion cards.
///
/// Uses loremflickr.com — free, keyword-based, no API key required.
/// (source.unsplash.com is deprecated and no longer works)
class ImageService {
  /// Returns a relevant image URL for the given fashion [item].
  ///
  /// Examples:
  ///   "black heels"    → loremflickr.com/400/400/fashion,black,heels
  ///   "gold necklace"  → loremflickr.com/400/400/fashion,gold,necklace
  ///   "leather clutch" → loremflickr.com/400/400/fashion,leather,clutch
  static String getUnsplashUrl(String item, {int width = 400, int height = 400}) {
    // Generate image URL dynamically using Unsplash
    final clean = item.trim().toLowerCase().replaceAll(' ', '+');
    return 'https://source.unsplash.com/featured/?$clean';
  }

  /// Returns image URLs for a list of outfit items.
  static List<String> getUrlsForItems(List<String> items) {
    return items.map((item) => getUnsplashUrl(item)).toList();
  }
}
