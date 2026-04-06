import '../models/outfit_model.dart';

class WardrobeService {
  static final WardrobeService _instance = WardrobeService._internal();

  factory WardrobeService() {
    return _instance;
  }

  WardrobeService._internal();

  // In-memory list to store outfits (no Firebase required as per instructions)
  final List<Outfit> _outfits = [];

  // CREATE
  void addOutfit(Outfit outfit) {
    _outfits.add(outfit);
  }

  // READ
  List<Outfit> getOutfits() {
    // Return a copy to prevent direct modification
    return List.unmodifiable(_outfits);
  }

  // UPDATE
  void updateOutfit(Outfit updatedOutfit) {
    final index = _outfits.indexWhere((o) => o.outfitId == updatedOutfit.outfitId);
    if (index != -1) {
      _outfits[index] = updatedOutfit;
    }
  }

  // DELETE
  void deleteOutfit(String outfitId) {
    _outfits.removeWhere((o) => o.outfitId == outfitId);
  }
}
