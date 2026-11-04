import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/models/product_model.dart';
import '../../services/providers/product_approval_provider.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  static const String _prefKey = 'eventhub_favorite_service_ids';

  FavoritesNotifier() : super({'s1', 's2'}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_prefKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(savedJson);
        state = list.map((e) => e.toString()).toSet();
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(state.toList()));
    } catch (_) {}
  }

  bool isFavorite(String serviceId) {
    if (state.contains(serviceId)) return true;
    if (serviceId == 's1' && state.contains('ps1')) return true;
    if (serviceId == 'ps1' && state.contains('s1')) return true;
    return false;
  }

  bool toggleFavorite(String serviceId) {
    final next = Set<String>.from(state);
    final targetId = (serviceId == 'ps1' && !next.contains('ps1') && next.contains('s1')) ? 's1' : serviceId;
    final bool isNowFav;
    if (next.contains(targetId) || next.contains(serviceId)) {
      next.remove(targetId);
      next.remove(serviceId);
      if (serviceId == 's1') next.remove('ps1');
      if (serviceId == 'ps1') next.remove('s1');
      isNowFav = false;
    } else {
      next.add(serviceId);
      isNowFav = true;
    }
    state = next;
    _persist();
    return isNowFav;
  }

  void addFavorite(String serviceId) {
    if (!isFavorite(serviceId)) {
      state = {...state, serviceId};
      _persist();
    }
  }

  void removeFavorite(String serviceId) {
    final next = Set<String>.from(state)
      ..remove(serviceId)
      ..remove(serviceId == 's1' ? 'ps1' : (serviceId == 'ps1' ? 's1' : ''));
    state = next;
    _persist();
  }

  void clearAll() {
    state = <String>{};
    _persist();
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

/// Returns list of ProductModel matching the favorited IDs
final favoriteProductsProvider = Provider<List<ProductModel>>((ref) {
  final favIds = ref.watch(favoritesProvider);
  final productApproval = ref.watch(productApprovalProvider);
  return favIds.map((id) => productApproval.resolveServiceById(id)).toList();
});
