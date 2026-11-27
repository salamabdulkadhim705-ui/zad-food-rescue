import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_config.dart';
import '../data/iraq_regions.dart';
import '../models/models.dart';

class SurplusRepository {
  final List<SurplusOffer> _localCache = IraqData.initialOffers();

  Future<List<SurplusOffer>> fetchOffersByGovernorate(String governorate) async {
    if (AppConfig.isCloudEnabled) {
      final response = await Supabase.instance.client
          .from('surplus_offers')
          .select()
          .eq('governorate', governorate)
          .gt('quantity_remaining', 0)
          .order('created_at', ascending: false);

      return (response as List)
          .map((row) => SurplusOffer.fromJson(row as Map<String, dynamic>))
          .toList();
    }
    return _localCache.where((o) => o.governorate == governorate).toList();
  }

  Future<void> publishOffer(SurplusOffer offer) async {
    if (AppConfig.isCloudEnabled) {
      await Supabase.instance.client.from('surplus_offers').insert(offer.toJson());
    } else {
      _localCache.insert(0, offer);
    }
  }

  Future<bool> reserveOffer(SurplusOffer offer) async {
    if (offer.remaining <= 0) return false;
    if (AppConfig.isCloudEnabled) {
      await Supabase.instance.client
          .from('surplus_offers')
          .update({'quantity_remaining': offer.remaining - 1})
          .eq('id', offer.id);
    }
    offer.remaining--;
    return true;
  }
}
